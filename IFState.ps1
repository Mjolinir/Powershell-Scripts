# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
#          Name: ifstate
#        Author: Kris Cieslak (defaultset.blogspot.com)
#          Date: 2010-04-21
#   Description: Enabling/Disabling network adapter.
#                Works on Windows XP and higher.
#                If your os is WinXP and its language is not English,
#                you'll have to change values in $UpStateLabel and $DownStateLabel 
#
#    Parameters: network interface name,
#                state [up/down] (optional, if up then down, or if down then up :))
# Usage example: 
#                ./ifstate 'Local network connection' down
#            or
#                ./ifstate 'Local network connection'  
#
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
PARAM ($ifname = $(throw "Specifiy interface name"),$state = "")
trap [Exception] {
    Write-Host 'Ups! Something wrong.' -ForegroundColor Red
	continue;
}

# These values depends on your os language
$UpStateLabel = 'En&able';
$DownStateLabel = 'Disa&ble';

$st = 0;
if ($state.length -gt 0) {
  switch ($state.ToLower()) {
       'up' { $st = 1 }
	   'down' {$st = 0 }
  }
} else {
  $c =(gwmi Win32_NetworkAdapter | ? { $_.NetConnectionID -eq $ifname }).ConfigManagerErrorCode;
  if ($c -eq 22) { $st = 1 } else { $st = 0 }
}

if ($st -eq 1) {
    $StateLabel = $UpStateLabel;
} else {
    $StateLabel = $DownStateLabel;
}

if ([int](([regex]('\d{1,3}')).match((gwmi win32_OperatingSystem).Version).ToString()) -le 5) {
    $shell = New-Object -comObject Shell.Application;
    $test=(($shell.NameSpace(3).Items() | 
	    ? { $_.Path -like '*7007ACC7-3202-11D1-AAD2-00805FC1270E*'}).GetFolder.Items() |
		? { $_.Name -eq $ifname }).Verbs() | ? { $_.Name -eq $StateLabel }
	if ($test -ne $null) { 
	   ($test).DoIt() 
	}
} else {
     if ($st -eq 1) {
        (gwmi Win32_NetworkAdapter | ? { $_.NetConnectionID -eq $ifname } ).Enable() | Out-Null
	 } else {
	    (gwmi Win32_NetworkAdapter | ? { $_.NetConnectionID -eq $ifname } ).Disable() | Out-Null
	 }
}