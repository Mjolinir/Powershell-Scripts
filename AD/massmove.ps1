$Mailboxes = Get-Content .\massmove.txt
For ($Start = 0; $Start -lt $Mailboxes.length; $Start++) {New-MoveRequest –Identity $Mailboxes[$Start] -TargetDatabase 'Student15' -Suspend}