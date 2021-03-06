# Ask for stuff through read-host instead of params, because reasons
#$vCenterServer = Read-Host "What vCenter server should be connected to?"
#$location = Read-Host "What location (I.E. datacenter, folder, cluster, etc.) needs the fix?"

# Add PowerCLI Snapin if it is not currently added.
#If (!(Get-PSSnapin | Where {$_.Name -eq "VMware.VimAutomation.Core"})) {
#	Add-PSSnapin "VMware.VimAutomation.Core"; `
#	Write-Host Adding Snapin - "VMware.VimAutomation.Core"
#}

$vmLocation = $args[0]

if ($vmLocation -eq $null -or $vmLocation -eq "") {
	Write-Host -ForegroundColor "yellow" "Usage:  Disable-VM-Hw-Upgrade.ps1 [Location]"
exit
}

# Connect to vCenter
#Connect-VIServer $vCenterServer

# Create function to set UpgradePolicy to never
Function UpgradeHW($vm) {
	$spec = New-Object -TypeName VMware.Vim.VirtualMachineConfigSpec
	$spec.ScheduledHardwareUpgradeInfo = New-Object -TypeName VMware.Vim.ScheduledHardwareUpgradeInfo
	$spec.ScheduledHardwareUpgradeInfo.UpgradePolicy = "never"
	$vm.ExtensionData.ReconfigVM_Task($spec)
}
	
# Apply policy to all VMs in $location
UpgradeHW (Get-VM -Location $vmLocation | Where-Object {($_.ExtensionData.get_Config() | Select -expand ScheduledHardwareUpgradeInfo | Select -expand UpgradePolicy) -notmatch "never"})