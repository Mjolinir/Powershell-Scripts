$server_name = $args[0]
$percentage_warn = 0

if ($server_name -eq $null -or $server_name -eq "") {
Write-Host -ForegroundColor "yellow" "Usage:  GetCPULoad.ps1 [servername]"
exit
}

$cpuinfo = Get-WmiObject -ComputerName $server_name Win32_Processor

$count = 0
$cpu_utilisation_total = 0
$cpu_utilisation_average = 0
$cpu_utilisation_maximum_single_processor = 0

foreach ($cpu in $cpuinfo)
    {
    $cpu_utilisation_total = $cpu_utilisation_total + $cpu.LoadPercentage
    $count = $count + 1
    if ($cpu.LoadPercentage -gt $cpu_utilisation_maximum_single_processor)
        {
        $cpu_utilisation_maximum_single_processor = $cpu.LoadPercentage
        }
    }
$cpu_utilisation_average = $cpu_utilisation_total / $count

if ($cpu_utilisation_average -gt $percentage_warn)
    {
    Write-Host "Server: $server_name - CPU load $cpu_utilisation_average %"
    }
if ($cpu_utilisation_maximum_single_processor -gt $percentage_warn)
    {
    Write-Host "Server: $server_name - Single CPU load, highest percentage is: $cpu_utilisation_maximum_single_processor %"
    }