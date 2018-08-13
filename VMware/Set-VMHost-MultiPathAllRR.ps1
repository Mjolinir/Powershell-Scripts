param(
   [Parameter(Mandatory=$false)]
   [ValidateNotNullOrEmpty()]
   [string] $vmHost
)

Get-VMHost $vmHost | Get-ScsiLun -LunType disk | Where {$_.MultipathPolicy -notlike "RoundRobin"} | Where {$_.CapacityGB -ge 100} | Set-Scsilun -MultiPathPolicy RoundRobin
