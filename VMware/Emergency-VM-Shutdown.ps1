# Connect to vCenter as local admin
Connect-VIServer vcsa01.valdosta.edu -User 'administrator@vsphere.local' -Password 'TOFEJ~?Rn#"_,XMyv%9e'
# Generate list of powered on VMs excluding vCenter
$vmservers=Get-VM | Where-Object { $_.Name -ne 'vcsa01' -And $_.powerstate -eq ‘PoweredOn’} 
# Export server list to file
$vmservers | Select-Object Name | export-csv ServersShutdown.csv -NoTypeInformation
# Execute graceful shutdown
$vmservers| Shutdown-VMGuest


#Enable ssh on all ESXi hosts
Get-VMHost | ForEach-Object {Start-VMHostService -HostService ($_ | Get-VMHostService | Where-Object {$_.Key -eq “TSM-SSH”})}
