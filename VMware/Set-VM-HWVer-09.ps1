$vmName = $args[0]

if ($vmName -eq $null -or $vmName -eq "") {
	Write-Host -ForegroundColor "yellow" "Usage:  Set-Min-VMHWver.ps1 [VM Name]"
exit
}

$spec = New-Object -TypeName VMware.Vim.VirtualMachineConfigSpec
$spec.ScheduledHardwareUpgradeInfo = New-Object -TypeName VMware.Vim.ScheduledHardwareUpgradeInfo
$spec.ScheduledHardwareUpgradeInfo.UpgradePolicy = "never"
$spec.ScheduledHardwareUpgradeInfo.VersionKey = 'vmx-09'

Get-VM -Name $vmName | %{
    $_.ExtensionData.ReconfigVM_Task($spec)
}