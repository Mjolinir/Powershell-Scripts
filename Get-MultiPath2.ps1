# Description:  Offers to either check and log path selection policies not set to RoundRobin, OR, set and log these disk PSPs to RoundRobin
# Author: Sean Duffy
# Web/blog: http://www.shogan.co.uk
# Date: 25/05/2013
## IMPORTANT: Always test scripts in preproduction or your lab before using them live!!

#region UserDefined
# Setup the location of our log files...
# This should be the only custom bit you need to set (the location you want log files to be)
# This will only be used when changing path selection policies
$SetPSPlogfile = "C:\temp\SetPathSelectionPolicy_UpdateScript_Log.txt"
# This will only be used when seeing what path selection policies are in place that are not round robin
$GetPSPlogfile = "C:\temp\GetPathSelectionPolicy_UpdateScript_Log.txt"
#endregion

# Ask for connection details, then connect using these
$vcenter = Read-Host "Enter vCenter Name or IP"
$username = Read-Host "Enter your username"
$password = Read-Host "Enter your password"
$Connection = Connect-VIServer $vcenter -User $username -Password $password

# Grab all ESX hosts on the connection that are either connected, or connected and in maintenance mode
$AllESXHosts = Get-VMHost | Where { ($_.ConnectionState -eq "Connected") -or ($_.ConnectionState -eq "Maintenance")} | Sort Name

# Prompt user with two options - 1) List all disk devices where no roundrobin PSP is set, or 2) Change all disk devices to RoundRobin PSP
Clear
Write-Host "1) Log all disk devices on all hosts where RoundRobin not set." -ForegroundColor Yellow
Write-Host "2) Set and log all disk devices on all hosts where RoundRobin not set, to RoundRobin." -ForegroundColor Yellow
$MenuChoice = Read-Host "Enter your selection (1/2)"

# We could use a switch statement here too, but an if,elseif,else statement is fine in this case...
# Chose option 1
if ($MenuChoice -like "1") {
	# Log the username to our log file
	$User = $Connection.User
	Write "User logged in for reading of PSPs: $User" | Out-File $GetPSPlogfile -Append
	Write-Host "Paths not set to RoundRobin for each host will be logged to the $GetPSPlogfile"
	Foreach ($esxhost in $AllESXHosts) {
		# Write an entry into our log for the host we busy reading PSPs from
		$Now = Get-Date
		Write "$Now :: Getting paths on $esxhost where not set to RoundRobin" | Out-File $GetPSPlogfile -Append
		Write-Host "ESX Host: $esxhost :: Disk devices not set to RoundRobin" -ForegroundColor Cyan
		Get-VMhost $esxhost | Get-ScsiLun -LunType disk | Where { $_.MultipathPolicy -notlike "RoundRobin" } | Select CanonicalName,MultipathPolicy | Out-File $GetPSPlogfile -Append
	}
	Write "------------- End of this run -------------" | Out-File $GetPSPlogfile -Append
	Disconnect-VIServer * -Confirm:$false
}
# Chose option 2
elseif ($MenuChoice -like "2") {
	# Prompt user with a warning first and ask to confirm to continue as this is a change to policies...
	Write-Host "WARNING: You are about to loop through all ESX hosts found and change disks to a PSP of RoundRobin! 
	Are you sure you want to continue? (Y/N): " -ForegroundColor Yellow -NoNewline
	$Answer = Read-Host

	# If user answered y, or Y, then continue with the change...
	if ($Answer -like "y") {
		# Log the username to our log file
		$User = $Connection.User
		Write "User logged in for change: $User" | Out-File $SetPSPlogfile -Append
		# Loop through all ESX hosts
		Foreach ($esxhost in $AllESXHosts) {
			# Write an entry into our log for the host we are working on along with the current timestamp
			$Now = Get-Date
			Write "$Now :: Setting PSP for the following current devices on $esxhost to RoundRobin" | Out-File $SetPSPlogfile -Append
			Write-Host "ESX Host: $esxhost :: Now setting path selection policy for all disk devices that are not already set to RoundRobin, to RoundRobin" -ForegroundColor Cyan
			# Find all disk devices where they are not already set to Round Robin Path Selection Policy and log these to log file
			Get-VMHost $esxhost | Get-ScsiLun -LunType disk | Where { $_.MultipathPolicy -notlike "RoundRobin" } | Select CanonicalName,MultipathPolicy | Out-File $SetPSPlogfile -Append
			# Find all disk devices where they are not already set to Round Robin Path Selection Policy and set these to RoundRobin
			Get-VMhost $esxhost | Get-ScsiLun -LunType disk | Where { $_.MultipathPolicy -notlike "RoundRobin" } | Set-ScsiLun -MultipathPolicy "RoundRobin"
		}
		Write "------------- End of this run -------------" | Out-File $SetPSPlogfile -Append
		Disconnect-VIServer * -Confirm:$false
	}
	else {
		Disconnect-VIServer * -Confirm:$false
		Write-Host "Script aborted" -ForegroundColor White
	}
}
# Didn't enter a valid choice...
else {
	Disconnect-VIServer * -Confirm:$false
	Write-Host "Not a valid choice! Exiting script..."
}