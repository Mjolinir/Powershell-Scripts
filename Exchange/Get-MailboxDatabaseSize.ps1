
if ($args[0] -eq $null) {
Get-MailboxDatabase -Status | select ServerName,Name,DatabaseSize
exit
}
else
{
Get-MailboxDatabase -Status -identity $args[0] | select ServerName,Name,DatabaseSize
}