#Script used to fiund all accounts ahwihc are inactive in Active Directory and move them to a specific OU and disable them 
#Customise the script with the source serach OU and desitnation OU to move the accounts, and specify the number of days the computer 
#must have been inactive for - suggested value is 60 days.  
 
#Script uses quest powershell commandlets which can be downloaded for free from quest website 
# http://www.quest.com/powershell/activeroles-server.aspx 
 
#Specify the OU you want to search for inactive accounts 
 
    $SearchOU=“DC=domain,DC=local" 
 
#Specify the OU you want to move your inactive computer accounts to 
 
    $DestinationOU=“OU=To be Deleted Computers,OU=OUName,DC=domain,DC=local" 
 
#Specify the number of days that computers have been inactive for 
 
    $NumOfDaysInactiveFor = 365 
     
#Specify the description to set on the computer account 
 
    $Today = Get-Date 
     
    $Description = "Account disabled due to inactivity on $Today" 
 
#DO NOT MODIFY BELOW THIS LINE 
 
Get-QADComputer -InactiveFor $NumOfDaysInactiveFor -SizeLimit 0 -SearchRoot $searchOU -IncludedProperties ParentContainerDN | foreach {  
 
    $computer = $_.ComputerName 
    $SourceOU = $_.DN 
     
    #Remove the commented # from the next line if you want to set the description to be the source OU 
    #$Description = "SourceOU was $SourceOu" 
     
    Write-Host $computer
	
	# Uncomment these to actually move computer accounts and disable them:
	
	#Set-QADComputer $computer -Description $Description 
    #Disable-QADComputer $computer 
    #Move-QADObject $computer -NewParentContainer $destinationOU  
     
 
 
}
