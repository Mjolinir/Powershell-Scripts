

Function hwstatus ([string]$server) {
	if ($server -eq $null) {
		write-host -foregroundcolor "yellow"  "Usage hwstatus servername"
		write-host -foregroundcolor "yellow"  "   Enter servername to get status of chassis"
		write-host
		exit
	}

	$server = $server

	$a = Get-WMIObject -Namespace root\CIMv2\Dell -computername $server -Class DELL_Chassis -erroraction silentlycontinue -errorvariable err

	if (-not($?)) {
		omsaerr
		exit
	}	

	if ($a -eq $null) {
		write-host -foregroundcolor "red" "Could not get chassis status on this machine"
		write-host
		exit
	} else {

		$b = $a |select-object Model,SerialNumber,Status,ProcStatus,PsStatus,TempStatus,VoltStatus,FanStatus
		$b
	}

}

function omsaerr {
    
	$exception = $error[0].Exception.ErrorCode
	if ($exception -eq "InvalidNamespace") {
		write-host "OMSA version not high enough to query machine"  -foregroundcolor "red"
		
	} elseif ($error[0].CategoryInfo.Reason -eq "UnauthorizedAccessException") {
		write-host "Access is Denied" -foregroundcolor "red"
	} elseif ($error[0].Exception.ErrorCode -eq -2147023174) {	
		write-host "Can't connect to RPC service on machine, if OS is windows, server might be down or behind a firewall. " -foregroundcolor "red"
	} else {
		write-host "OMSA connection failed" -foregroundcolor "red"
	
	}
		write-host
		$error.clear()
		
}


$server = $args[0]

if ($server -eq $null -or $server -eq "") {
Write-Host -ForegroundColor "yellow" "Usage:  GetDellServerStatus.ps1 [servername]"
exit
}


&hwstatus $server