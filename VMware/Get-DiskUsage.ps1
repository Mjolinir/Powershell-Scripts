#$viServer = Read-Host 'Please Enter Your vCenter hostname/IP address'
#$cred = Get-Credential
#Connect-VIServer $viServer -Credential $cred
 
$VMName = Read-host 'Please Enter the VM Name'
$VM = Get-VM $VMName
$VM.Extensiondata.Guest.Disk | Select @{N="Name";E={$VM.Name}},DiskPath, @{N="Capacity(GB)";E={[math]::Round($_.Capacity/ 1GB)}}, @{N="Free Space(GB)";E={[math]::Round($_.FreeSpace / 1GB)}}, @{N="Free Space %";E={[math]::Round(((100* ($_.FreeSpace))/ ($_.Capacity)),0)}} | ft -AutoSize

