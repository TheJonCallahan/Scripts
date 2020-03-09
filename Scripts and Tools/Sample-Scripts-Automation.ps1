#########################################################################################
#   MICROSOFT LEGAL STATEMENT FOR SAMPLE SCRIPTS/CODE
#########################################################################################
#   This Sample Code is provided for the purpose of illustration only and is not 
#   intended to be used in a production environment.
#
#   THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY 
#   OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED 
#   WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
#
#   We grant You a nonexclusive, royalty-free right to use and modify the Sample Code 
#   and to reproduce and distribute the object code form of the Sample Code, provided 
#   that You agree: 
#   (i)      to not use Our name, logo, or trademarks to market Your software product 
#            in which the Sample Code is embedded; 
#   (ii)     to include a valid copyright notice on Your software product in which 
#            the Sample Code is embedded; and 
#   (iii)    to indemnify, hold harmless, and defend Us and Our suppliers from and 
#            against any claims or lawsuits, including attorneys’ fees, that arise 
#            or result from the use or distribution of the Sample Code.
#########################################################################################

Connect-MSGraph
Connect-AzureAD

# update-msgraphenvironment -schema beta

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

Get-IntuneDeviceConfigurationPolicy -Filter "contains(displayName,'Win10 - test - Endpoint Protection')"


# Find all device configuration profiles assigned to a group
# Connect to Beta endpoint for MS Graph to ensure all policies are returned

Connect-MSGraph
Update-MSGraphEnvironment -SchemaVersion beta
Connect-MSGraph

$groupName = "Intune - Pilot Users"
$group = Get-AADGroup -Filter "displayname eq '$groupName'"

$deviceConfig = Get-IntuneDeviceConfigurationPolicy -Expand assignments | Where-Object {$_.assignments -match $group.id}

foreach($config in $deviceConfig)
{
 
    Write-host $config.displayName
 
}


# Find all mobile apps assigned to a group
# Connect to Beta endpoint for MS Graph to ensure all apps are returned

Connect-MSGraph
Update-MSGraphEnvironment -SchemaVersion beta
Connect-MSGraph

$groupName = "Intune - Pilot Users"
$group = Get-AADGroup -Filter "displayname eq '$groupName'"

$mobileApp = Get-IntuneMobileApp -Expand assignments | Where-Object {$_.assignments -match $group.id}

foreach($app in $mobileApp)
{
 
    Write-host $app.displayName
 
}