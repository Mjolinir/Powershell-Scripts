$server = $args[0]

if ($server -eq $null -or $server -eq "") {
Write-Host -ForegroundColor "yellow" "Usage:  ListServicesNotRunning.ps1 [servername]"
exit
}

Get-WmiObject -class Win32_Service -computername $server -namespace "root\CIMV2" | Where-Object {$_.StartMode -match "auto" -and $_.state -match "stopped"}
#Get-WmiObject -class Win32_Service -computername . -namespace "root\CIMV2" | Where-Object {$_.StartMode -match "auto" -and $_.state -match "stopped"} | Start-Service