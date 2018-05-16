$group = $args[0]

if ($group -eq $null -or $group -eq "") {
Write-Host -ForegroundColor "yellow" "Usage:  ListGroupMambers.ps1 [groupname]"
exit
}

get-qadgroup $group | foreach { $_.member }