$Path = "C:\temp"
$Daysback = "-30"
 
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($Daysback)
# Find files by last write time
Get-ChildItem $Path | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item
# Or by file creation time
#Get-ChildItem $Path | Where-Object { $_.CreationTime -lt $DatetoDelete } | Remove-Item



# One Liner
# Get-ChildItem –Path "C:\path\to\folder" -Recurse | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays(-30))} | Remove-Item
