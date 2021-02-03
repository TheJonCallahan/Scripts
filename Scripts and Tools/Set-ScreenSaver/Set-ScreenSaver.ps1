$ErrorActionPreference= 'silentlycontinue'
 
$SSFile = "C:\WINDOWS\system32\scrnsave.scr"
 
New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name ScreenSaveActive -Value 1 -PropertyType String -Force
 
New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name ScreenSaverIsSecure -Value 0 -PropertyType String -Force
 
New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name ScreenSaveTimeOut -Value 900 -PropertyType String -Force
 
New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name SCRNSAVE.EXE -Value $SSFile -PropertyType String -Force
