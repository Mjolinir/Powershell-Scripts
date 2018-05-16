# AD_Health.PS1
# Script By: Jon Knapp
#
# ACtive Directory Health Script
#
# This script creates a logfile to collect the out put of dcdiag and repadmin tools and calls a second script to get info on the DC's
#
# Great tool for troubleshooting!

function WMIDateStringToDate($Bootup) {  
    [System.Management.ManagementDateTimeconverter]::ToDateTime($Bootup)  
}  

New-Item C:\health.log -type file -force
$logfile = "C:\health.log"

function AllDCs
{
    $objRootDSE = New-Object System.DirectoryServices.DirectoryEntry('LDAP://rootDSE')
    $objSites = New-Object System.DirectoryServices.DirectoryEntry('LDAP://CN=Sites,' + $objRootDSE.configurationNamingContext)

    $strFilter = "(&(objectCategory=Server)(dNSHostName=*))"
    $objSearcher = New-Object System.DirectoryServices.DirectorySearcher
    $objSearcher.SearchRoot = $objSites
    $objSearcher.PageSize = 1000
    $objSearcher.Filter = $strFilter
    $objSearcher.SearchScope = "Subtree"

    $colProplist = "dNSHostname", "distinguishedName"
    foreach ($i in $colPropList)
    {
	[void] $objSearcher.PropertiesToLoad.Add($i)
    }

    $colResults = $objSearcher.FindAll()

    foreach ($objResult in $colResults)
    {
	$objItem = $objResult.Properties
	$objNTDS = New-Object System.DirectoryServices.DirectoryEntry('LDAP://CN=NTDS Settings,' + $objItem.distinguishedname)
	if ($objNTDS.name -ne $null) { 
		$objItem.dnshostname 
	}
    }
}

foreach ($dc in AllDCs)
{
    "==== Processing $dc" 
    "==== Processing $dc" 	>> $logfile
    "" >> $logfile
    
    # get uptime for the Dc's
    
    $computers = Get-WMIObject -class Win32_OperatingSystem -computer $dc  
  
    foreach ($system in $computers) {  
       $Bootup = $system.LastBootUpTime  
       $LastBootUpTime = WMIDateStringToDate $bootup  
       $now = Get-Date
       $Uptime = $now - $lastBootUpTime  
       $d = $Uptime.Days  
       $h = $Uptime.Hours  
       $m = $uptime.Minutes  
       $ms= $uptime.Milliseconds  
  
       "System Up for: {0} days, {1} hours, {2}.{3} minutes" -f $d,$h,$m,$ms >> $logfile
    }   
    
    "" >> $logfile
    
    # Now run the DC_Info.ps1 script
     
    $job = Start-Job -filepath C:\DC_info.ps1 -ArgumentList $dc
    Wait-Job $job
    Receive-Job $job
       
    "" >> $logfile
    
    # Run the diagnostic tools
    
    "======  Begin tool Dcdiag.exe /test:dns /v /s:$dc   ========================" >> $logfile
    Dcdiag.exe /test:dns /v /s:$dc >> $logfile
    "======  Begin tool Dcdiag.exe /v /s:$dc   ==================================" >> $logfile       
    Dcdiag.exe /v /s:$dc >> $logfile
    "======  Begin tool Repadmin /kcc $dc   =====================================" >> $logfile
    Repadmin /kcc $dc 		>> $logfile
    "======  Begin tool Repadmin /showrepl   ====================================" >> $logfile
    Repadmin /showrepl >> $logfile
    "======  Begin tool Repadmin /replsummary  ==================================" >> $logfile
    Repadmin /replsummary /errorsonly >> $logfile
    
    # the lines below can be uncommented and run if you want to force a sync to all DC's
    #"======  Begin tool Repadmin /syncall /A /e $dc   ==========================" >> $logfile
    #Repadmin /syncall /A /e $dc >> $logfile
    
    "" 				>> $logfile
}


