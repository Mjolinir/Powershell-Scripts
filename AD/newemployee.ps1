#########################################################################################
#
#  New employee netid/email account creation from Web Netid Activation Page
#
#  This program is run by Netid Activation web page. Accepts input parameters, creates
#  user account in active directory, mailbox enables the account, and adds them to
#  designated groups.
#
#########################################################################################
#
#  Script name:   newemployee.ps1
#  Created on:    04/13/2011
#  Author:        Truter, Vermie
#  Purpose:       
#  History:       04/13/2011 - Initial creation
#
#########################################################################################

## Input paramaters from Netid Activation web page. Netid, firstname, middlename,lastname,
## UIN, Birthdate. The word "empty" is sent as a placeholder if a parameter is Null or empty. 

$strNetid = $args[0]
$strFname = $args[1]
$strMname = $args[2]
$strLname = $args[3]
$strUIN = $args[4]
$strBirthdate = $args[5]

## Set variables that were not input parameters.

$strUserDN = "OU=UIS Users,DC=uisad,DC=uis,DC=edu"
$strPrincipalName = $strNetid + "@uisad.uis.edu"
$strUserCN = "CN=" + $strNetid + "," + $strUserDN
$strDLGroupCN = "CN=UIS Employee - Official Information DL,OU=Groups,DC=uisad,DC=uis,DC=edu"
$strDLGroupCN2 = "CN=CampusAnnouncementsDL,OU=DL,OU=Groups,DC=uisad,DC=uis,DC=edu"
$strDefaultpassword = ("UISpw" + $strBirthdate)
$strEmployee = "E"

If ($strMname = "empty") {
$strMname = " "
$strDisplayName = $strLname + ", " + $strFName }
Else {
$strDisplayName = $strLname + ", " + $strFName + " " + $strMname }

## Create employee account

#$domain = [ADSI] "LDAP://uisad:389/DC=uisad,DC=uis,DC=edu"
$usersOU = [ADSI] "LDAP://" + $strUserDN

$newUser = $usersOU.Create("user","CN=" + $strnetid)
$newUser.put("samAccountName", $strnetid)
$newUser.put("cn", $strnetid)
$newUser.put("givenName", $strFname)
$newUser.put("sn", $strLname)
$newUser.put("middleName", $strMname)
$newUser.put("displayName", $strDisplayName)
$newUser.put("userPrincipalname", $strPrincipalName)
$newUser.put("extensionAttribute1", $strUIN)
$newUser.put("extensionAttribute2", $strBirthdate)
$newUser.put("extensionAttribute3", $strDefaultpassword)
$newUser.put("extensionAttribute4", $strEmployee)
try {
   $newUser.SetInfo() }
catch {
   write-host "Error 1001: User" $strnetid " already exists in AD..."
   exit 1001 }

## Set password & flag to reset
$newUser.SetPassword($strDefaultpassword)
$newUser.put("pwdLastSet", 0)
$newUser.SetInfo()

## Make account active
$newUser.psbase.InvokeSet("AccountDisabled", $false)
$newUser.SetInfo()


## Setup employee email ##


$strMail = $strNetid + "@uis.edu"
$strMailnickname = $strNetid
$strHomeMDB = "CN=Employee20,CN=Databases,CN=Exchange Administrative Group (FYDIBOHF23SPDLT),CN=Administrative Groups,CN=UIS,CN=Microsoft Exchange,CN=Services,CN=Configuration,DC=uiscore,DC=uis,DC=edu"

$strHomeMTA = "CN=Microsoft MTA,CN=UISMAIL10,CN=Servers,CN=Exchange Administrative Group (FYDIBOHF23SPDLT),CN=Administrative Groups,CN=UIS,CN=Microsoft Exchange,CN=Services,CN=Configuration,DC=uiscore,DC=uis,DC=edu"

$strmsExchHomeServerName = "/o=UIS/ou=Exchange Administrative Group (FYDIBOHF23SPDLT)/cn=Configuration/cn=Servers/cn=UISMAIL10"
$strmDBUseDefaults = "TRUE"
   
$newUser.put("mail", $strMail)
$newUser.put("homeMDB", $strhomeMDB)
$newUser.put("msExchHomeServerName", $strmsExchHomeServerName)
$newUser.put("mailNickname", $strmailNickname)
$newUser.put("homeMTA", $strhomeMTA)
$newUser.put("mDBUseDefaults", $strmDBUseDefaults)
try {
   $newUser.SetInfo() }
catch {
   write-host "Error 1002: Could not create mailbox."
   exit 1002 }


## Add employee to UIS Employee - Official Information DL
try {
   #Const ADS_PROPERTY_UPDATE = 2
   #Const ADS_PROPERTY_APPEND = 3
   $objGroup = [ADSI] "LDAP://" + $strDLGroupCN
   $objGroup.PutEx 3, "member", Array($strUserCN)
   $objGroup.SetInfo()

   ## Add employee to UIS Campus Announcements
   $objGroup = [ADSI] "LDAP://" + $strDLGroupCN2
   $objGroup.PutEx 3, "member", Array($strUserCN)

   $objGroup.SetInfo() }
catch {
   write-host "Error 1002: Could not add user to designated groups"
   exit 1002 }   

exit 1010