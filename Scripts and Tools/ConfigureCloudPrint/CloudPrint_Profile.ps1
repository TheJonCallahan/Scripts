##########################################################################
# Define Enterprise Cloud Print configuration
##########################################################################

$CloudPrinterDiscoveryEndpoint = "<CloudPrinterDiscoveryEndpoint>"
$CloudPrintOAuthAuthority = "<CloudPrintOAuthAuthority>"
$CloudPrintOAuthClientId = "<CloudPrintOAuthClientId>"
$CloudPrintResourceId = "http://MicrosoftEnterpriseCloudPrint/CloudPrint"
$DiscoveryMaxPrinterLimit = "100"
$MopriaDiscoveryResourceId = "http://MopriaDiscoveryService/CloudPrint"

$nodeCSPURI = './Vendor/MSFT/Policy/Config'
$Instance = 'EnterpriseCloudPrint'
$namespaceName = 'root\cimv2\mdm\dmmap'
$className = 'MDM_Policy_User_Config01_EnterpriseCloudPrint02'

##########################################################################
# Retrieve the active user
##########################################################################

try
{
$username = Gwmi -Class Win32_ComputerSystem | select username
$objuser = New-Object System.Security.Principal.NTAccount($username.username)
$sid = $objuser.Translate([System.Security.Principal.SecurityIdentifier])
$SidValue = $sid.Value
$Message = "User SID is $SidValue."
Write-Host "$Message"
}
catch [Exception]
{
$Message = "Unable to get user SID. User may be logged on over Remote Desktop: $_"
Write-Host "$Message"
exit
}

$session = New-CimSession
$options = New-Object Microsoft.Management.Infrastructure.Options.CimOperationOptions
$options.SetCustomOption('PolicyPlatformContext_PrincipalContext_Type', 'PolicyPlatform_UserContext', $false)
$options.SetCustomOption('PolicyPlatformContext_PrincipalContext_Id', "$SidValue", $false)

##########################################################################
# Delete any existing Enterprise Cloud Print profile
##########################################################################

$getInstance = $session.EnumerateInstances($namespaceName, $className, $options)

try
{
    $deleteInstances = $session.EnumerateInstances($namespaceName, $className, $options)
    foreach ($deleteInstance in $deleteInstances)
    {
        $InstanceId = $deleteInstance.InstanceID
        if ("$InstanceId" -eq "EnterpriseCloudPrint")
        {
            $session.DeleteInstance($namespaceName, $deleteInstance, $options)
            $Message = "Removed $InstanceId profile"
            Write-Host "$Message"
        } else {
            $Message = "Ignoring existing $InstanceId profile"
            Write-Host "$Message"
        }
    }
}
catch [Exception]
{
    $Message = "Unable to remove existing outdated instance of Enterprise Cloud Print profile"
    Write-Host "$Message"
    exit
}

##########################################################################
# Create the Enterprise Cloud Print profile
##########################################################################

try
{
    $newInstance = New-Object Microsoft.Management.Infrastructure.CimInstance $className, $namespaceName
    $property = [Microsoft.Management.Infrastructure.CimProperty]::Create("ParentID", "$nodeCSPURI", 'String', 'Key')
    $newInstance.CimInstanceProperties.Add($property)
    $property = [Microsoft.Management.Infrastructure.CimProperty]::Create("InstanceID", $Instance, 'String', 'Key')
    $newInstance.CimInstanceProperties.Add($property)
    $property = [Microsoft.Management.Infrastructure.CimProperty]::Create("CloudPrinterDiscoveryEndpoint", "$CloudPrinterDiscoveryEndpoint", 'String', 'Property')
    $newInstance.CimInstanceProperties.Add($property)
    $property = [Microsoft.Management.Infrastructure.CimProperty]::Create("CloudPrintOAuthAuthority", "$CloudPrintOAuthAuthority", 'String', 'Property')
    $newInstance.CimInstanceProperties.Add($property)
    $property = [Microsoft.Management.Infrastructure.CimProperty]::Create("CloudPrintOAuthClientId", "$CloudPrintOAuthClientId", 'String', 'Property')
    $newInstance.CimInstanceProperties.Add($property)
    $property = [Microsoft.Management.Infrastructure.CimProperty]::Create("CloudPrintResourceId", "$CloudPrintResourceId", 'String', 'Property')
    $newInstance.CimInstanceProperties.Add($property)
    $property = [Microsoft.Management.Infrastructure.CimProperty]::Create("DiscoveryMaxPrinterLimit", "$DiscoveryMaxPrinterLimit", 'sint32', 'Property')
    $newInstance.CimInstanceProperties.Add($property)
    $property = [Microsoft.Management.Infrastructure.CimProperty]::Create("MopriaDiscoveryResourceId", "$MopriaDiscoveryResourceId", 'String', 'Property')
    $newInstance.CimInstanceProperties.Add($property)
    $session.CreateInstance($namespaceName, $newInstance, $options)
    $Message = "Created $ProfileName profile."

    Write-Host "$Message"
}
catch [Exception]
{
    $Message = "Unable to create $ProfileName profile: $_"
    Write-Host "$Message"
    exit
}

$Message = "Script Complete"
Write-Host "$Message"
