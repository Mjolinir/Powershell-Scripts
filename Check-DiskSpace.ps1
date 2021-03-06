# Get server list
$servers = Get-Content "C:\Users\btrut2\Scripts\servers.txt";

foreach($server in $servers)
{
	# Get fixed drive info
    $erroractionpreference = "SilentlyContinue"
	$disks = Get-WmiObject -ComputerName $server -Class Win32_LogicalDisk -Filter "DriveType = 3";
	foreach($disk in $disks)
	{
		$deviceID = $disk.DeviceID;
		[float]$size = $disk.Size;
		[float]$freespace = $disk.FreeSpace;
		$percentFree = [Math]::Round(($freespace / $size) * 100, 2);
		$sizeGB = [Math]::Round($size / 1073741824, 2);
		$freeSpaceGB = [Math]::Round($freespace / 1073741824, 2);
		$colour = "Green";
		if($percentFree -lt $percentWarning)
		{
			$colour = "Red";
		}
		Write-Host -ForegroundColor $colour "$server $deviceID percentage free space = $percentFree";
		Add-Content "C:\Users\btrut2\Scripts\logs\server disks $datetime.txt" "$server,$deviceID,$sizeGB,$freeSpaceGB,$percentFree";
	}
}


