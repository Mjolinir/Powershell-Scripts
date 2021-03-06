$a = @{Expression={$_.Name};Label="Database";width=20}, `
@{Expression={$_.Count};Label="Count";width=5}

$b = @{Expression={$_.Name};Label="Server";width=15}, `
@{Expression={$_.Count};Label="Count";width=5}

clear-host
write-host ""
write-host "Mailbox count by database:"
get-mailboxdatabase | Get-Mailbox | Group-Object -Property:Database | Select-Object name,count | Sort-Object Name | format-table $a
write-host "Mailbox count by server:"
get-mailboxdatabase | Get-Mailbox | Group-Object -Property:ServerName | Select-Object name,count | format-table $b
write-host "Total count of mailboxes:"
write-host ""
write-host "Count"
write-host "-----"
(get-mailboxdatabase | Get-Mailbox).Count
write-host ""