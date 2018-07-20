$StartDay = $args[0]
$EndDay = $args[1]

if ($StartDay -eq $null -or $StartDay -eq "" -and $EndDay -eq $null -or $EndDay -eq "") {
Write-Host -ForegroundColor "yellow" "Usage:  List-PasswordsExpireSoon.ps1 [days from now to start] [days from now to end]"
Write-Host -ForegroundColor "yellow" "Starting today by default, ending in 7 days"
$StartDay = 0
$EndDay = 7
}
#Connect-QAD
write-host "Accounts with password that expires between" $StartDay "day(s) from now and" $EndDay "day(s) from now: "
Get-QADUser -SearchRoot "OU=OUName,DC=domain,DC=local" -Enabled -PasswordNeverExpires:$false -SizeLimit 0 | Where-Object {$_.PasswordExpires -gt (Get-Date).AddDays($StartDay).ToString("d") -and $_.PasswordExpires -le (Get-Date).AddDays($EndDay).ToString("d")} | Select Name, PasswordExpires | Sort-Object PasswordExpires
