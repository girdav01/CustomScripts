#This script will use a yara rule to spot a suspicious process. this process will then be dump to a file
#Find a process with a specific yara rule and dump the memory of that process. See output for process file name and dmp file name.  this way you can collect them.
$yarafile =  "https://raw.githubusercontent.com/girdav01/CustomScripts/main/rules/testHunt004.yara"
$ProgressPreference = "SilentlyContinue"
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
                # This is where you should call any memory dump function and pass the process $p.Id and the "c:\ir" dump folder
				
                # list connections if any
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