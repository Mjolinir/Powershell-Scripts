

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

$colComputers = get-content MachineList2.txt

foreach ($strComputer in $colComputers)
{
$c.Cells.Item($intRow,1)  = $strComputer

Function GetRegInfo
{
$key="SOFTWARE\McAfee\GroupShield for Exchange"
$regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $strComputer)
$regKey = $regKey.OpenSubKey($key)

$Product = $regKey.GetValue("ProductDisplayName")
$c.Cells.Item($intRow,2)  = $Product

$productver  = $regKey.GetValue("ProductVer")
$c.Cells.Item($intRow,3) = $Productver

$key="SOFTWARE\McAfee\GroupShield for Exchange\SystemState"
$regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $strComputer)
$regKey = $regKey.OpenSubKey($key)

$ScanEngine = $regKey.GetValue("EngineVersion")
$c.Cells.Item($intRow,4) = $ScanEngine

$VirDefVer = $regKey.GetValue("DatVersion")
$c.Cells.Item($intRow,5) = $VirDefVer

$virDefDate = $regKey.GetValue("DatDate")
$c.Cells.Item($intRow,6) = $virDefDate
}

Function GetRegInfo64
{
$key="SOFTWARE\Wow6432Node\McAfee\GroupShield for Exchange"
$regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $strComputer)
$regKey = $regKey.OpenSubKey($key)

$Product = $regKey.GetValue("ProductDisplayName")
$c.Cells.Item($intRow,2)  = $Product

$productver  = $regKey.GetValue("ProductVer")
$c.Cells.Item($intRow,3) = $Productver

$key="SOFTWARE\Wow6432Node\McAfee\GroupShield for Exchange\SystemState"
$regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $strComputer)
$regKey = $regKey.OpenSubKey($key)

$ScanEngine = $regKey.GetValue("EngineVersion")
$c.Cells.Item($intRow,4) = $ScanEngine

$VirDefVer = $regKey.GetValue("DatVersion")
$c.Cells.Item($intRow,5) = $VirDefVer

$virDefDate = $regKey.GetValue("DatDate")
$c.Cells.Item($intRow,6) = $virDefDate
}

try {GetRegInfo}
catch { "" }

try {GetRegInfo64}
catch { "" }

$c.Cells.Item($intRow,7) = Get-date
 
$intRow = $intRow + 1

}
$d.EntireColumn.AutoFit()
#cls