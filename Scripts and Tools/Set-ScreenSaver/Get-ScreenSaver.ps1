$ErrorActionPreference= 'silentlycontinue'
 
$SSFile = "C:\WINDOWS\system32\scrnsave.scr"
$SSItem = Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name SCRNSAVE.EXE

if($SSItem.'SCRNSAVE.EXE' -eq $SSFile){
    Return $SSItem.'SCRNSAVE.EXE'
    Exit 0
} else{
    exit 1
}