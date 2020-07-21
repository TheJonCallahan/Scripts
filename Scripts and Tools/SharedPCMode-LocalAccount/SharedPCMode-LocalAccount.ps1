$adminName = "LocalUser"
$adminPass = 'Pa$$word123'
iex "net user /add $adminName $adminPass"
$user = New-Object System.Security.Principal.NTAccount($adminName) 
$sid = $user.Translate([System.Security.Principal.SecurityIdentifier]) 
$sid = $sid.Value;
New-Item -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\DefaultUserName" -Value $adminName -Force
New-Item -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\DefaultPassword" -Value $adminPass -Force