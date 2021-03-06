
$tDB = "Employee20"

$oldDB = (Get-Mailbox -Database Employee1).count
$newDB = (Get-Mailbox -Database $tDB).count
$freeDB =  ( 50 - $newDB)

if ( $oldDB -gt 0) {
   if ( $oldDB -lt $freeDB ) {
      Get-Mailbox -Database Employee1 | New-MoveRequest -TargetDatabase $tDB -BatchName "Ex2k3toEx2k10"
	  Write-Host ""
	  Write-Host "Moving mailboxes in batch mode." }
   else {
      Send-MailMessage -To "btrut2@uis.edu","jsant1@uis.edu" -From "uisexchangeadmin@uis.edu" -Subject "Mailbox Move Error" -Priority High -SmtpServer uismail20 -Body "Database $tDB is full. Could not move new employee mailboxes."
      Write-Host $tDB "is at or near the max limit. Please create a new DB." }
}
else {
   Write-Host "Employee1 has no mailboxes to move." }  