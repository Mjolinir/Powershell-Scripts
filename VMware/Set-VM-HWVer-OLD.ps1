$vmName = $args[0]
$hwVer = $args[1]

if ($vmName -eq $null -or $vmName -eq "") {
	Write-Host -ForegroundColor "yellow" "Usage:  Set-VMHWver.ps1 [VM Name] [HW Version]"
exit
}
if ($hwVer -eq $null -or $hwVer -eq "") {
	$hwVer = "v9"
}

Set-VM -VM $vmName -version $hwVer -Confirm:$false