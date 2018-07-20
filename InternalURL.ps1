#InternalURL.ps1
$urlpath = Read-Host "Type internal Client Access FQDN starting with http:// or https://"
Set-AutodiscoverVirtualDirectory -Identity "UISCAS1\Autodiscover (Default Web Site)" –internalurl “$urlpath/autodiscover/autodiscover.xml”
Set-AutodiscoverVirtualDirectory -Identity "UISCAS2\Autodiscover (Default Web Site)" –internalurl “$urlpath/autodiscover/autodiscover.xml”
Set-ClientAccessServer –Identity "UISCAS1" –AutodiscoverServiceInternalUri “$urlpath/autodiscover/autodiscover.xml”
Set-ClientAccessServer –Identity "UISCAS2" –AutodiscoverServiceInternalUri “$urlpath/autodiscover/autodiscover.xml”
Set-webservicesvirtualdirectory –Identity "UISCAS1\EWS (Default Web Site)" –internalurl “$urlpath/ews/exchange.asmx”
Set-webservicesvirtualdirectory –Identity "UISCAS2\EWS (Default Web Site)" –internalurl “$urlpath/ews/exchange.asmx”
Set-oabvirtualdirectory –Identity "UISCAS1\OAB (Default Web Site)" –internalurl “$urlpath/oab”
Set-oabvirtualdirectory –Identity "UISCAS2\OAB (Default Web Site)" –internalurl “$urlpath/oab”
Set-owavirtualdirectory –Identity "UISCAS1\owa (Default Web Site)" –internalurl “$urlpath/owa”
Set-owavirtualdirectory –Identity "UISCAS2\owa (Default Web Site)" –internalurl “$urlpath/owa”
Set-ecpvirtualdirectory –Identity "UISCAS1\ecp (Default Web Site)" –internalurl “$urlpath/ecp”
Set-ecpvirtualdirectory –Identity "UISCAS2\ecp (Default Web Site)" –internalurl “$urlpath/ecp”
Set-ActiveSyncVirtualDirectory -Identity "UISCAS1\Microsoft-Server-ActiveSync (Default Web Site)" -InternalUrl "$urlpath/Microsoft-Server-ActiveSync"
Set-ActiveSyncVirtualDirectory -Identity "UISCAS2\Microsoft-Server-ActiveSync (Default Web Site)" -InternalUrl "$urlpath/Microsoft-Server-ActiveSync"
#get commands to  to doublecheck the config
get-AutodiscoverVirtualDirectory | ft identity,internalurl
get-ClientAccessServer | ft identity,AutodiscoverServiceInternalUri
get-webservicesvirtualdirectory | ft identity,internalurl
get-oabvirtualdirectory | ft identity,internalurl
get-owavirtualdirectory | ft identity,internalurl
get-ecpvirtualdirectory | ft identity,internalurl
get-ActiveSyncVirtualDirectory | ft identity,internalurl