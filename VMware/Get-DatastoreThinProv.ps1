$report = @()
foreach ($vm in Get-VM){
$view = Get-View $vm
if ($view.config.hardware.Device.Backing.ThinProvisioned -eq $true){
$row = '' | Select-Object Name, Provisioned, Total, Used, VMDKs, VMDKsize, DiskUsed, Thin
    $row.Name = $vm.Name
    $row.Provisioned = [math]::round($vm.ProvisionedSpaceGB , 2)
    $row.Total = [math]::round(($view.config.hardware.Device | Measure-Object CapacityInKB -Sum).sum/1048576 , 2)
    $row.Used = [math]::round($vm.UsedSpaceGB , 2)
    $row.VMDKs = $view.config.hardware.Device.Backing.Filename | Out-String
    $row.VMDKsize = $view.config.hardware.Device | Where-Object {$_.GetType().name -eq 'VirtualDisk'} | ForEach-Object {($_.capacityinKB)/1048576} | Out-String
    $row.DiskUsed = $vm.Extensiondata.Guest.Disk | ForEach-Object {[math]::round( ($_.Capacity - $_.FreeSpace)/1048576/1024, 2 )} | Out-String
    $row.Thin = $view.config.hardware.Device.Backing.ThinProvisioned | Out-String
$report += $row
}}
#$report | Sort Name | Export-Csv -Path "Thin_Disks.csv"
$report | Sort-Object Name
