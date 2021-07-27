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
# testing function
# to test run notepad or notepad++, use task manager or Process Explorer to get the Process Id
# the second parameter (optional, default is c:\ir) is the path where you want the dump. 
procdump 21464 "c:\ir"