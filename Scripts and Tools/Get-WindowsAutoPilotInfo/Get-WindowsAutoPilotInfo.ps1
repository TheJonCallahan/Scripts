<#PSScriptInfo

.VERSION 1.1

.GUID ebf446a3-3362-4774-83c0-b7299410b63f

.AUTHOR Michael Niehaus

.COMPANYNAME Microsoft

.COPYRIGHT 

.TAGS Windows AutoPilot

.LICENSEURI 

.PROJECTURI 

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES
Version 1.0:  Original published version.
Version 1.1:  Added -Append switch.

#>

<#
.SYNOPSIS
Retrieves the Windows AutoPilot deployment details from one or more computers
.DESCRIPTION
This script uses WMI to retrieve properties needed by the Microsoft Store for Business to support Windows AutoPilot deployment.
.PARAMETER Name
The names of the computers.  These can be provided via the pipeline (property name Name or one of the available aliases, DNSHostName, ComputerName, and Computer).
.PARAMETER OutputFile
The name of the CSV file to be created with the details for the computers.  If not specified, the details will be returned to the PowerShell
pipeline.
.PARAMETER Append
Switch to specify that new computer details should be appended to the specified output file, instead of overwriting the existing file.
.EXAMPLE
.\Get-WindowsAutoPilotInfo.ps1 -ComputerName MYCOMPUTER -OutputFile .\MyComputer.csv
.EXAMPLE
.\Get-WindowsAutoPilotInfo.ps1 -ComputerName MYCOMPUTER -OutputFile .\MyComputer.csv -Append
.EXAMPLE
.\Get-WindowsAutoPilotInfo.ps1 -ComputerName MYCOMPUTER1,MYCOMPUTER2 -OutputFile .\MyComputers.csv
.EXAMPLE
Get-ADComputer -Filter * | .\GetWindowsAutoPilotInfo.ps1 -OutputFile .\MyComputers.csv
.EXAMPLE
Get-CMCollectionMember -CollectionName "All Systems" | .\GetWindowsAutoPilotInfo.ps1 -OutputFile .\MyComputers.csv

#>

[CmdletBinding()]
param(
	[Parameter(Mandatory=$False,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True,Position=0)][alias("DNSHostName","ComputerName","Computer")] [String[]] $Name = @($env:ComputerName),
	[Parameter(Mandatory=$False)] [String] $OutputFile = "", 
	[Parameter(Mandatory=$False)] [Switch] $Append = $False
)

Begin
{
	# Initialize empty list
	$computers = @()
}

Process
{
	foreach ($comp in $Name)
	{
		# Get the properties.  At least serial number and hash are needed.
		Write-Verbose "Checking $comp"
		$serial = (Get-WmiObject -ComputerName $comp -class Win32_BIOS).SerialNumber
		$licenseProduct = (Get-WmiObject -ComputerName $comp -class SoftwareLicensingProduct -Filter "ProductKeyChannel!=NULL and LicenseDependsOn=NULL AND ApplicationID='55c92734-d682-4d71-983e-d6ec3f16059f'")
		if ($licenseProduct)
		{
			$product = $licenseProduct.ProductKeyID2.Substring(0,17).Replace("-","").TrimStart("0")
		}
		else
		{
			$product = ""
		}
		$devDetail = (Get-WMIObject -ComputerName $comp -Namespace root/cimv2/mdm/dmmap -class MDM_DevDetail_Ext01 -filter "InstanceID='Ext' AND ParentID='./DevDetail'")
		if ($devDetail)
		{
			$hash = $devDetail.DeviceHardwareData

			# Create a pipeline object
			$c = New-Object psobject -Property @{
				"Device Serial Number" = $serial
				"Windows Product ID" = $product
				"Hardware Hash" = $hash
			}

			# Write the object to the pipeline or array
			if ($OutputFile -eq "")
			{
				$c
			}
			else
			{
				$computers += $c
			}
		}
		else
		{
			# Report an error when the hash isn't available
			Write-Error -Message "Unable to retrieve device hardware data (hash) from computer $comp" -Category DeviceError
		}

	}
}

End
{
	if ($OutputFile -ne "")
	{
		if ($Append)
		{
			if (Test-Path $OutputFile)
			{
				$computers += Import-CSV -Path $OutputFile
			}
		}
		$computers | Select "Device Serial Number", "Windows Product ID", "Hardware Hash" | ConvertTo-CSV -NoTypeInformation | % {$_ -replace '"',''} | Out-File $OutputFile
	}
}
