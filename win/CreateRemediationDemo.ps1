# the goal of this script is to plant evidence used in the remediation demo
# Create scheduled task
$action = New-ScheduledTaskAction -Execute 'Notepad.exe' 
$trigger =  New-ScheduledTaskTrigger -Daily -At 9am
Register-ScheduledTask -User "system" -Action $action -Trigger $trigger -TaskName "VisionOneDemo" -Description "Vision One Demo scheduled task to be deleted"
# Create registry key and values
$regkeyItem = "HKLM:\SOFTWARE\NodeSoftware"  # set to '' or $null if you don't have a property
$regkeyItemProperty = "AppSecurity"  
New-Item -Path $regkeyItem 
New-ItemProperty -Path $regkeyItem -Name $regkeyItemProperty -Value "Test value here"  -PropertyType "String"
# create folder & file at once
New-Item c:\testvisionOne\testfile.txt -ItemType File -Force

# create process based that will be killed based on process name
$procDetails = Start-Process "Notepad.exe" -Passthru
$procDetails.id

# Add a local account to demo disable 
New-LocalUser -Name "User02" -Description "Description of this account." -NoPassword
