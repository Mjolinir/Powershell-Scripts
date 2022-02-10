Get-VM | 
    Where-Object -Property PowerState -eq 'PoweredOff' | 
    Select-Object -Property Name, @{Label='poweredOffTime'; Expression={
        $_ | Get-VIEvent -Types Info | 
            Where-Object -Property fullformattedmessage -Match 'shutdown|powered off' | 
            Sort-Object -Property CreatedTime | 
            Select-Object -Last 1 -ExpandProperty CreatedTime 
    }}