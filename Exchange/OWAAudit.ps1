#Created by P. Sukus
#Modified by D. Dill
#Name: mobile users syncing through OWA audit
#set the timeframe to audit in days
$Daysold = 1
$Date = (get-date).adddays(-$daysold)
$servers = "uiscas1", "uiscas2"
foreach ($s in $servers) 
    {
    Write-host -ForegroundColor Blue "Checking server $s for files from the last $daysold day(s)"
    $logfiles += gci -path \\$s\c$\inetpub\logs\LogFiles\W3SVC1 | where {$_.LastWriteTime -gt $date}
    }
    
Foreach ($l in $logfiles)
    {
    
    Write-host "Processing "$l.fullname
    Copy-item $l.fullname -Destination C:\Users\btrut2\Scripts
	$palmusers +=  gc $l.name | where {$_ -match "DeviceType=Palm"}
	$iphoneusers +=  gc $l.name | where {$_ -match "DeviceType=iPhone"}
    $ipodusers +=  gc $l.name | where {$_ -match "DeviceType=iPod"}
    $ipadusers +=  gc $l.name | where {$_ -match "DeviceType=iPad"}
    Remove-Item $l.name
    }
$iuser = @()
$puser = @()
$poduser = @()
$paduser = @()
foreach ($l in $iphoneusers | where {$_ -ne $null})
    {
    $u = $l.split(" ")[7]
    if ($iuser -notcontains $u)
        {
        $iuser += "$u"
        }
    $u = $null
    }
	foreach ($l in $palmusers | where {$_ -ne $null})
    {
    $u = $l.split(" ")[7]
    if ($puser -notcontains $u)
        {
        $puser += "$u"
        }
    $u = $null
    }
    foreach ($l in $ipodusers | where {$_ -ne $null})
    {
    $u = $l.split(" ")[7]
    if ($poduser -notcontains $u)
        {
        $poduser += "$u"
        }
    $u = $null
    }
    foreach ($l in $ipadusers | where {$_ -ne $null})
    {
    $u = $l.split(" ")[7]
    if ($paduser -notcontains $u)
        {
        $paduser += "$u"
        }
    $u = $null
    }
$body = "<!DOCTYPE html PUBLIC `"-//W3C//DTD XHTML 1.0 Strict//EN`"  `"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd`">"
$body += "<html xmlns=`"http://www.w3.org/1999/xhtml`">"
$body += "<head>"
$body += "<title>iPhone Users</title>"
$body += "</head><body>"
$body += "<table border=1>"
$body += "<colgroup>"
$body += "<col/>"
$body += "</colgroup>"
$body += "<tr><td><b>iPhone Users</b></td></tr>"
foreach ($y in $iuser)
    {
    $body += "<tr><td>$y</td></tr>"
    }
$body += "<tr><td></td></tr>"
$body += "<br>"
$body += "<tr><td><b>iPod Users</b></td></tr>"
foreach ($y in $poduser)
    {
    $body += "<tr><td>$y</td></tr>"
    }
$body += "<tr><td></td></tr>"
$body += "<br>"
$body += "<tr><td><b>iPad Users</b></td></tr>"
foreach ($y in $paduser)
    {
    $body += "<tr><td>$y</td></tr>"
    }
$body += "<tr><td></td></tr>"
$body += "<br>"
$body += "<tr><td><b>Palm Users</b></td></tr>"
foreach ($y in $puser)
    {
    $body += "<tr><td>$y</td></tr>"
    }
$body += "</table>"
$body += "<br>Audited servers:  $servers <br>"
$body += "Audited for:  DeviceType=Palm and DeviceType=iPhone, iPod, or iPad"
$body += "</body></html>"

$smtpServer = "uismail3"
$mailer = new-object Net.Mail.SMTPclient($smtpserver)	
$From = "dontreplyiamascript@uis.edu"
$To = "btrut2@uis.edu"
$subject = "Mobile users syncing through OWA in the last $daysold day(s)"
$msg = new-object Net.Mail.MailMessage($from,$to,$subject,$body)	
$msg.IsBodyHTML = $true
$mailer.send($msg)

clear-variable logfiles
clear-variable servers
clear-variable daysold