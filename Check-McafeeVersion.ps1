$erroractionpreference = "SilentlyContinue"

$excel = New-Object -comobject Excel.Application
$excel.visible = $True

$wb = $excel.Workbooks.Add()
$col = $wb.Worksheets.Item(1)

$col.Cells.Item(1,1) = "Server Name"
$col.Cells.Item(1,2) = "AV Product"
$col.Cells.Item(1,3) = "Version"
$col.Cells.Item(1,4) = "Scan Engine"
$col.Cells.Item(1,5) = "Virus Definition"
$col.Cells.Item(1,6) = "Virus Definition Date"
$col.Cells.Item(1,7) = "Report Time Stamp"

$head = $col.UsedRange
$head.Interior.ColorIndex = 19
$head.Font.ColorIndex = 11
$head.Font.Bold = $True

$intRow = 2

$colComputers = get-content MachineList.txt

foreach ($strComputer in $colComputers)
{
$col.Cells.Item($intRow,1) = $strComputer

Function GetRegInfo
{
$key="SOFTWARE\McAfee\DesktopProtection"
$regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $strComputer)
$regKey = $regKey.OpenSubKey($key)

$Product = $regKey.GetValue("Product")
$col.Cells.Item($intRow,2) = $Product

$productver = $regKey.GetValue("szProductVer")
$col.Cells.Item($intRow,3) = $Productver

$key="SOFTWARE\McAfee\AVEngine"
$regkey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $strComputer)
$regKey = $regKey.OpenSubKey($key)

$ScanEngine = $regKey.GetValue("EngineVersionMajor")
$col.Cells.Item($intRow,4) = $ScanEngine

$VirDefVer = $regKey.GetValue("AVDatVersion")
$col.Cells.Item($intRow,5) = $VirDefVer

$virDefDate = $regKey.GetValue("AVDatDate")
$col.Cells.Item($intRow,6) = $virDefDate
}

GetRegInfo

$col.Cells.Item($intRow,7) = Get-date

$intRow = $intRow + 1


}
$head.EntireColumn.AutoFit()
#cls