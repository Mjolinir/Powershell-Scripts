function Get-McAfeeVersion {
param ($Computer)
$ProductVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$Computer).OpenSubKey('SOFTWARE\McAfee\DesktopProtection').GetValue('szProductVer')
$EngineVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$Computer).OpenSubKey('SOFTWARE\McAfee\AVEngine').GetValue('EngineVersionMajor')
$DatVer = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$Computer).OpenSubKey('SOFTWARE\McAfee\AVEngine').GetValue('AVDatVersion')
$DatDate = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$Computer).OpenSubKey('SOFTWARE\McAfee\AVEngine').GetValue('AVDatDate')

Write-Host "Product version: $ProductVer"
Write-Host "Engine version: $EngineVer"
Write-Host "Dat version: $DatVer"
Write-Host "Dat date: $DatDate"
Write-Host " "

}

$server = $args[0]

if ($server -eq $null -or $server -eq "") {
Write-Host -ForegroundColor "yellow" "Usage:  GetMcafeeVersion.ps1 [servername]"
exit
}

Get-McAfeeVersion $server