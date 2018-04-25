$ou = [ADSI]"LDAP://OU=OUName,DC=DomainName,DC=local"
foreach ($child in $ou.psbase.Children) {
    if ($child.ObjectCategory -like '*computer*') { $strServers += $child.Name }
}

$ou = [ADSI]"LDAP://OU=Domain Controllers,DC=DomainName,DC=local"
foreach ($child in $ou.psbase.Children) {
 if ($child.ObjectCategory -like '*computer*') { $strServers += $child.Name }
}

#$ou = [ADSI]"LDAP://OU=OUName,DC=DomainName,DC=local"
#foreach ($child in $ou.psbase.Children) {
# if ($child.ObjectCategory -like '*computer*') { Write-Host $child.Name } 
#}

$erroractionpreference = "SilentlyContinue"

$a = New-Object -comobject Excel.Application
$a.visible = $True

$b = $a.Workbooks.Add()
$c = $b.Worksheets.Item(1)

$c.Cells.Item(1,1) = "Server Name"
$c.Cells.Item(1,2) = "AV Product"
$c.Cells.Item(1,3) = "Version"
$c.Cells.Item(1,4) = "Scan Engine"
$c.Cells.Item(1,5) = "Virus Definition"
$c.Cells.Item(1,6) = "Virus Definition Date"
$c.Cells.Item(1,7) = "Report Time Stamp"

$d = $c.UsedRange
$d.Interior.ColorIndex = 19
$d.Font.ColorIndex = 11
$d.Font.Bold = $True

$intRow = 2

$colComputers = $strServers

foreach ($strComputer in $colComputers)
{
$c.Cells.Item($intRow,1)  = $strComputer

Function GetRegInfo
{
$key="SOFTWARE\McAfee\DesktopProtection"
$regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $strComputer)
$regKey = $regKey.OpenSubKey($key)

$Product = $regKey.GetValue("Product")
$c.Cells.Item($intRow,2)  = $Product

$productver  = $regKey.GetValue("szProductVer")
$c.Cells.Item($intRow,3) = $Productver

$key="SOFTWARE\McAfee\AVEngine"
$regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $strComputer)
$regKey = $regKey.OpenSubKey($key)

$ScanEngine = $regKey.GetValue("EngineVersionMajor")
$c.Cells.Item($intRow,4) = $ScanEngine

$VirDefVer = $regKey.GetValue("AVDatVersion")
$c.Cells.Item($intRow,5) = $VirDefVer

$virDefDate = $regKey.GetValue("AVDatDate")
$c.Cells.Item($intRow,6) = $virDefDate

}

GetRegInfo


$c.Cells.Item($intRow,7) = Get-date
 
$intRow = $intRow + 1


}
$d.EntireColumn.AutoFit()
#cls

Write-Host $strComputers
