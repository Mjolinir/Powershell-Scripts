# ==============================================================================================
# NAME: Check-Replication
# 
# AUTHOR: Maish Saidel-Keesing
# DATE  : 27/04/2010
# 
# COMMENT: Will check the replication status and if there are failures will send an email to the
# Assigned Addresses.
# ** Requires Repadmin from the Windows resource Kit accessible in the default path **
# ==============================================================================================
 
$from = "Replication Status<administrator@domain.local>"
$to = Administrator <email@domain.local>"
#Collect the replication info
 
#Check the Replication with Repadmin
$workfile = repadmin.exe /showrepl * /csv 
$results = ConvertFrom-Csv -InputObject $workfile | where {$_.'Number of Failures' -ge 1}
 
 
#Here you set the tolerance level for the report
$results = $results | where {$_.'Number of Failures' -gt 1 }
 
if ($results -ne $null ) {
    $results = $results | select "Source DC", "Naming Context", "Destination DC" ,"Number of Failures", "Last Failure Time", "Last Success Time", "Last Failure Status" | ConvertTo-Html
    } else {
    $results = "There were no Replication Errors"
}
 
Send-MailMessage -From $from -To $to -Subject "Daily Forest Replication Status" -SmtpServer "smtp.domain.local" -BodyAsHtml ($results | Out-String)
