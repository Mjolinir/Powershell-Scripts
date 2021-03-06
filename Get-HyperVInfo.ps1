param(
	$server = "uismtmsvs1.uismt.edu" 
)

function Get-VirtualSystemManagementService 
{
	return Get-WmiObject -class "Msvm_VirtualSystemManagementService" -namespace "root\virtualization" -ComputerName $server -credential uismt\administrator
}

function Get-VirtualMachineSettingData([System.Management.ManagementObject]$vm)
{	
	$query = "ASSOCIATORS OF {" + $vm.__Path + "} WHERE resultClass = Msvm_VirtualSystemSettingData"
	return Get-WmiObject -query $query -namespace root\virtualization -ComputerName $server -credential uismt\administrator
}

function GetSummaryInfo([System.Management.ManagementObject]$vm)
{
	# http://msdn.microsoft.com/en-us/library/cc160706(VS.85).aspx
	$requestedProperties = 3,4,101,102,103,104,106,107
	$settings = Get-VirtualMachineSettingData($vm)
	$service = Get-VirtualSystemManagementService
	$summaryList = $service.GetSummaryInformation($settings.__PATH, $requestedProperties)
	foreach($summary in $summaryList.SummaryInformation)
	{
		return $summary
	}
}

$vms = Get-WmiObject -Class Msvm_ComputerSystem -Namespace "root\virtualization" -ComputerName $server -credential uismt\administrator
$vms = $vms | where-object{$_.caption -ne "Hosting Computer System"}
$records = @()
ForEach($vm in $vms)
{
	$summary = GetSummaryInfo($vm)
	$record = "" | `
	select @{name="VM Name"; expression={$vm.ElementName}},
			@{name="Notes"; expression={$summary.Notes}},
			@{name="Processors"; expression={$summary.NumberOfProcessors}},
			@{name="Processor Load"; expression={$summary.ProcessorLoad}},
			@{name="Processor Load History[Multi]"; expression={$summary.ProcessorLoadHistory}},
			@{name="Memory Usage"; expression={$summary.MemoryUsage}},
			@{name="Heartbeat"; expression={$summary.Heartbeat}},
			@{name="OS"; expression={$summary.GuestOperatingSystem}},
			@{name="Snapshots[Multi]"; expression={GetSnapshotNames $summary.Snapshots}}
	$records += $record
}
$records