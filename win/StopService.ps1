# Stop Service by process name or process id
# Trend Micro Vision One Custom Script Example with parameters
# Note: Kill process in Vision One use the SHA1 of the EXE responsible for the process. this script use 2 different methods
# D. Girard Vision One PM Team
# To kill a service by service name or Display name:
# -pName "Spooler" -by "Name"
# -pName "Print Spooler" -by "DisplayName"
param(
[Parameter (Mandatory = $true)] [String]$pName,
[Parameter (Mandatory = $true)] [ValidateSet("Name","DisplayName")][String]$by = "Name"
)
if ($pName) {
    Write-host "StopService.ps1" $pName
    if ($by -eq "Name") {
        Stop-Service -Name $pName
    }
    elseif($by -eq "DisplayName") {
        Stop-Service -DisplayName $pName
    }
    else {Write-host "action not recognized, please check misspelled action" $action}
    Write-Host 'Service Stopped:' $pName
}
