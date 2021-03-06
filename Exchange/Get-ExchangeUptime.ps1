#http://www.mikepfeiffer.net/2010/03/exchange-server-uptime-reports-with-powershell/

Get-ExchangeServer | %{
    if(Test-Connection $_.name -Count 1 -Quiet) {
        $OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $_.name            
 
        $uptime = (Get-Date) - $OS.ConvertToDateTime($OS.LastBootUpTime)            
 
        $report += "$($_.name) has been up for {0} days, {1} hours and {2} minutes." `
        -f $uptime.Days, $uptime.Hours, $uptime.Minutes + "`r"
        
        Write-Host $report
    }
}
