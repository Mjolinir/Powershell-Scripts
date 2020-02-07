# Connect to vCenter as local admin
Connect-VIServer vcsa01.valdosta.edu -User 'administrator@vsphere.local' -Password 'TOFEJ~?Rn#"_,XMyv%9e'
# Generate list of powered on VMhosts
$vmhosts=Get-VMhost | Where-Object {$_.powerstate -eq ‘PoweredOn’} | Select-Object -ExpandProperty Name
# Export server list to file
$vmhosts | Select-Object Name | export-csv ESXServersShutdown.csv -NoTypeInformation
# Put VMNHosts in maintenance mode
#Set-VMHost -State Maintenance -VMHost $vmhosts
# Execute graceful shutdown of ESXI Hosts
$vmhosts | ForEach-Object {Stop-VMHost -VMHost $_ -Server $_ -RunAsync}
