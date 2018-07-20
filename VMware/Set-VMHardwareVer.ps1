param(
#  [Parameter(Mandatory=$true)]
#  [ValidateNotNullOrEmpty()]
   [string] $vmName,
   [string] $hwVersion
)

if ( $vmName -eq "" -or $vmName -eq $null ) { 
   Write-Host "Syntax: Set-VMHardwareVer <VM Name> <Desired v#>"
   exit }

Write-Host -nonewline "Is VM powered off? (Y/N) "
$response = read-host
if ( $response -ne "y" -or $response -ne "Y" ) {
   exit }

if ( $hwVersion -eq "8" ) { $hwVersion="v8" }
elseIf ( $hwVersion -eq "9" ) { $hwVersion="v9" }
elseIf ( $hwVersion -eq "10" ) { $hwVersion="v10" }
elseIf ( $hwVersion -eq "11" ) { $hwVersion="v11" }
else { $hwVersion="v9" }

Set-VM -VM $vmName -version $hwVersion -Confirm:$false

if ($?)
   { Write-Host "Hardware upgraded."
     exit 0 }
else
   { Write-Host "Hardware upgrade failed."
     exit 1 }

