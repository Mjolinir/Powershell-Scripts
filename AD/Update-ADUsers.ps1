$UserList = Get-Content .\massmove.txt
$Desc = "Put description here"

ForEach ($User in $UserList){

Set-QADuser $User -objectAttributes @{extensionAttribute8='IAM_IRS_UIS_EXCEPTION';description=$Desc}

}