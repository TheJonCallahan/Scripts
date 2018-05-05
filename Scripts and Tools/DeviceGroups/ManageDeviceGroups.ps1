##################################################

# Script to add devices to an Azure AD group

##################################################

# Define script Parameters

param (
    [Parameter(Mandatory=$true,HelpMessage="Adding a User or Group? ...")][ValidateSet('User','Group')][string]$Type,
    [Parameter(Mandatory=$true)][string]$Source,
    [Parameter(Mandatory=$true)][string]$Destination,
    [Parameter(Mandatory=$true)][string]$DeviceOSType
 )

# Load Azure AD module and connect to Azure AD

if (Get-Module -ListAvailable -Name AzureAD) {
    if (!(Get-Module "AzureAD")) {
        Write-Information "AzureAD Module is Installed but not loaded. Importing the module...."
        Import-Module AzureAD
    }
} 
else 
{
    Write-Information "AzureAD Module is not Installed. Installing and Importing the AzureAD module..."
    Install-Module -Name AzureAD
    Import-Module AzureAD
}

# Check if there is an active Azure AD session

try{

    $validate = Get-AzureADTenantDetail

} catch{

    $cred = Connect-AzureAD

}

# Set ObjectNameSource for either User or Group.
# ObjectNameSource is used to retrieve device objects for the user
# Validate that the Source group exists in Azure AD

If($Type -eq "Group"){

    try{

        $ObjectNameSource = Get-AzureADGroup -All $true | Where-Object {$_.DisplayName -eq $Source}
        $ObjectNameSource = $ObjectNameSource.ObjectId

        $ObjectNameSource = Get-AzureADGroup -objectid $ObjectNameSource | Get-AzureADGroupMember -All $true

        $Message = "Found source group $Source"
        Write-Host $Message

    } catch{

        $Message = "Unable to find source group $Source"
        Write-Host $Message
        Exit

    }

}

If($Type -eq "User"){

    $ObjectNameSource = Get-AzureADUser -Filter "userPrincipalName eq '$Source'"
    $ObjectNameSource = $ObjectNameSource.ObjectId

    If($ObjectNameSource -ne $null){

        $Message = "Found user $Source"
        Write-Host $Message

    } else{

        $Message = "Unable to user $Source"
        Write-Host $Message
        Exit
    }

}

# Validate and retrieve info for the destination group

$GroupNameDestination = $Destination
$GroupNameDestination = Get-AzureADGroup -All $true | Where-Object {$_.DisplayName -eq $GroupNameDestination}
$GroupNameDestination = $GroupNameDestination.ObjectId

If($GroupNameDestination -ne $null){

$Message = "Found destination group $Destination"
Write-Host $Message

} else{

    $Message = "Unable to find destination group $Destination"
    Write-Host $Message
    Exit
}

$Message = "Gathering all $DeviceOSType devices from $Source.."
Write-Host $Message

# Gather the devices for the user loaded to ObjectNameSource
# Filter by device type (ex: Windows, iPhone, Android) or use -DeviceOSType "All" to retrieve all device OS types

if($DeviceOSType -ne "All"){

    $AADDeviceID =  $ObjectNameSource |  Get-AzureADUserOwnedDevice -All $true | Where-Object {$_.DeviceOSType -eq $DeviceOSType}

} else {
    
    $AADDeviceID =  $ObjectNameSource |  Get-AzureADUserOwnedDevice -All $true

}

$AADDeviceIDs = $AADDeviceID.ObjectId

# Add each retrieved device to the destinaton group

foreach($AADDeviceID in $AADDeviceIDs){

    try{
        $DeviceName = Get-AzureADDevice -ObjectId $AADDeviceID
        $DeviceNameDisplayName = $DeviceName.DisplayName

        Add-AzureADGroupMember -ObjectId $GroupNameDestination -RefObjectId $AADDeviceID

        $Message = " - Added $DeviceNameDisplayName to $Destination"
        Write-Host $Message

    } catch{

        $Message = " - Not adding $DeviceNameDisplayName to $Destination"
        Write-Host $Message

    }
          
}

$Message = "Script complete"
Write-Host $Message