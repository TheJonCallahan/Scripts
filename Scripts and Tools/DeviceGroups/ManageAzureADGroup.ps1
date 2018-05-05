Connect-AzureAd

Param(
  [string]$GroupNameSource,
  [string]$GroupNameDestination
)

#$GroupNameSource = "CC_All Users"
$GroupNameSource = Get-AzureADGroup -All $true | Where-Object {$_.DisplayName -eq $GroupNameSource}
$GroupNameSource = $GroupNameSource.ObjectId

#$GroupNameDestination= "Intune - Devices - Windows Update - Contact Center"
$GroupNameDestination = Get-AzureADGroup -All $true | Where-Object {$_.DisplayName -eq $GroupNameDestination}
$GroupNameDestination = $GroupNameDestination.ObjectId

$AADDeviceID = Get-AzureADGroup -objectid $GroupNameSource | Get-AzureADGroupMember -All $true |  Get-AzureADUserOwnedDevice -All $true | Where-Object {$_.DeviceOSType -eq "Windows"}

$AADDeviceIDs = $AADDeviceID.ObjectId

foreach($AADDeviceID in $AADDeviceIDs){

    $DeviceName = Get-AzureADDevice -ObjectId $AADDeviceID 

    Add-AzureADGroupMember -ObjectId $GroupNameDestination -RefObjectId $AADDeviceID -InformationAction SilentlyContinue

    Write-Host "Adding " $DeviceName.DisplayName
}