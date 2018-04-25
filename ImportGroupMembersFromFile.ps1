$GroupName = $args[0]
$FileName = "C:\GrpExport.csv"

if ($GroupName -eq $null -or $GroupName -eq "") {
	write-host -foregroundcolor "yellow"  "Usage: ImportGroupMembersFromFile [groupname]"
	write-host -foregroundcolor "yellow"  "This should be the name of the group you wish to import members in the file to."
	exit
}

$Group = Get-QADGroup -Identity $GroupName
Import-Csv -Path $FileName | ForEach-Object {Add-QADGroupMember -Identity $Group.DN -Member $_.DN }