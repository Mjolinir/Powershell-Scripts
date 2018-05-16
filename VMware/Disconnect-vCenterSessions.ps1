$var = $args[0]

if ($var -eq $null -or $var -eq "") {
	Write-Host -ForegroundColor "yellow" "Usage:  Disconnect-vCenterSessions.ps1 [Idle Time In Minutes]"
	exit
}

Function Get-ViSession {
<#
.SYNOPSIS
Lists vCenter Sessions.

.DESCRIPTION
Lists all connected vCenter Sessions.

.EXAMPLE
PS C:\> Get-VISession

.EXAMPLE
PS C:\> Get-VISession | Where { $_.IdleMinutes -gt 720 }
#>
$SessionMgr = Get-View $DefaultViserver.ExtensionData.Client.ServiceContent.SessionManager
$AllSessions = @()
$SessionMgr.SessionList | Foreach {
	$Session = New-Object -TypeName PSObject -Property @{
	Key = $_.Key
	UserName = $_.UserName
	FullName = $_.FullName
	LoginTime = ($_.LoginTime).ToLocalTime()
	LastActiveTime = ($_.LastActiveTime).ToLocalTime()
		}
	
	If ($_.Key -eq $SessionMgr.CurrentSession.Key) {
		$Session | Add-Member -MemberType NoteProperty -Name Status -Value “Current Session”
		} Else {
		$Session | Add-Member -MemberType NoteProperty -Name Status -Value “Idle”
		}

	$Session | Add-Member -MemberType NoteProperty -Name IdleMinutes -Value ([Math]::Round(((Get-Date) – ($_.LastActiveTime).ToLocalTime()).TotalMinutes))
	$AllSessions += $Session
	}
	$AllSessions
}

Function Disconnect-ViSession {
<#
.SYNOPSIS
Disconnects a connected vCenter Session.

.DESCRIPTION
Disconnects a open connected vCenter Session.

.PARAMETER  SessionList
A session or a list of sessions to disconnect.

.EXAMPLE
PS C:\> Get-VISession | Where { $_.IdleMinutes -gt 720 } | Disconnect-ViSession

.EXAMPLE
PS C:\> Get-VISession | Where { $_.Username -eq “User19” } | Disconnect-ViSession
#>
[CmdletBinding()]
Param (
[Parameter(ValueFromPipeline=$true)]
$SessionList
)
Process {
	$SessionMgr = Get-View $DefaultViserver.ExtensionData.Client.ServiceContent.SessionManager
	$SessionList | Foreach {
	Write “Disconnecting Session for $($_.Username) which has been active since $($_.LoginTime)”
	$SessionMgr.TerminateSession($_.Key)
		}
	}
}

Get-ViSession | Where { $_.IdleMinutes -gt $var } | Disconnect-ViSession
