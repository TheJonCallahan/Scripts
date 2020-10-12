# Get BIOS information from WMI
$Win32BIOS = Get-WmiObject -Namespace "root\cimv2" -Query "SELECT * FROM Win32_BIOS" -ErrorAction 'SilentlyContinue'
# Return value for Win32BIOS if found, otherwise exit with 1
if ($Win32BIOS -gt $null) {
	# Return value for SMBIOSBIOSVersion if found, otherwise exit with 1
	if ($Win32BIOS.SMBIOSBIOSVersion -gt $null) {
		# Write output of SMBIOSBIOSVersion
        Write-Output $Win32BIOS.SMBIOSBIOSVersion
		Exit 0
	} else {
		Write-Output "SMBIOSBIOSVersion not found"
		Exit 1
	}
} else {
	Write-Output "Could not query root\cimv2 WMI namespace"
	Exit 1
}