import-module ActiveDirectory
[int]$LastLoggedOnInDays = 365
[int]$PasswordLastSetInDays = 180

$ADDomainDNSRoot = "domain.local"
$DomainDNS = "DOM"

Write-Verbose "Generating AD User Statistics `r "
$Age=365
$LastLoggedOnDate = $DateTime - (New-TimeSpan -days $LastLoggedOnInDays)
$PasswordStaleDate = $DateTime - (New-TimeSpan -days $PasswordLastSetInDays)
$DateTime = Get-Date #Get date/time
$UserStaleDate = $DateTime.AddDays(-$Age)
$NeverLoggedOnDate = $DateTime.AddDays(-365) 
$Yesterday = $DateTime.AddDays(-1) 
$Yesterday = $Yesterday.ToShortDateString()
[string]$Yesterday = $Yesterday
$Today = $DateTime.ToShortDateString()
[string]$Today = $Today

[array] $AllUserInventory = @()
$1Days = $DateTime.AddDays(-1)
$2Days = $DateTime.AddDays(-2)
$3Days = $DateTime.AddDays(-3)
$4Days = $DateTime.AddDays(-4)
$5Days = $DateTime.AddDays(-5)
$6Days = $DateTime.AddDays(-6)
$7Days = $DateTime.AddDays(-7)
$30Days = $DateTime.AddDays(-30)
$45Days = $DateTime.AddDays(-45)
$60Days = $DateTime.AddDays(-60)
$90Days = $DateTime.AddDays(-90)
$120Days = $DateTime.AddDays(-120)
$180Days = $DateTime.AddDays(-180)

###################
# User Statistics # 20110919-13
###################
Write-Verbose "Generating AD User Statistics `r "
$LastLoggedOnDate = $DateTime - (New-TimeSpan -days $LastLoggedOnInDays)
$PasswordStaleDate = $DateTime - (New-TimeSpan -days $PasswordLastSetInDays)
$DateTime = Get-Date #Get date/time
$UserStaleDate = $DateTime.AddDays(-$Age)
$NeverLoggedOnDate = $DateTime.AddDays(-365) 
$Yesterday = $DateTime.AddDays(-1).ToShortDateString()
#Yesterday = $Yesterday.ToShortDateString()
[string]$Yesterday = $Yesterday
$Today = $DateTime.ToShortDateString()
[string]$Today = $Today

Write-Output "Discovering all users in $ADDomainDNSRoot ... `r "
# Gather a list of all users in AD including necessary attributes
[array]$AllUsers = Get-ADUser -filter * -properties Name,DistinguishedName,Enabled,LastLogonDate,LastLogonTimeStamp,LockedOut,SAMAccountName
$AllUsersCount = $AllUsers.Count
Write-Output "There were $AllUsersCount stale user objects discovered in $ADDomainDNSRoot ... `r "
Write-Output " `r "

Write-Verbose "Count Disabled Users `r "
[array] $DisabledUsers = $AllUsers | Where-Object { $_.Enabled -eq $False }
$DisabledUsersCount = $DisabledUsers.Count
[array] $EnabledUsers = $AllUsers | Where-Object { $_.Enabled -eq $True }
$EnabledUsersCount = $EnabledUsers.Count
Write-Output "There are $EnabledUsersCount Enabled users and there are $DisabledUsersCount Disabled users in $DomainDNS `r "

Write-Verbose "Count Inactive Users that are Enabled `r "
[array] $InactiveUsers = $AllUsers | Where-Object { ($_.PasswordLastSet -lt $UserStaleDate) -and ($_.Enabled -eq $True) }
$InactiveUsersCount = $InactiveUsers.Count
Write-Output "There are $InactiveUsersCount users identified as Inactive (with passwords older than $Age days in $DomainDNS `r "

Write-Verbose "Count Admin Accounts (accounts with _ad in the name) `r "
[array] $AllAdminAccounts = $AllUsers | Where-Object { ($_.SAMAccountName -like "*_it") -or ($_.Name -like "*_ad*") }
$AllAdminAccountsCount = $AllAdminAccounts.Count
#
[array] $EnabledAdminAccounts = $AllAdminAccounts | Where-Object { $_.Enabled -eq $True }
$EnabledAdminAccountsCount = $EnabledAdminAccounts.Count
Write-Output "There are $EnabledAdminAccountsCount Enabled Admin accounts in $DomainDNS (out of a total of $AllAdminAccountsCount Admin accounts) `r "
#
[array] $ActiveAdminAccounts = $EnabledAdminAccounts | Where-Object { ($_.LastLogonDate -ge $180Days) -and ($_.PasswordLastSet -gt $NeverLoggedOnDate) } 
$ActiveAdminAccountsCount = $ActiveAdminAccounts.Count
Write-Output "There are $ActiveAdminAccountsCount Active Admin accounts in $DomainDNS (Active accounts have logged on in the past 6 months and have current passwords) `r "

Write-Verbose "Count Service Accounts (accounts with SVC in the name) `r "
[array] $AllServiceAccounts = $AllUsers | Where-Object { $_.SAMAccountName -like "SA*" }
$AllServiceAccountsCount = $AllServiceAccounts.Count
[array] $EnabledServiceAccounts = $AllServiceAccounts | Where-Object { $_.Enabled -eq $True }
$EnabledServiceAccountsCount = $EnabledServiceAccounts.Count
Write-Output "There are $EnabledServiceAccountsCount Enabled Service accounts in $DomainDNS (out of a total $AllServiceAccountsCount Service accounts) `r "

