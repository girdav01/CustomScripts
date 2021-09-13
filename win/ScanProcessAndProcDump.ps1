#This script will use a yara rule to spot a suspicious process. this process will then be dump to a file
#Find a process with a specific yara rule and dump the memory of that process. See output for process file name and dump file name.  this way you can collect them.
$yarafile =  "https://raw.githubusercontent.com/girdav01/CustomScripts/main/rules/testHunt004.yara"
$ProgressPreference = "SilentlyContinue"
function ProcDump
{
<#
.SYNOPSIS
ProcDump acquires memory dump of the specified process. Based on Kansa but highly modified
.DESCRIPTION
Uses Sysinternal's procdump.exe to write a dmp file to disk. 
.PARAMETER ProcId
A required parameter, the process id of the process you want to dump.
the second parameter (optional, default is c:\ir) is the path where you want the dump.
.EXAMPLE
ProcDump 10400
or 
ProcDump 10400 "c:\ir2"
.NOTES
Demo Custom Script for Trend Micro Vision One, Provided as is by the product team.
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False,Position=0)]
            [Int]$ProcId=$pid,

        [Parameter(Position = 1)]
        [ValidateScript({ Test-Path $_ })]
        [String]
        $DumpFilePath = "c:\ir"  #default dump folder
    )
    Write-Host "running procdump"
    #check if dump folder exist, if not then create it
    if ( -not (Test-Path -path $DumpFilePath )) {
        Write-Host $DumpFilePath "directory does not exist, let's create it"
        New-Item -Path $DumpFilePath -ItemType directory
    } else {
        Write-Host $DumpFilePath "exist, we are fine"
    }

    # checking if procdump.exe is there, if not then download
    if ( -not (Test-Path ".\procdump\Procdump.exe")) {
        Write-Host "Downloading procdump.exe"
        #trusted url to get procdump.exe only
        $procDumpExe = "https://download.sysinternals.com/files/Procdump.zip"
        Invoke-WebRequest -Uri $procDumpExe -OutFile ".\procdump.zip"
        Start-Sleep -Seconds 2
        Expand-Archive procdump.zip -Force
        Start-Sleep -Seconds 2
    } else {
        Write-Host "ProcDump.exe was already there! No need to download"
    }

    # config process dump full path name & get process name from pid
    $procname = (Get-Process -Id $ProcId).Name
    $ProcessFileName = $procname + "_" + $ProcId + ".dmp"
    $ProcessDumpPath = Join-Path $DumpFilePath $ProcessFileName
    Write-Host "Process Id" $ProcId
    Write-Host "Process name"  $procname
    Write-Host "Process dump file"  $ProcessDumpPath
    # recheck if procdump.exe is there in case download is blocked
    if (Test-Path ".\procdump\Procdump.exe") {
        # Dump specified process memory to file on disk named ProcessDumpPath
        & .\procdump\Procdump.exe /accepteula $ProcId $ProcessDumpPath 2> $null
        if ( -not (Test-Path -path $ProcessDumpPath  -PathType Leaf )) {
            Write-Host "ERROR Dump File does not exist : " -f White -nonewline; Write-Host $ProcessDumpPath 
        } else {
            Write-Host "Success! Dump File created : " -f White -nonewline; Write-Host $ProcessDumpPath
        }
    } else {
        Write-Host "We can't dump process memory since ProcDump.exe is not present. Check if download is blocked"    
    }
    # optionally remove procdump.zip and \procdump folder. if you want this, just uncomment next line
    # Remove-Item .\procdump\, .\procdump.zip -Force -Recurse
}
<#
This function will gather the permissions of the executiing user and 
return a true or false when called
#>
function Test-Administrator {
    [OutputType([bool])]
    param()
    process {
        [Security.Principal.WindowsPrincipal]$user = [Security.Principal.WindowsIdentity]::GetCurrent();
        return $user.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);
    }
}
<#
    This function handles the scanning of processes according to the yara rule specified.
    1) Will Download Yara 4.0.5 from Github
    2) Expand the zip archive
    3) Gather all of the running processes and pipe the output to yara
    4) Yara will take the passed rule and scan each process against the rule 
    5) Write the output of the scan from stdout to a file and the terminal 
