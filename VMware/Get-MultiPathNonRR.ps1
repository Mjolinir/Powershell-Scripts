$VSUHosts = Get-VMHost | Where { ($_.ConnectionState -eq "Connected") -or ($_.ConnectionState -eq "Maintenance")} | Select Name
Foreach ($vmhosts in $VSUHosts) {
	Get-VMhost $vmhosts | Get-ScsiLun -LunType disk | Where { $_.MultipathPolicy -notlike "RoundRobin" } | Select CanonicalName,MultipathPolicy
}

