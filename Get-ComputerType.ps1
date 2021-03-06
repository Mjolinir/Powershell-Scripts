function Get-ComputerType {
<#
	.Synopsis
		Will get Computer type in clear text
	.Description
		Will get Computer type in clear text
	.Example
		Get-ComputerType localhost
	.Notes
	 NAME:      Get-ComputerType
	 AUTHOR:    Fredrik Wall, fredrik@poweradmin.se
	 BLOG:		poweradmin.se/blog
	 LASTEDIT:  01/03/2010
#>
param ($computerName)
$Error.Clear()
	trap {continue}
	$colItems = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $computerName
	if ($Error.Count -gt 0) {
		Write-Host "An error occured while trying to determine Computer Type"
	}
	else {
		foreach ($objItem in $colItems) {
		$PCType = $objItem.PCSystemType
			Switch ($PCType) {
			1 {"Desktop"}
			2 {"Mobile"}
			3 {"Workstation"}
			4 {"Enterprise Server"}
			5 {"Small Office and Home Office (SOHO) Server"}
			6 {"Appliance PC"}
			7 {"Performance Server"}
			8 {"Maximum"}
			default {"Not a known Product Type"}
			}		
		}
	}
}