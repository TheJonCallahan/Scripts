$bdeProtect = Get-BitLockerVolume $env:SystemDrive

if ($bdeProtect.ProtectionStatus -eq "On") 
{

    $Compliance = "Compliant"
               
}
else
{

    $Compliance = "Non-Compliant"
			
}
			
$Compliance