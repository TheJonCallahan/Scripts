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
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
try
{
        $bdeProtect = Get-BitLockerVolume $env:SystemDrive

            if ($bdeProtect.KeyProtector.Count -lt 1) 
	       {
              # Enable Bitlocker using TPM
            Enable-BitLocker -MountPoint $env:SystemDrive  -TpmProtector -SkipHardwareTest -ErrorAction Continue
            Enable-BitLocker -MountPoint $env:SystemDrive  -RecoveryPasswordProtector -SkipHardwareTest

	       }      
			
                #Check if we can use BackupToAAD-BitLockerKeyProtector commandlet
			    $cmdName = "BackupToAAD-BitLockerKeyProtector"
                if (Get-Command $cmdName -ErrorAction SilentlyContinue)
				{
					#BackupToAAD-BitLockerKeyProtector commandlet exists
                    $BLV = Get-BitLockerVolume -MountPoint $env:SystemDrive | select *
					BackupToAAD-BitLockerKeyProtector -MountPoint $env:SystemDrive -KeyProtectorId $BLV.KeyProtector[1].KeyProtectorId
                }
			    else
                { 

		  		# BackupToAAD-BitLockerKeyProtector commandlet not available, using other mechanisme  
				# Get the AAD Machine Certificate
				$cert = dir Cert:\LocalMachine\My\ | where { $_.Issuer -match "CN=MS-Organization-Access" }

				# Obtain the AAD Device ID from the certificate
				$id = $cert.Subject.Replace("CN=","")

				# Get the tenant name from the registry
				$tenant = (Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\JoinInfo\$($id)).UserEmail.Split('@')[1]

				# Generate the body to send to AAD containing the recovery information
				# Get the BitLocker key information from WMI
					(Get-BitLockerVolume -MountPoint $env:SystemDrive).KeyProtector|?{$_.KeyProtectorType -eq 'RecoveryPassword'}|%{
					$key = $_
					write-verbose "kid : $($key.KeyProtectorId) key: $($key.RecoveryPassword)"
					$body = "{""key"":""$($key.RecoveryPassword)"",""kid"":""$($key.KeyProtectorId.replace('{','').Replace('}',''))"",""vol"":""OSV""}"
				
				# Create the URL to post the data to based on the tenant and device information
					$url = "https://enterpriseregistration.windows.net/manage/$tenant/device/$($id)?api-version=1.0"
				
				# Post the data to the URL and sign it with the AAD Machine Certificate
					$req = Invoke-WebRequest -Uri $url -Body $body -UseBasicParsing -Method Post -UseDefaultCredentials -Certificate $cert
					$req.RawContent
                }

			}

            $bdeProtect = Get-BitLockerVolume $env:SystemDrive

            if ($bdeProtect.VolumeStatus -eq "FullyEncrypted" -and $bdeProtect.ProtectionStatus -eq "Off") 
	        {

               # Resume BitLocker if suspended
               Resume-BitLocker -MountPoint $env:SystemDrive
	         } 
            
            #>
    
    } catch 
            {
            write-error "Error while setting up AAD Bitlocker, make sure that you are AAD joined and are running the cmdlet as an admin: $_"
            }
