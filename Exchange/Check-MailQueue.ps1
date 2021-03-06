#Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
$MailQfile = “C:\Users\btrut2\Scripts\logs\Mailq.htm”
$style = '<style>BODY{font-size:1em; font-family:calibri; background-color:#D0D0D0;}TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}TH{font-size:1em; color:white; border-width: 1px;padding: 2px;border-style: solid;border-color:black;background-color:#000066}TD{border-width: 1px;padding: 2px;border-style: solid;border-color:black;background-color:white}</style>'

Do {
$time = get-date -format g

$MessageCount = Get-ExchangeServer | Where { $_.isHubTransportServer -eq $true } | get-queue |  foreach -begin {$total=0} -process {$total+=$_.messageCount} -end {$total}
 
$mailq =  Get-ExchangeServer | Where { $_.isHubTransportServer -eq $true } | get-queue | select @{Expression={$_.Identity};Name=”Queue Identity"}, @{Expression={$_.NextHopDomain};Name="Destination"}, @{Expression={$_.Status};Name=”Status”}, @{Expression={$_.MessageCount};Name=”Queue Size”}, @{Expression={$_.LastError};Name="Last Error"} |ConvertTo-Html -head $style -body $style

if ($MessageCount -gt 500)
{
$Alert = "<font color=red><B>Exchange 2010 Server Queue Lengths..ABOVE NORMAL.. PLEASE INVESTIGATE!</B></DIV>"
}
Else
{
$Alert = "<font color=lime><B>Exchange 2010 Server Queue Lengths....ALL OK! :-)</B></DIV>"
}

$HTML = "<head><META HTTP-EQUIV=refresh CONTENT=300></head><body><DIV ALIGN=center style=background-color=black>" + $Alert + "<DIV ALIGN=center><font color=black><B> Last Updated  :  " + $time + "</B></DIV><p></p><DIV ALIGN=center>" + $mailq
echo $HTML | out-file $MailQfile

invoke-item $MailQfile

sleep 300
}
until (1 -eq 2)