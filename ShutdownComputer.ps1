$computer = $args[0]
$type = $args[1]
$cred = $args[2]

function Shutdown-Computer {
<#
	.Synopsis
		Will shutdown, Log Off or Reboot a remote or a local computer
	.Description
		Will shutdown, Log Off or Reboot a remote or a local computer.
		Force will shutdown open programs etc.
	.Example
		Shutdown-Computer mycomputer 'Log Off'
	Will Log Off the computer mycomputer
	.Example
		Shutdown-Computer mycomputer 'Shutdown'
	Will Shutdown the computer mycomputer
	.Example
		Shutdown-Computer mycomputer 'Reboot'
	Will Reboot the computer mycomputer
	.Example
		Shutdown-Computer mycomputer 'Power Off'
	Will Power Off the computer mycomputer	
	.Example
		Shutdown-Computer mycomputer 'Log Off' other
	Will Log Off the computer mycomputer with other credentials
	.Notes
	 NAME:      Shutdown-Computer
	 AUTHOR:    Fredrik Wall, fredrik@poweradmin.se
     MODIFIED:  Brian Truter
	 BLOG:		poweradmin.se/blog
	 LASTEDIT:  05/21/2010
#>

param ($computer, $type, $cred)
	switch ($type) {
	'Log Off' {$ShutdownType = "0"}
	'Shutdown' {$ShutdownType = "1"}
	'Reboot' {$ShutdownType = "2"}
	'Forced Log Off' {$ShutdownType = "4"}
	'Forced Shutdown' {$ShutdownType = "5"}
	'Forced Reboot' {$ShutdownType = "6"}
	'Power Off' {$ShutdownType = "8"}
	'Forced Power Off' {$ShutdownType = "12"}
	}
	
	$Error.Clear()
	if ($cred -eq $null) {
		trap { continue }
		(Get-WmiObject win32_operatingsystem -ComputerName $computer -ErrorAction SilentlyContinue).Win32Shutdown($ShutdownType)
	}
	
	if ($cred -eq "other") {
		trap { continue }
		(Get-WmiObject win32_operatingsystem -ComputerName $computer -ErrorAction SilentlyContinue -Credential (get-Credential)).Win32Shutdown($ShutdownType)
	}
}


if ($computer -eq $null -or $computer -eq "" -or $type -eq $null -or $type -eq "") {
Write-Host -ForegroundColor "yellow" "Usage:  ShutdownComputer.ps1 [computername] [type] (credentials)"
Write-Host ""
Write-Host -ForegroundColor "yellow" "Type can be: 'Log Off'"
Write-Host -ForegroundColor "yellow" "             'Shutdown'"
Write-Host -ForegroundColor "yellow" "             'Reboot'"
Write-Host -ForegroundColor "yellow" "             'Forced Log Off'"
Write-Host -ForegroundColor "yellow" "             'Forced Reboot'"
Write-Host -ForegroundColor "yellow" "             'Power Off'"
Write-Host -ForegroundColor "yellow" "             'Forced Power Off'"
Write-Host ""
Write-Host -ForegroundColor "yellow" "Credentials: If unspecified, will use current credentials"
Write-Host ""
Write-Host -ForegroundColor "yellow" "             Use 'other' to be prompted for credentials"
Write-Host ""
exit
}
Shutdown-Computer $computer $type $cred