#>
function ScanProcesses{
    if (-not (Test-Path $yarafile)) {
        Write-Host "The rule file could not be found."
    }
    else {
    Clear-Host
    Write-Host "Downloading Yara"
    Invoke-WebRequest -Uri "https://github.com/VirusTotal/yara/releases/download/v4.0.5/yara-v4.0.5-1554-win64.zip" -OutFile ".\yara64.zip"
    Expand-Archive yara64.zip -Force
    Clear-Host
    Write-Host "Scanning Processes"
    $host.UI.RawUI.ForegroundColor = "Red"
    $host.UI.RawUI.BackgroundColor = "Black"
    $outputFileName =  "$yarafile$(get-date -f yyyyMMddhhmmss).txt"
    Get-Process | ForEach-Object {
	    <#
        If a YARA Rule matches, the following will evaluate to "TRUE' and
        we will document additional information about the flagged process. 
        -D -p 10 was the original. replaced by -s -f
        #>
        if ($result = .\yara64\yara64.exe $yarafile $_.ID -D -s -f) {
            $p = Get-Process -Id $_.ID
            if ($p.Company -eq ""){
                $h = Get-FileHash $p.Path -Algorithm SHA1
                Write-Output "The following rule matched the following process:" $result
		        Get-Process -Id $_.ID | Format-Table -Property Id, ProcessName, Path
                $p_cmd = Get-CimInstance Win32_Process -Filter "ProcessId = $($p.Id)"
                Write-Host "|| MATCHED! ||" -f White -BackgroundColor Red; 
                Write-Host "PROCESS:" -f White -nonewline; Write-Host $p.Name
                Write-Host "COMPANY:" -f White -nonewline; Write-Host $p.Company
                Write-Host "PID:" -f White -nonewline; Write-Host $p.Id
                Write-Host "IMAGE PATH:" -f White -nonewline; Write-Host $p.Path
                Write-Host "COMMANDLINE:" -f White -nonewline; Write-Host $p_cmd.CommandLine
                Write-Host "SHA-1:" -f White -nonewline; Write-Host $h.hash
                Write-Host "MATCH:" -f White -nonewline; Write-Host $result
                $ppp = Get-CimInstance Win32_Process -Filter "ProcessId = $($p_cmd.ProcessId)"
                Write-Host "PARENT PROCESS:" -f White -nonewline; Write-Host $ppp.ProcessName -nonewline
                Write-Host " PPID:" -f White -nonewline; Write-Host $p_cmd.ParentProcessId -nonewline
                Write-Host " IMAGE PATH:" -f White -nonewline; Write-Host $ppp.ExecutablePath -nonewline
                Write-Host " COMMANDLINE:" -f White -nonewline; Write-Host $ppp.CommandLine
                #call ProcDump
                ProcDump $p.Id "c:\ir"
                # if the process got connections then write to logs
                foreach ($con in Get-NetTcpConnection -OwningProcess $p.Id -ErrorAction SilentlyContinue)
                {
                    Write-Host "LHOST:" -f White -nonewline; Write-Host $con.LocalAddress -nonewline
                    Write-Host " LPORT:" -f White -nonewline; Write-Host $con.LocalPort -nonewline
                    Write-Host " RHOST:" -f White -nonewline; Write-Host $con.RemoteAddress -nonewline
                    Write-Host " RPORT:" -f White -nonewline; Write-Host $con.RemotePort
                }
            } 2>&1 | Tee-Object -FilePath .\$outputFilename
	    }
    } 2>&1 | Tee-Object -FilePath .\$outputFilename

    $host.UI.RawUI.ForegroundColor = "White"
    $host.UI.RawUI.BackgroundColor = "DarkMagenta"
    if ( -not (Test-Path .\$outputFilename )) {
        Write-Output "No Processes were found matching the provided YARA rule: " $yarafile | Tee-Object -FilePath .\$outputFilename
    } else {
        Write-Host "Any processes that were flagged are saved in " $outputFilename 
    }
    Remove-Item .\yara64, .\yara64.zip -Force -Recurse
    # Remove-Item .\procdump.exe, .\procdump.zip -Force -Recurse
    }
}
<#
    This function will execute if the rule being specified is referenced as a URL
    1) Download the rule using Invoke-WebRequest naming it based on the downloaded file
    2) Call the ScanProcesses function
    3) Remove downloaded rule file
#>
function RuleByURL {
    Invoke-WebRequest -Uri $yarafile -OutFile $(split-path -path $yarafile -leaf)
    $yarafile = $(split-path -path $yarafile -leaf)
    ScanProcesses
    Remove-Item $yarafile
}

<#
Confirm that the executing user is in the Administrators group
#>
if (-not (Test-Administrator)) {
    Write-Error "This script must be executed as Administrator."
    break
}
<#
Logic to determine if the rule being passed is a URL or a file on disk
#>
if ($yarafile -match 'http.*\.(yara|yar)') {
    RuleByURL
}
else {
    ScanProcesses
}
