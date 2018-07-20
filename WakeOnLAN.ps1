#wakeonlan $computer
function WakeOnLan($computer)
{
	$select=$select |where-object {$_.computername -eq $computer} |Select-Object mac
	if ($select.mac -eq $null)
	{
		echo "workstation not found.epic fail. use all to wake'em all"
	}
	else
	{
		$select.mac  -match "(..)(..)(..)(..)(..)(..)" | out-null
		$mac= [byte[]]($matches[1..6] |% {[int]"0x$_"})
		$UDPclient = new-Object System.Net.Sockets.UdpClient
		$UDPclient.Connect(([System.Net.IPAddress]::Broadcast),4000)
		$packet = [byte[]](,0xFF * 102)
		6..101 |% { $packet[$_] = $mac[($_%6)]}
		$UDPclient.Send($packet, $packet.Length)
		echo "workstation $computer is booting up..."
	}
}

#wakeonlan all the computers
function WakeOnLanAll
{
	$computers=$select | Select-Object computername
	foreach ($computer in $computers)
	{
		$target = $computer.computername
		WakeOnLan($target)
		#delay to be powergrid friendly
		Start-Sleep -seconds 5
	}
}
#shutdown $computer
function ShutDown($computer)
{
if ($computer.ToLower() -eq "all")
	{
	$select=$select|Select-Object computername
	foreach ($computername in $select)
		{
			$target=$computername.computername
			get-wmiobject win32_operatingsystem -computer $target | foreach {$_.shutdown()}
		}
	}
else {
		$select=$select |where-object {$_.computername -eq $computer} |Select-Object computername
		if ($select.computername -eq $null)
		{
			echo "workstation $computer not found.epic fail. use all to kill'em all"
		}
		else
		{
			get-wmiobject win32_operatingsystem -computer $computer | foreach {$_.Shutdown()}
		}
	}
}
####reboot $computer
function Reboot($computer)
{
#reboot all
if ($computer.ToLower() -eq "all")
	{
	$select=$select|Select-Object computername
	foreach ($computername in $select)
		{
			$target=$computername.computername
			get-wmiobject win32_operatingsystem -computer $target | foreach {$_.reboot()}
		}
	}
else {
	$select=$select |where-object {$_.computername -eq $computer} |Select-Object computername
	#check input
	if ($select.computername -eq $null)
	{
		echo "workstation $computer not found.epic fail. use all to kill'em all"
	}
	#reboot
	else
		{
			get-wmiobject win32_operatingsystem -computer $computer | foreach {$_.reboot()}
			#delay to be powergrid friendly
			Start-Sleep -seconds 5
		}
	}
}

###################
$option=read-host "Enter option"
$select=Import-Csv C:\Users\btrut2\Scripts\MachineList.csv
switch ($option)
{
	"wol" {
			$computer=read-host "Enter Workstation to wake..."
			if ($computer -eq "all")
			{
				WakeOnLanAll
			}
	else {
			WakeOnLan($computer)
			ping -4 -n 25 $computer
		}
	}
	"reboot" {
			$computer=read-host "Enter Workstation to reboot..."
			Reboot($computer)
	}
	"shutdown" {
			$computer=read-host "Enter Workstation to kill..."
			Shutdown($computer)
	}
	default {echo "error!options are : wol, reboot, shutdown"}
}