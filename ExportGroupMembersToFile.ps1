$GroupName = $args[0]
$FileName = "C:\GrpExport.csv"

if ($GroupName -eq $null -or $GroupName -eq "") {
	write-host -foregroundcolor "yellow"  "Usage: ExportGroupMembersToFile [groupname]"
	exit
}

get-qadgroupmember $args[0] | select-object dn | export-csv $FileName
write-host "Group list exported to $FileName"