#requires -Version 3.0
#requires -PSSnapin VMware.VimAutomation.Core
 
function Set-VMChangeBlockTracking
{
<#
.SYNOPSIS
	The function Set-VMChangeBlockTracking allows you to set the
	Change Block Tracking setting on each VM you specify
	 
.DESCRIPTION
	The function Set-VMChangeBlockTracking allows you to set the
	Change Block Tracking setting on each VM you specify
	It can be run against one or more computers.
	It requires PowerShell version 3 (for #requires)
	 
.PARAMETER VM
	Specify one or multiple Virtual Machine names
	 
.PARAMETER Enable
	Specify if the Change Block Tracking must be Enable (TRUE) or Disable (FALSE)
	 
.EXAMPLE
	Set-VMChangeBlockTracking -VM Server01 -Enable true
	 
	This example Enable Change Block Tracking on the VM Server01.
	You'll need to go through a Stun/UnStun operation to actually enable the feature
	 
.EXAMPLE
	Get-Content c:\VM_List.txt | Set-VMChangeBlockTracking -Enable true
	 
	This example Enable Change Block Tracking on the VM(s) listed
	in the VM_list.txt file.
	 
.NOTES
	NAME : Set-VMChangeBlockTracking
	DATE : 2013/07/01
#>
 
 
[CmdletBinding()]
PARAM(
	[Parameter(Mandatory,ValueFromPipeLine,HelpMessage = "Please Specify the Virtual Machine name(s)")]
	[PSDefaultValue(Help='Specifies the Virtual Machine Name(s)')]
	[string[]]$VM,
	[Parameter(Mandatory,HelpMessage = "Please Specify if the Change Block Tracking must be Enable or not")]
	[ValidateSet($true,$false)]
	[PSDefaultValue(Help='Specifies if Change Block Tracking will be Enabled(true) or Disabled(false)')]
	[string]$Enable
)
 
BEGIN{
	Write-Verbose -Message "Checking if there is any VI Server Active Connection"
	IF(-not($global:DefaultVIServers.count -gt 0)){
		Write-Warning -Message "Wow You are not connected to any Vi Server. Use Connect-ViServer first"
		break
	}
	 
	Write-Verbose -Message "At least one VI Server Active Connection Found"
}#BEGIN
 
PROCESS{
	TRY{
		foreach ($item in $vm){
			Write-Verbose -Message "$item - Setting the Change Block Tracking Setting to $Enable..."
			$CurrentVM = Get-vm $item | get-view
			$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
			$vmConfigSpec.changeTrackingEnabled = $Enable
			$CurrentVM.reconfigVM($vmConfigSpec)
		}#foreach
	}# TRY Block
	 
	CATCH{
		Write-Warning -Message "Wow Something went wrong with $item"
	}#CATCH Block
}#PROCESS Block
 
END{Write-Verbose -Message "Script completed"}#END Block
}#function Set-VMChangeBlockTracking