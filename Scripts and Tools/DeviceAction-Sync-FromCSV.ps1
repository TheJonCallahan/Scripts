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

# Check if Microsoft.Graph.Intune module is installed
$GraphIntuneModule = Get-Module -Name "Microsoft.Graph.Intune" -ListAvailable
 if($GraphIntuneModule.count -eq 0){

        Write-Host "Microsoft.Graph.Intune  not found" -ForegroundColor Red
        Write-Host "Install by running the command 'Install-Module Microsoft.Graph.Intune' in an elevated PowerShell prompt" -f Yellow
        Write-Host "Instructions at https://github.com/microsoft/Intune-PowerShell-SDK" -f Yellow
        exit
    }

# Connect to MS Graph API

Connect-MSGraph

# Location of CSV file
# Serial numbers must be in column named SerialNumber
$devices = Import-Csv "C:\temp\DevicesList.csv"

# Perform device action on devices in CSV
foreach($device in $devices){

    $deviceObject = Get-IntuneManagedDevice -Filter "contains(serialNumber,'$($device.SerialNumber)')"
    
    if($deviceObject.count -eq 0){

        Write-Host "No object found for $($device.SerialNumber)"
        Write-Host ""

    }else{

        Write-Host "Object found for $($device.SerialNumber)"
        $deviceObject | Format-Table -Property deviceName, serialNumber, lastSyncDateTime
        Write-Host "Device action will be done on this device"
        $deviceObject | Invoke-IntuneManagedDeviceSyncDevice
        Write-Host ""

    }

}