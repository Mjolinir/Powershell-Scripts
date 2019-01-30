$hostName = $args[0]

if ($hostName -eq $null -or $hostName -eq "") {
	Write-Host -ForegroundColor "yellow" "Usage:  Enable-HostSSH.ps1 [ESXi Hostame],[ESXi Hostame],[ESXi Hostame]"
exit
}

Get-VMHost $hostName | ForEach-Object {Start-VMHostService -HostService ($_ | Get-VMHostService | Where-Object {$_.Key -eq “TSM-SSH”})}