$MinutesOld = $args[0]

if ($MinutesOld -eq $null -or $var -eq "") {
        Write-Host -ForegroundColor "yellow" "Usage:  Disconnect-vCenterSessions.ps1 [Idle Time In Minutes]"
        exit
}

#$ServiceInstance = Get-View ServiceInstance 
#$SessionManager = Get-View $ServiceInstance.Content.SessionManager 
#$SessionManager.SessionList | Where {$_.LastActiveTime -lt (Get-Date).AddMinutes(-$MinutesOld)} | %{$SessionManager.TerminateSession($_.Key)}

$intOlderThan = $MinutesOld
$serviceInstance = Get-View 'ServiceInstance'
## get the session manager object
$sessMgr = Get-View $serviceInstance.Content.sessionManager
## array to hold info about stale sessions
$oldSessions = @()
foreach ($sess in $sessMgr.SessionList){
    if (($sess.LastActiveTime).addminutes($intOlderThan).ToLocalTime() -lt (Get-Date) -and
          $sess.Key -ne $sessMgr.CurrentSession.Key){
        $oldSessions += $sess.Key
    } ## end if
} ## end foreach

## if there are any old sessions, terminate them; else, just write message to the Warning stream
if (($oldSessions | Measure-Object).Count -gt 0) {
    ## Terminate sessions than are idle for longer than approved ($intOlderThan)
    write-host "Killing:" $oldSessions.count "sessions"
    $sessMgr.TerminateSession($oldSessions)
} ## end if
else {Write-Warning "No sessions that have been idle for more than '$intOlderThan' minutes; no action taken"} 

