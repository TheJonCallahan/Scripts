$adminName = "LocalUser"
$adminPass = 'Pa$$word123!'
Invoke-Expression -Command "net user /add $adminName $adminPass"
$user = New-Object System.Security.Principal.NTAccount($adminName) 
$sid = $user.Translate([System.Security.Principal.SecurityIdentifier]) 
$sid = $sid.Value;
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"  
Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String  
Set-ItemProperty $RegPath "DefaultUsername" -Value "$adminName" -type String
Set-ItemProperty $RegPath "DefaultPassword" -Value "$adminPass" -type String