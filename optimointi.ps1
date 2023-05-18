$programName = "PUBG: BATTLEGROUNDS"

#Etsitään polku pubgi asennukseen
$program = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" |
           Where-Object { $_.DisplayName -eq $programName } |
           Select-Object -First 1

if ($program) {
    $installationLocation = $program.InstallLocation
    Write-Host "Program Name: $($program.DisplayName)"
    Write-Host "Installation Location: $installationLocation"
} else {
    Write-Host "Pubgi ei asennettu koneelle"
	Pause
	Exit
	
}

#Poistetaan leffat
$movieLocation = "\TslGame\Content\Movies"
$atozPClocation = "\TslGame\Content\Movies\AtoZ\PC"
$atozSTADIAlocation = "\TslGame\Content\Movies\AtoZ\STADIA"
$atozXBOXlocation = "\TslGame\Content\Movies\AtoZ\XBOX_PS"
$folderPath = "{0}{1}" -f $installationLocation, $movieLocation
$keepPathPC = "{0}{1}" -f $installationLocation, $atozPClocation
$keepPathSTADIA = "{0}{1}" -f $installationLocation, $atozSTADIAlocation
$keepPathXBOX = "{0}{1}" -f $installationLocation, $atozXBOXlocation

# Write-Host "Poistetaan leffat sijainnista: $folderPath"

# Get-ChildItem -Path $folderPath -File -Recurse | Remove-Item -Force

# $folders = Get-ChildItem -Path $folderPath -Directory -Recurse | Select-Object -ExpandProperty FullName

# foreach ($folder in $folders) {
    # Get-ChildItem -Path $folder -File | Remove-Item -Force
# }


$excludedFolders = @(
    $keepPathPC,
    $keepPathSTADIA,
	$keepPathXBOX
    # Add additional excluded folder paths as needed
)

# Delete files in the folder and subfolders, excluding specific folders
Get-ChildItem -Path $folderPath -File -Recurse | Where-Object { $excludedFolders -notcontains $_.Directory.FullName } | Remove-Item -Force

# Delete files in the main folder, excluding specific folders
Get-ChildItem -Path $folderPath -File | Where-Object { $excludedFolders -notcontains $_.Directory.FullName } | Remove-Item -Force

#Gameusersettings hommat
#Etsitään appdata polku TSLGAME kansioon
$folderName = "TslGame"
$appDataFolderPath = Join-Path $env:LOCALAPPDATA $folderName
Write-Host "Path to $folderName folder in AppData: $appDataFolderPath"

#Lisätään polkuun gameusersettings.ini tiedoston sijainti turvaan kopiointia varten
$gameusersettingslisapolku = "\Saved\Config\WindowsNoEditor\GameUserSettings.ini"

#Yhdistetään polut ja kopioidaan tiedosto turvaan
$sourceFilePath = "{0}{1}" -f $appDataFolderPath, $gameusersettingslisapolku
Copy-Item -Path $sourceFilePath -Destination $appDataFolderPath

$appDataPoistettavat = "{0}{1}" -f $appDataFolderPath, "\Saved"

#Deletoidaan kansion sisältö
Get-ChildItem -Path $appDataPoistettavat -File -Recurse | Remove-Item -Force

$poistettavatKansiot = Get-ChildItem -Path $appDataPoistettavat -Directory -Recurse | Select-Object -ExpandProperty FullName

foreach ($kansio in $poistettavatKansiot) {
    Get-ChildItem -Path $kansio -File | Remove-Item -Force
}

#Kopioidaan gameusersettings.ini takaisin paikoilleen
$gameusersettingsalkup = "{0}{1}" -f $appDataFolderPath, "\Saved\Config\WindowsNoEditor\"
$gameusersettingsbackup = "{0}{1}" -f $appDataFolderPath, "\GameUserSettings.ini"
Copy-Item -Path $gameusersettingsbackup -Destination $gameusersettingsalkup
Pause

$keywords = "ScreenScale"
$keywords = "ScreenScale", "InGameFrameRateLimitType", "InGameCustomFrameRateLimit",`
"MasterSoundVolume", "EffectSoundVolume", "EmoteSoundVolume", "UISoundVolume",`
"BGMSoundVolume", "PlaygroundBGMSoundVolume",`
"PlaygroundWebSoundVolume", "FpsCameraFov", "Gamma" 
$excludedKeyword = "TslPersistant"

Get-Content -Path $gameusersettingsbackup |
    Select-String -Pattern $keywords |
    Where-Object { $_ -notmatch $excludedKeyword }


Pause