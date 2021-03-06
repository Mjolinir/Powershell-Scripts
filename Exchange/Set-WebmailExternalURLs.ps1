write-host "Updating Exchange Web Services Virtual Directory External URL..." -foregroundcolor Yellow
Get-WebServicesVirtualDirectory | Set-WebServicesVirtualDirectory -ExternalUrl https://webmail.uis.edu/ews/exchange.asmx
write-host "Updating Exchange Control Panel Virtual Directory External URL..." -foregroundcolor Yellow
Get-EcpVirtualDirectory | Set-EcpVirtualDirectory -ExternalUrl https://webmail.uis.edu/ecp
write-host "Updating Exchange ActiveSync Virtual Directory External URL..." -foregroundcolor Yellow
Get-ActiveSyncVirtualDirectory | Set-ActiveSyncVirtualDirectory -ExternalUrl https://webmail.uis.edu/Microsoft-Server-ActiveSync
write-host "Updating Exchange Offline Address Book Virtual Directory External URL..." -foregroundcolor Yellow
Get-OabVirtualDirectory | Set-OabVirtualDirectory -ExternalUrl https://webmail.uis.edu/OAB
write-host "Updating Exchange Outlook Web Access Virtual Directory External URLs..." -foregroundcolor Yellow
Get-OwaVirtualDirectory | Set-OwaVirtualDirectory -ExternalUrl https://webmail.uis.edu/owa -Exchange2003Url https://webmail2003.uis.edu/exchange

Get-WebServicesVirtualDirectory | select-object Server,ExternalUrl
Get-EcpVirtualDirectory | select-object Server,ExternalUrl
Get-ActiveSyncVirtualDirectory | select-object Server,ExternalUrl
Get-OabVirtualDirectory | select-object Server,ExternalUrl
Get-OwaVirtualDirectory | select-object Server,ExternalUrl,Exchange2003Url