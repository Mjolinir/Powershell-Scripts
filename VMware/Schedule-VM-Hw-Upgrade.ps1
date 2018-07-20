foreach($vmlist in (Get-Content -Path vmliste.txt)){
	$vm = Get-VM -Name $vmlist
	$do = New-Object -TypeName VMware.Vim.VirtualMachineConfigSpec
	$do.ScheduledHardwareUpgradeInfo = New-Object -TypeName VMware.Vim.ScheduledHardwareUpgradeInfo
	$do.ScheduledHardwareUpgradeInfo.UpgradePolicy = “always”
	$do.ScheduledHardwareUpgradeInfo.VersionKey = “vmx-09”
	$vm.ExtensionData.ReconfigVM_Task($do)
}
