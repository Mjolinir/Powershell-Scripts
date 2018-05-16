$vmName = $args[0]

if ($vmName -eq $null -or $vmName -eq "") {
	Write-Host -ForegroundColor "yellow" "Usage:  Set-VM-CBT-Off.ps1 [VM Name]"
exit
}

$vmtest = Get-vm $vmName | get-view
$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
$vmConfigSpec.changeTrackingEnabled = $false
$vmtest.reconfigVM($vmConfigSpec)