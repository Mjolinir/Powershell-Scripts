if(!(test-path netid.txt))
{
  write-host ""
  write-host "input file 'netid.txt' not found"
  write-host "place this file in same dir as the script"
  write-host ""
}
else
{
  $netidlist = Get-Content netid.txt
  write-host ""
  write-host "add the following to command line in order to redirect to a file:"
  write-host "'| export-csv -Path match.csv -Encoding ascii -NoTypeInformation'"
  write-host ""
  foreach ($netid in $netidlist)
  {
	#get-qaduser $netid -IncludeAllProperties | select-object cn,extensionAttribute1
	Get-ADUser -Filter {cn -eq $netid} -SearchBase "DC=domain,DC=local" -Properties extensionAttribute1 | Select-Object Name,extensionAttribute1
  }
}
