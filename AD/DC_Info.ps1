# Script By: Jon Knapp
#
# Get Information about your Domain Controllers to add to your Logfile 


$strComputer = $args[0]

# Get Operating System Information
$colOS =Get-WmiObject -class Win32_OperatingSystem -computername $strComputer

foreach($objComp in $colOS){
   $c1 = $objComp.Caption
   $c2 = $objComp.ServicePackMajorVersion

   "Operating System: {0} and Service Pack Level: {1}" -f $c1,$c2 | Out-File C:\health.log -append

}

# Get Hardware Information

$objWin32CS = Get-WmiObject -Class Win32_ComputerSystem -namespace "root\CIMV2" -computername $strComputer

foreach ($colhw in $objwin32cs){
   $c3 = $colhw.manufacturer
   $c4 = $colhw.model
   $c9 = $colhw.TotalPhysicalMemory

   #"Manufacturer: {0} and Model: {1}" -f $c3,$c4 | Out-File C:\health.log -append

}

# Get Serial number from BIOS

$objwin32B = Get-WmiObject -class  Win32_BIOS  -computername $strComputer

foreach ($colB in $objwin32B){
   $c5 = $colB.SerialNumber

   "Manufacturer: {0}, Model: {1} and Serial Number: {2}" -f $c3,$c4,$c5 | Out-File C:\health.log -append

}

# get processor info

$objWin32P = Get-WmiObject -class "Win32_Processor" -namespace "root\CIMV2" -computername $strComputer

foreach ($strPItem in $objWin32P){
  $c6 = $strPItem.Name
  $c7 = $strPItem.NumberOfCores
  $c8 = $strPItem.NumberOfLogicalProcessors
  
  "Processor: {0}, Number of cores: {1} and Number of Logical Processors: {2}" -f $c6,$c7,$c8 | Out-File C:\health.log -append
}

# Memory Info

[int]$TotMem = $c9 / 1GB
#$TotMem = $b1 / 1024

"Total Physical Memory: {0}GB" -f $TotMem | Out-File C:\health.log -append

# Get Network Info

$objWin32NAC = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -namespace "root\CIMV2" -computername $strComputer -Filter "IPEnabled = 'True'"

foreach ($objNACItem in $objWin32NAC){
  [string]$c10 = $objNACItem.IPAddress
  [string]$C11 = $objNACItem.MACAddress
  
   "IP Address: {0} and MAC Address: {1} " -f $C10,$c11 | Out-File C:\health.log -append 
}
C:\health.log
