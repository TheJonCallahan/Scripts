# Graph Beta
Update-MSGraphEnvironment -SchemaVersion 'beta'

#Graph prod
Update-MSGraphEnvironment -SchemaVersion 'v1.0'

Get-Intune

Connect-AzureAD
Connect-MSGraph

# Configure the groups that will be managed
# Set $userGroupIDs equal to the groupIDs of the source groups that contain users (this variable supports multiple values)
# Set $deviceGroupID equal to the groupIDs of the source groups that contain users (only one group may be specified)

$userGroupIDs = "fedf1f28-b6d2-4fa7-b81c-63597e8f199b","f38c718e-34fd-4d8b-bc4f-24a478ef7ec0"
$deviceGroupID = "5892293f-6c3a-4430-9912-6788ca3113e2"

# Gather group DisplayName for $deviceGroupID

$deviceGroup = Get-AADGroup -groupId $deviceGroupID
$deviceGroupDisplayName = $deviceGroup.displayName

# Loop through each group specified in $userGroupIDs

foreach($userGroupID in $userGroupIDs){

    $aadGroup = Get-AADGroup -groupId $userGroupID
    $aadGroupDisplayName = $aadGroup.DisplayName

    Write-Output "==========================================================="
    Write-Output "[$([DateTime]::Now)] Starting group management - Devices for users found in '$aadGroupDisplayName' will be added to '$deviceGroupDisplayName'"

    $groupMembers = Get-AzureADGroupMember -ObjectId $userGroupID

    foreach($groupMember in $groupMembers){

        $groupMemberDisplayName = $groupMember.UserPrincipalName

        Write-Output "[$([DateTime]::Now)] + Gathering devices for $groupMemberDisplayName"

        $azureADUserOwnedDevices = Get-AzureADUserOwnedDevice -ObjectId $groupMember.ObjectId

        foreach($azureADUserOwnedDevice in $azureADUserOwnedDevices){
            
            $deviceDisplayName = $azureADUserOwnedDevice.DisplayName
            $deviceObjectID = $azureADUserOwnedDevice.ObjectID


            try{

                Add-AzureADGroupMember -ObjectId $deviceGroupID -RefObjectId $deviceObjectID

                Write-Output "[$([DateTime]::Now)] ++ Added device: $deviceDisplayName  "

            }
            catch{

                Write-Output "[$([DateTime]::Now)] ++ Not adding device: $deviceDisplayName"

            }

        }

    }

    Write-Output "[$([DateTime]::Now)] Ending group management for $aadGroupDisplayName"

}