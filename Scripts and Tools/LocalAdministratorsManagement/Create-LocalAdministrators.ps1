# Get the AAD Machine Certificate
$cert = dir Cert:\LocalMachine\My\ | where { $_.Issuer -match "CN=MS-Organization-Access" }

# Obtain the AAD Device ID from the certificate
$id = $cert.Subject.Replace("CN=","")

# Get the user name from the registry
$username = (Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\JoinInfo\$($id)).UserEmail.Split('@')[0]

# Write values to registry

$registryPath = "HKLM:\SOFTWARE\Microsoft\DeviceOwner"
$domain = "CORP"

New-Item -Path $registryPath -Force | Out-Null

New-ItemProperty -Path $registryPath -Name "UserName" -Value $username -PropertyType String -Force | Out-Null

New-ItemProperty -Path $registryPath -Name "UserDomain" -Value $domain -PropertyType String -Force | Out-Null

New-ItemProperty -Path $registryPath -Name "AllowDeviceOwnerLocalAdministrator" -Value 1 -PropertyType DWord -Force | Out-Null

# Execute LocalAdministrators script

$command = “cmd /C cscript .\LocalAdministrators.vbs”
invoke-expression $command