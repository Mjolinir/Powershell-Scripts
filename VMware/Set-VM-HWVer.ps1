$vmName = $args[0]

if ($vmName -eq $null -or $vmname -eq "") {
	Write-Host -ForegroundColor "yellow" "Usage:  Set-VMHWver.ps1 [VM Name]"
exit
}

$vm = Get-VM -Name $vmName
$do = New-Object -TypeName VMware.Vim.VirtualMachineConfigSpec
$do.ScheduledHardwareUpgradeInfo = New-Object -TypeName VMware.Vim.ScheduledHardwareUpgradeInfo
$do.ScheduledHardwareUpgradeInfo.UpgradePolicy = “always”
$do.ScheduledHardwareUpgradeInfo.VersionKey = “vmx-10”
$vm.ExtensionData.ReconfigVM_Task($do)