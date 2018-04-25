# massmove.txt can be NetIDs, email addresses, or display names - one per line
$UserList = Get-Content .\massmove.txt
$Target = "OU=To Be Deleted Students,OU=OUName,DC=domain,DC=local"

ForEach ($User in $UserList){

$UserDN = Get-QADUser $User | Select-Object DN
if ($UserDN -notmatch [String]::Join('|',"OU=OUName,DC=domain,DC=local")) {
	#Get-QADUser -Identity $User
	Move-QADObject $User -To $Target
	Set-QADUser $User -Description "Delete end of Spring 2012"
	Disable-QADUser $User
	}
else {
	  write-host -foregroundcolor yellow "Skipped OPT Student -" $User
     }
}
