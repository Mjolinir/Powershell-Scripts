$server = $args[0]

if ($server -eq $null -or $server -eq "") {
Write-Host -ForegroundColor "yellow" "Usage:  ListWinInstallDate.ps1 [servername]"
exit
}

([WMI]'').ConvertToDateTime((Get-WmiObject -ComputerName $server Win32_OperatingSystem).InstallDate)