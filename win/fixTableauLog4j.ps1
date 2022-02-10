# Trend Micro Vision One script to disable vulnerability in Tableau Desktop
# This script is not supported, it is a demo only. Make your own test 
# TODO : check Tableau version numbers and only run on affected versions. these are not affected : 2021.4.2+, 2021.3.6+, 2021.2.7+, 2021.1.10+, 2020.4.13+ 
# Note: TMV1 Custom scripting run as administrator. But if you wish to run this script manually, make sure you are administrator
# Reference : https://kb.tableau.com/articles/issue/apache-log4j2-vulnerability-log4shell-tableau-desktop-mitigation-steps
Write-Host "Trend Micro Vision One script to disable vulnerability in Tableau Desktop"
Write-Host "#1 Downloading 7z.exe"
$toolfolder = "c:\7zip"
$zip = "7z.exe"
$7zFullPath = Join-Path $toolfolder $zip
New-Item $toolfolder -ItemType Directory -Force
Invoke-WebRequest -Uri "https://github.com/girdav01/CustomScripts/raw/main/win/7z.exe" -OutFile $7zFullPath
Start-Sleep -Seconds 2  # sleep to make sure the file is writen
# Searching for Tableau folders, there might be more than one
$rootFolder = "C:\Program Files\Tableau" #Tableau root install folder
$NameToFind = "Tableau Public 20*" #folder name for the different versions

# check if Tableau folder is there
if ( -not (Test-Path -path $rootFolder)) {
    Write-Host $rootFolder "directory does not exist"
    Write-Host "There was no Tableau installed on this computer"
    Exit
} else {
    Write-Host $rootFolder "exist, we are fine"
}

Set-Location \
Write-Host Get-Location
Write-Host "#2 Get Tableau install folders"
$subfolderslist = (Get-ChildItem $rootFolder -recurse | Where-Object {$_.PSIsContainer -eq $True -and $_.Name -like $NameToFind} | Sort-Object)
foreach ($curfolder in $subfolderslist)
{
    Write-Host 'Folder Name ' $curfolder.FullName.ToString()
    $loc = $curFolder.FullName + "\bin"
    if ( -not (Test-Path -path $loc)) {
        Write-Host $loc "directory does not exist"
        continue
    } else {
        Write-Host "#3 Change directory to your Tableau Desktop bin directory"
        Set-Location $loc
        $curDir = Get-Location
        Write-Host "Current Working Directory: $curDir"
        Write-Host "# 4 Disable ReadOnly on jdbcserver.jar"
        Set-ItemProperty jdbcserver.jar -Name IsReadOnly -Value $false
        Write-Host "# 5 Disable ReadOnly on oauthservice.jar"
        Set-ItemProperty oauthservice.jar -Name IsReadOnly -Value $false
        Write-Host "# 6. Remove the JndiLookup.class from jdbcserver"
        c:\7zip\7z.exe d jdbcserver.jar org/apache/logging/log4j/core/lookup/JndiLookup.class -r
        Write-Host "#7. Remove the JndiLookup.class from oauthservice"
        c:\7zip\7z.exe d oauthservice.jar org/apache/logging/log4j/core/lookup/JndiLookup.class -r
        Write-Host "#8. Re-enable ReadOnly on jdbcserver.jar"
        Set-ItemProperty jdbcserver.jar -Name IsReadOnly -Value $true
        Write-Host "#9. Re-enable ReadOnly on oauthservice.jar"
        Set-ItemProperty oauthservice.jar -Name IsReadOnly -Value $true
        Write-Host "#10. Change directory to your Tableau Desktop bin32 directory. By default C:\Program Files\Tableau\Tableau <version>\bin32"
        $newloc = $curFolder.FullName + "\bin32"
        Set-Location $newloc
        Write-Host "#11. Disable ReadOnly on jdbcserver.jar"
        Set-ItemProperty jdbcserver.jar -Name IsReadOnly -Value $false
        Write-Host "#12. Disable ReadOnly on oauthservice.jar"
        Set-ItemProperty oauthservice.jar -Name IsReadOnly -Value $false
        Write-Host "#13. Remove the JndiLookup.class from jdbcserver"
        c:\7zip\7z.exe d jdbcserver.jar org/apache/logging/log4j/core/lookup/JndiLookup.class -r
        Write-Host "#14. Remove the JndiLookup.class from oauthservice"
        c:\7zip\7z.exe d oauthservice.jar org/apache/logging/log4j/core/lookup/JndiLookup.class -r
        Write-Host "#15. Re-enable ReadOnly on jdbcserver.jar"
        Set-ItemProperty jdbcserver.jar -Name IsReadOnly -Value $true
        Write-Host "#16. Re-enable ReadOnly on oauthservice.jar"
        Set-ItemProperty oauthservice.jar -Name IsReadOnly -Value $true
        Write-Host $curFolder.Name.ToString() "secured !!!!!!!!!!!"
    }
      
}
# cleanup downloaded tools
if (Test-Path $toolfolder) {
    Remove-Item $toolfolder -Force
    Write-Host 'Delete downloaded tools folder' $toolfolder 
}
else {Write-host "Folder does not exist" $toolfolder}
Write-Host "Script endded normally"


