# Delete registry Key or Value
# Trend Micro Vision One Custom Script Example with parameters
# D. Girard Vision One PM Team
# To delete a registry key only pass regKey parameter
# -regKey "HKLM:\SOFTWARE\NodeSoftware"
# To delete a registry value, you must pass regKey and regValue
# -regKey "HKLM:\SOFTWARE\NodeSoftware"  -regValue "myApp"
param(
[Parameter (Mandatory = $true)] [String]$regKey, 
[Parameter (Mandatory = $false)] [String]$regValue
)
if ($regKey){
    Write-host "DeleteRegKeyValue.ps1" $regKey $regValue
    if ($regValue){
        If (Get-ItemProperty -Path $regKey -Name $regValue -ErrorAction SilentlyContinue) {
            Remove-ItemProperty -Path $regKey -Name $regValue -Force -Verbose
            Write-host "Deleted Registry Value" $regKey $regValue
        }
        else {Write-host "Registry value does not exist" $regKey $regValue}
    }
    else {
        if (Get-Item $regKey -ErrorAction SilentlyContinue){
            Remove-Item -Path $regKey -Force -Verbose
            Write-host "Deleted Registry key " $regKey 
        }
        else {Write-host "Registry key does not exist" $regKey}
    }    
}