#Write-Verbose "Count users with an Exchange Mailbox `r "
#[array] $MailboxUsers = $AllUsers | Where-Object { $_.msExchHomeServerName -notlike $NULL }
#$MailboxUsersCount = $MailboxUsers.Count
#[array] $MailboxEnabledUsers = $MailboxUsers | Where-Object { $_.msExchHomeServerName -notlike $NULL }
#$MailboxEnabledUsersCount = $MailboxEnabledUsers.Count
#Write-Output "There are $MailboxUsersCount users in $DomainDNS with an Exchange Mailbox. `r "
#Write-Output "There are $MailboxEnabledUsersCount Enabled users in $DomainDNS with an Exchange Mailbox. `r "

Write-Verbose "Count Enabled users who have logged on in the last 30 days `r "
[array] $LastLogon30 = $EnabledUsers | Where-Object { $_.LastLogonDate -ge $30Days }
$LastLogon30Count = $LastLogon30.Count
Write-Output "Out of $EnabledUsersCount Enabled users in $DomainDNS only $LastLogon30Count have logged on in the last 30 days (there may be up to a 14 day margin of error for this count) `r "

Write-Verbose "Count Enabled users who have logged on in the last 45 days `r "
[array] $LastLogon45 = $EnabledUsers | Where-Object { $_.LastLogonDate -ge $45Days }
$LastLogon45Count = $LastLogon45.Count
Write-Output "Out of $EnabledUsersCount Enabled users in $DomainDNS only $LastLogon45Count have logged on in the last 45 days `r"

Write-Verbose "Count Enabled users who have logged on in the last 60 days `r "
[array] $LastLogon60 = $EnabledUsers | Where-Object { $_.LastLogonDate -ge $60Days }
$LastLogon60Count = $LastLogon60.Count
Write-Output "Out of $EnabledUsersCount Enabled users in $DomainDNS only $LastLogon60Count have logged on in the last 60 days `r"

Write-Verbose "Count Enabled users who have logged on in the last 90 days `r"
[array] $LastLogon90 = $EnabledUsers | Where-Object { $_.LastLogonDate -ge $90Days }
$LastLogon90Count = $LastLogon90.Count
Write-Output "Out of $EnabledUsersCount Enabled users in $DomainDNS only $LastLogon90Count have logged on in the last 90 days `r"

Write-Verbose "Count Enabled users who have logged on in the last 120 days `r"
[array] $LastLogon120 = $EnabledUsers | Where-Object { $_.LastLogonDate -ge $120Days }
$LastLogon120Count = $LastLogon120.Count
Write-Output "Out of $EnabledUsersCount Enabled users in $DomainDNS only $LastLogon120Count have logged on in the last 120 days `r"

Write-Verbose "Count Enabled users who have logged on in the last 180 days `r"
[array] $LastLogon180 = $EnabledUsers | Where-Object { $_.LastLogonDate -ge $180Days }
$LastLogon180Count = $LastLogon180.Count
Write-Output "Out of $EnabledUsersCount Enabled users in $DomainDNS only $LastLogon180Count have logged on in the last 180 days `r"

Write-Verbose "Count All users who have NEVER logged on `r"
[array] $LastLogonNever = $AllUsers | Where-Object { ($_.LastLogonDate -eq $NULL) -and ($_.PasswordLastSet -gt $NeverLoggedOnDate) }
$LastLogonNeverCount = $LastLogonNever.Count
Write-Output "Out of All $AllUsersCount users in $DomainDNS $LastLogonNeverCount have NEVER logged on (no logon date associated with account) `r"

Write-Verbose "Count users who logged in during the last week (Only useful if LastLogonTimeStamp replicates every <7 days) `r"
[array] $LastLogon1 = $EnabledUsers | Where-Object { $_.LastLogonDate -le $7days }
$LastLogon1Count = $LastLogon1.Count
Write-Output "$LastLogon1Count Enabled users logged in within the last week `r"

#Write-Verbose "Count users who logged in yesterday (Only useful if LastLogonTimeStamp replicates every 1 day) `r" 
#[array] $LastLogonYesterday = $EnabledUsers | Where-Object { $_.LastLogonDate -like "*$Yesterday*" }
#$LastLogonYesterdayCount = $LastLogonYesterday.Count
#Write-Output "$LastLogonYesterdayCount Enabled users logged in yesterday `r"

Write-Verbose "Count users who logged in today (Only useful if LastLogonTimeStamp replicates every 1 day -combine with yesterday logons to get semi-accurate count of recent logons) `r"
[array] $LastLogontoday = $EnabledUsers | Where-Object { $_.LastLogonDate -like "*$Today*" }
$LastLogontodayCount = $LastLogontoday.Count
Write-Output "$LastLogontodayCount Enabled users logged in today (so far) `r"

Write-Verbose "Count enabled users who have accounts locked out `r"
[array] $EnabledLockedUsers = $EnabledUsers | Where-Object { $_.LockedOut -eq $True }
$EnabledLockedUsersCount = $EnabledLockedUsers.Count
Write-Output "$EnabledLockedUsersCount Enabled users are currently locked out `r"
 
