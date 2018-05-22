
#foreach($vmName in (Get-Cluster "SysOps Cluster" | Get-VM)){
foreach($vmName in (Get-Folder Brian | Get-VM)){

$vm = Get-VM -Name $vmName
$do = New-Object -TypeName VMware.Vim.VirtualMachineConfigSpec
$do.ScheduledHardwareUpgradeInfo = New-Object -TypeName VMware.Vim.ScheduledHardwareUpgradeInfo
$do.ScheduledHardwareUpgradeInfo.UpgradePolicy = “always”
$do.ScheduledHardwareUpgradeInfo.VersionKey = “vmx-10”
$vm.ExtensionData.ReconfigVM_Task($do)
}
