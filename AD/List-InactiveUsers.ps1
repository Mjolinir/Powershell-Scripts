Get-QADUser -Sizelimit 0 |?{ $_.LastLogonTimestamp -gt (get-date).AddDays(-90)} | Select UserPrincipalName | export-Csv "C:\details.csv" 
$csv = Import-csv -path "C:\details.csv" 
#foreach($user in $csv) 
#{ 
#Move-QADObject $User -NewParentContainer ?domain.com/Disabled Accounts? 
#Disable-QADUser $user 