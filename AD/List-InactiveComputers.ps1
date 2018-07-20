# -inactive ## in weeks
$NumWeeks = $args[0]

if ($NumWeeks -eq $null -or $NumWeeks -eq "") {
Write-Host -ForegroundColor "yellow" "Usage:  List-InactiveComputers.ps1 [For how many Weeks?]"
Write-Host -ForegroundColor "yellow" "Starting today by default, for 52 weeks"
$NumWeeks = 52
}

$list = dsquery computer -inactive $NumWeeks -limit 0
Write-host $list.Count "computer objects not logged into in" $NumWeeks "weeks."