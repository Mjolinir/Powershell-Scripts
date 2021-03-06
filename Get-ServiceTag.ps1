$server = $args[0]

if ($server -eq $null -or $server -eq "") {
	write-host -foregroundcolor "yellow"  "Usage: GetServiceTag [servername]"
	exit
}

write-host
$a = Get-WmiObject Win32_BIOS -computername $server -erroraction silentlycontinue -errorvariable err
if ($a -eq $null) { 
	write-host -foregroundcolor "red" "Server not found or can't connect, could not get tag number"
	Exit
} else {
	$a = $a | select-object SerialNumber
	$b = $a.serialnumber
	echo "Service tag for $server is $b"
	write-host
}