<#

.SYNOPSIS

Powershell script that help you remediate a security incident

.DESCRIPTION
Powershell script that help you remediate 
    - Delete Schedule Task
    - Add, Modify, Delete Registry keys
    - Delete Files/folders
    - Kill Process based on name
    - Delete Local user

    TODO
    - Unmap drives
    - Use Host file to block a domain
    - Use Windows Firewall to block IP/Port
    - Install a software patch
    - Stop a service

.EXAMPLE

Remediate.ps1

.NOTES
Demo Custom Script for Trend Micro Vision One, Provided as is by the product team.

Run CreateRemediationDemo.ps1 before so you can test with fake evidence

We could use an external config for the remediation taks but in this implementation we try to be self contained

If more than 1 item of any type is needed, we may implement a JSON structure instead of parameter variables for each
#>

#Remediation parameters, please set those before executing. 
$taskName = "VisionOneDemo"
$regkeyItem = "HKLM:\SOFTWARE\NodeSoftware"  # set to '' or $null if you don't have a property
$regkeyItemProperty = ""   # set to '' or $null if you don't have a property
$targetFolder ="c:\testvisionOne" # Folder to delete
$targetFile = "testfile.txt"      # File to delete, set to '' if you don't need to delete a file
$deleteFolder = $true  # set if the target folder is deleted $true or $false
$processName2Kill = "Notepad"
$compromisedUser = 'User02'
Write-host "Script: Remediate.ps1"

# Delete a schedule task
$taskExists = Get-ScheduledTask | Where-Object {$_.TaskName -like $taskName }
if ($taskExists) {
    Unregister-ScheduledTask -TaskPath "\*" -TaskName $taskName -Confirm:$false
    Write-host "Scheduled task deleted" $taskName
}
else {Write-host "Scheduled task" $taskName "does not exist" }   

# Delete registry entries
if ($regkeyItem){
    if ($regkeyItemProperty){
        If (Get-ItemProperty -Path $regkeyItem -Name $regkeyItemProperty -ErrorAction SilentlyContinue) {
            Remove-ItemProperty -Path $regkeyItem -Name $regkeyItemProperty -Force -Verbose
            Write-host "Deleted Registry Item Property" $regkeyItem $regkeyItemProperty
        }
        else {Write-host "Registry Item and Property does not exist" $regkeyItem $regkeyItemProperty}
    }
    else {
        if (Get-Item $regkeyItem -ErrorAction SilentlyContinue){
            Remove-Item -Path $regkeyItem -Force -Verbose
            Write-host "Deleted Registry Item " $regkeyItem 
        }
        else {Write-host "Registry Item does not exist" $regkeyItem}
    }    
}

# Deletes files and folder example
$targetFullPath = Join-Path $targetFolder $targetFile
if (Test-Path $targetFullPath) {
    Remove-Item $targetFullPath -Force
    Write-Host 'File deleted' $targetFullPath
}
else {Write-host "File does not exist" $targetFullPath}

if ($deleteFolder -And (Test-Path $targetFolder)) {
    Remove-Item $targetFolder -Force
    Write-Host 'Folder deleted' $targetFolder 
}
else {Write-host "Folder does not exist" $targetFolder}

# Kill all process based on a process name

if ($processName2Kill) {
    $p = Get-Process | Where-Object {$_.ProcessName -match $processName2Kill} 
    if ($p) {
        Write-Host 'Process killed: ' $p.Name
        Stop-Process -Name $p.Name -Force
    } 
    else {Write-host "Process does not exist" $processName2Kill}
}

# Disable or Remove a local account
if ($compromisedUser) {
    $userExists = Get-LocalUser | Where-Object {$_.Name -like $compromisedUser}
    if ($userExists) {
        #Disable-LocalUser -Name $compromisedUser
        Remove-LocalUser -Name $compromisedUser
        Write-Host "Local User removed : " $compromisedUser 
    }
    else {Write-host "Local user does not exist" $compromisedUser}
}