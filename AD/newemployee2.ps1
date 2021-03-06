########################################################################################
#
#  New employee netid/email account creation from Web Netid Activation Page
#
#  This program is run by Netid Activation web page. Accepts input parameters, creates
#  user account in active directory, mailbox enables the account, and adds them to
#  designated groups. 
#
#  Requires Exchange 2010 Management Tools and ActiveDirectory PowerShell module 
#
########################################################################################
#
#  Script name:   newemployee2.ps1
#  Created on:    04/14/2011
#  Author:        Truter, Vermie
#  Purpose:       
#  History:       04/14/2011 - initial creation
#
########################################################################################

# Input paramaters from Netid Activation web page. Netid, firstname, middlename,lastname,
# UIN, Birthdate. The word "empty" is sent as a placeholder if a parameter is Null or empty. 

$strMDB = "Employee20"
$strNetid = $args[0]
$strFname = $args[1]
$strMname = $args[2]
$strLname = $args[3]
$strUIN = $args[4]
$strBirthdate = $args[5]

# Set variables that were not input parameters.

$strUserDN = "ou=UIS Users,DC=uisad,DC=uis,DC=edu"
$strPrincipalName = $strNetid + "@uisad.uis.edu"
$strUserCN = "CN=" + $strNetid + "," + $strUserDN
$strDefaultpassword = ("UISpw" + $strBirthdate)
$strSecurepassword = ConvertTo-SecureString -AsPlainText -Force -String $strDefaultpassword
$strEmployee = "E"

If ($strMname = "empty") {
$strMname = " "
$strDisplayName = $strLname + ", " + $strFName }
Else {
$strDisplayName = $strLname + ", " + $strFName + " " + $strMname }

# Create account and Exchange 2010 mailbox.
try {
   New-Mailbox -DomainController uisdc02 -Name $strnetid -Alias $strnetid -OrganizationalUnit 'uisad.uis.edu/UIS Users' -UserPrincipalName $strPrincipalName -SamAccountName $strnetid -FirstName $strFname -Initials $strMname -LastName $strLname -DisplayName $strDisplayName -Password $strSecurepassword -ResetPasswordOnNextLogon $true -Database $strMDB
}
catch {
   write-host "Error 1001: User" $strnetid " already exists in AD."
   exit 1001 }

# Modify default attributes
Import-Module ActiveDirectory
try {
   $strADO = "CN=" + $strNetid + ",OU=UIS Users,DC=uisad,DC=uis,DC=edu"
   Get-ADObject -Server uisdc02 -Identity $strADO | Set-ADObject -Replace @{"extensionAttribute1"=[string] $strUIN}
   Get-ADObject -Server uisdc02 -Identity $strADO | Set-ADObject -Replace @{"extensionAttribute2"=[string] $strBirthdate}
   Get-ADObject -Server uisdc02 -Identity $strADO | Set-ADObject -Replace @{"extensionAttribute3"=$strDefaultpassword}
   Get-ADObject -Server uisdc02 -Identity $strADO | Set-ADObject -Replace @{"extensionAttribute4"=$strEmployee} }
catch {
   write-host "Error 1002: Could not modify user attributes."
   exit 1002 }

# Add new user to UIS Employee - Official Information DL group
try {
   $strDLGroupCN = "CN=UIS Employee - Official Information DL,OU=Groups,DC=uisad,DC=uis,DC=edu"
   $strDLGroupCN2 = "CN=CampusAnnouncementsDL,OU=DL,OU=Groups,DC=uisad,DC=uis,DC=edu"
   Add-ADGroupMember -Server uisdc02 -Identity $strDLGroupCN -Member $strnetid
   Add-ADGroupMember -Server uisdc02 -Identity $strDLGroupCN2 -Member $strnetid }
catch {
   write-host "Error 1003: Could not modify user group membership."
   exit 1003 }

write-host ""
write-host "Completed successfully."
exit 1010