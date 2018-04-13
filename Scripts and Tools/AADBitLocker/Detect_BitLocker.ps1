<#PSScriptInfo 
.VERSION 1.7
.GUID f5187e3f-ed0a-4ce1-b438-d8f421619ca3 
.ORIGINAL AUTHOR Jan Van Meirvenne 
.MODIFIED BY Sooraj Rajagopalan, Paul Huijbregts, Pieter Wigleven, and Jon Callahan
.COPYRIGHT 
.TAGS Azure Intune Bitlocker  
.LICENSEURI  
.PROJECTURI  
.ICONURI  
.EXTERNALMODULEDEPENDENCIES  
.REQUIREDSCRIPTS  
.EXTERNALSCRIPTDEPENDENCIES  
.RELEASENOTES  
#>

<# 
 
.DESCRIPTION 
 Check whether BitLocker is Enabled, if not Enable Bitlocker on AAD Joined devices and store recovery info in AAD 
#> 
[cmdletbinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string] $OSDrive = $env:SystemDrive
    )
try
{
 
            $bdeProtect = Get-BitLockerVolume $OSDrive

            if ($bdeProtect.ProtectionStatus -eq "Off") 
	        {

				$Compliance = "Compliant"
               
	         }
			else
			{
			 
				$Compliance = "Non-Compliant"
			
			}
			
$Compliance