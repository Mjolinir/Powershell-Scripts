param(
   [Parameter(Mandatory=$true)]
   [ValidateNotNullOrEmpty()]
   [string] $vmName
)

$vmTest = Get-VM $vmName| Get-View
$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
$vmConfigSpec.changeTrackingEnabled = $true
$vmTest.reconfigVM($vmConfigSpec)

if ($?)
   { Write-Host "CBT enabled. You need to powercycle or perform a snapshot cycle for CBT to activate."
     exit 0 }
else
   { Write-Host "Enable CBT failed." 
     exit 1 }
