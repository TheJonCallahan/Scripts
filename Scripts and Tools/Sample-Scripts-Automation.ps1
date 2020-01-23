Connect-MSGraph
Connect-AzureAD

# List all Intune cmdlets

Get-Command -Module Microsoft.Graph.Intune

# List all Azure AD cmdlets

Get-Command -Module AzureAD

# Get a device and sync a device by name

Get-IntuneManagedDevice -Filter "contains(deviceName,'DESKTOP-7BHCHAI')" | Invoke-IntuneManagedDeviceSyncDevice

# Get a device and sync a device by serial number

Get-IntuneManagedDevice -Filter "contains(serialNumber,'MMPWP84UIF8G')" | Invoke-IntuneManagedDeviceSyncDevice

# Get a device by name prefix

Get-IntuneManagedDevice -Filter "startswith(deviceName,'Test')" | Format-Table -Property deviceName, emailAddress

# Get a device enrolled by user

Get-IntuneManagedDevice -Filter "startswith(emailAddress,'testuser01@contoso.onmicrosoft.com')" | Format-Table -Property deviceName, emailAddress

# Get a device and lock it

Get-IntuneManagedDevice -Filter "contains(deviceName,'Test’s iPad')" | Invoke-IntuneManagedDeviceRemoteLock

# Add a device to a group and then sync that device

$DeviceName = "DESKTOP-7BHCHAI"
$GroupName = "_Test-Group-Automation"

$Group = Get-AzureADGroup -All $true | Where-Object {$_.DisplayName -eq $GroupName}
$AzureADGroupID = $Group.ObjectId

$Devices = Get-AzureADDevice -All $true | Where-Object {$_.DisplayName -eq $DeviceName}

Foreach ($Device in $Devices)
{
    $AzureADObjectID = $Device.ObjectId
    $AzureADDeviceID = $Device.DeviceId

    try{

        Add-AzureADGroupMember -ObjectId $AzureADGroupID -RefObjectId $AzureADObjectID
        Write-Host "Adding $($Device.DisplayName) to $($GroupName)" -ForegroundColor Yellow
    
    } catch{

        Write-Host "Not adding $($Device.DisplayName) to $($GroupName). Likely already a member" -ForegroundColor Yellow

    }

    
    $IntuneDevice = Get-IntuneManagedDevice -Filter "contains(azureADDeviceId,'$AzureADDeviceID')"

    Invoke-IntuneManagedDeviceSyncDevice -managedDeviceId $IntuneDevice.managedDeviceId
    Write-Host "Syncing $($Device.DisplayName)" -ForegroundColor Yellow

}

# Sync a group of device

$GroupName = "_Test-Group-Automation"

$Group = Get-AzureADGroup -All $true | Where-Object {$_.DisplayName -eq $GroupName}

$GroupMembers = Get-AzureADGroupMember -ObjectId $Group.ObjectId

Foreach ($GroupMember in $GroupMembers)
{

    $AzureADDeviceID = $GroupMember.DeviceId

    $IntuneDevice = Get-IntuneManagedDevice -Filter "contains(azureADDeviceId,'$AzureADDeviceID')"

    Invoke-IntuneManagedDeviceSyncDevice -managedDeviceId $IntuneDevice.managedDeviceId
    Write-Host "Syncing $($GroupMember.DisplayName)" -ForegroundColor Yellow

}

# Copy an Intune device configuration policy

Get-IntuneDeviceConfigurationPolicy -Filter "contains(displayName,'_iOS - Device Restrictions')" | New-IntuneDeviceConfigurationPolicy -displayName "_iOS - Device Restrictions (copy)"

# Update an existing device configuration policy

Get-IntuneDeviceConfigurationPolicy -Filter "contains(displayName,'_iOS - Device Restrictions')" | Update-IntuneDeviceConfigurationPolicy -cameraBlocked 0
