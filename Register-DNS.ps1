# Get server list
$servers = Get-Content "C:\Users\btrut2\Scripts\servers.txt";

foreach($server in $servers)
{
	Invoke-Command -ComputerName $server -ScriptBlock { ipconfig /registerdns }
}


