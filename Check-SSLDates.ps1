#########################################################################
#                                                                       #
#                            URL's to Monitor                           #
#                                                                       #
#########################################################################
$SSL_URL = @(
'https://ethos.valdosta.edu:9443',
'https://watchtower.valdosta.edu',
'https://highseat.valdosta.edu',
'https://emsweb.valdosta.edu',
'https://calendar.valdosta.edu'

) #Use the Format of first URL to include monitor website's to montior
#########################################################################
#                                                                       #
#                             SMTP Settings                             #
#                                                                       #
#########################################################################
$SSL_To = 'btruter@valdosta.edu'
$SSL_From = 'powershell@valdosta.edu'
$SSL_SMTP = 'smtp.valdosta.edu'
#########################################################################
#                                                                       #
#                            Create Array's                             #
#                                                                       #
#########################################################################
$CurrentSSL = @()
$ExpiringSSL = @()
#########################################################################
#                                                                       #
#                       Start the SSL Check                             #
#                                                                       #
#########################################################################
Foreach ($site in $SSL_URL) {

$minimumCertAgeDays = 30 # Enter how many days left on the certificate before considering this monitor 'down'

$timeoutMilliseconds = 30000

$minimumCertAgeDays = 30 #Enter how many days left on the certificate before considering this monitor 'down'

$timeoutMilliseconds = 30000

[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

$req = [Net.HttpWebRequest]::Create($site)

$req.Timeout = $timeoutMilliseconds

$req.GetResponse()

[datetime]$expiration = (Get-Date $req.ServicePoint.Certificate.GetExpirationDateString())

[int]$certExpiresIn = ($expiration - $(get-date)).Days
#########################################################################
#                                                                       #
#                      Check for Date Range                             #
#                                                                       #
#########################################################################

    if ($certExpiresIn -gt $minimumCertAgeDays){
    "Cert for site $site expires in $certExpiresIn days [on $expiration]"

    $Current = @"
    URL,DaysToExpiration,ExpirationDate
    "",""
    $site,$certExpiresIn,$expiration
"@ | ConvertFrom-Csv
    $CurrentSSL += $Current

    ###############
    #  HTML Chart #
    ###############
    $SSL_s = "<style>"
    $SSL_s = $SSL_s + "BODY{background-color:white;}"
    $SSL_s = $SSL_s + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
    $SSL_s = $SSL_s + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:thistle}"
    $SSL_s = $SSL_s + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:palegoldenrod}"
    $SSL_s = $SSL_s + "</style>"
    $SSL_Body = $CurrentSSL | ConvertTo-Html -Head $SSL_s -Body "<H2>Current SSL Certificates</H2>" | Out-String
    }

else

    {

    "Cert for site $site expires in $certExpiresIn days [on $expiration] Threshold is $minimumCertAgeDays days."

    $Expiring = @"
    URL,DaysToExpiration,ExpirationDate
    "",""
    $site,$certExpiresIn,$expiration
"@ | ConvertFrom-Csv
    $ExpiringSSL += $Expiring


    ##############
    # HTML Chart #
    ##############
    $SSL_s = "<style>"
    $SSL_s = $SSL_s + "BODY{background-color:white;}"
    $SSL_s = $SSL_s + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
    $SSL_s = $SSL_s + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:thistle}"
    $SSL_s = $SSL_s + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:palegoldenrod}"
    $SSL_s = $SSL_s + "</style>"
    $SSL_Body = $ExpiringSSL | ConvertTo-Html -Head $SSL_s -Body "<H2>Expiring SSL Certificates</H2>" | Out-String
}
}
#########################################################################
#                                                                       #
#                    Send SMTP Notification                             #
#                                                                       #
#########################################################################
#if ($CurrentSSL.Count -gt 1){
#
#    Send-MailMessage -SmtpServer $SSL_SMTP -To $SSL_To -From $SSL_From -Subject 'Current SSL Info' -Body $SSL_Body -BodyAsHtml
#
#    }
#########################################################################
#                                                                       #
#                    Send SMTP Notification                             #
#                                                                       #
#########################################################################
If ($ExpiringSSL.Count -gt 1) {
    
    Send-MailMessage -SmtpServer $SSL_SMTP -To $SSL_To -From $SSL_From -Subject 'Expiring SSL Certificates' -Body $SSL_Body -BodyAsHtml
    
    }
