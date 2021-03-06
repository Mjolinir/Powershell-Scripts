#
# Requires Quest Active Roles http://www.quest.com/powershell/activeroles-server.aspx
# For connecting to Foreign domain
#
#
# A Simple menu system for managing multiple domains
# this is the top half.  The fields in each section should make sense
# Field #1 is the name of the NT domain
# Field #2 is the name of the Domain Controller
# Field #3 is the IP address of the Domain Controller
# Field #4 is an account that has credentials in the Domain specified in field #1
# 
# If you need to add more domains just copy this line below and replace the "Field#" with
# the appropriate data and add it to the end of the last entry of $Domain List
#
# $DomainList += ,("FAKEDOMAIN","FAKEDOMAINCONTROLLER","0.0.0.0","SomeFakeAdministratorAccount")
#,
$DomainList = ("DOM1","dom1dc1","10.101.10.36","Administrator"),("DOM1CORE","dom1core1","10.101.10.35","Administrator")
$DomainList += ,("DOM2","dom2dc1","10.109.60.1","Administrator")
$DomainList += ,("DOM3","dom3dc1","10.101.10.125","Administrator")
#
# Very simple menu system, nothing fancy. List the Domains.   
#
Do
{
# Boolean Variable (True/False) to set when the loop is done
$DONE=$FALSE

# There is probably a more direct way, but I cheated and told
# the Loop to just Count up my Domains. :{P
$CountDomains=0

# Echo the information to the screen

WRITE-HOST 'Which Domain are we managing Today?'
WRITE-HOST '-----------------------------------'
WRITE-HOST ''


FOREACH ($Domain in $DomainList)
{
Write-Host $CountDomains, $Domain[0]
$CountDomains++
}

# Get the Domain number to work with.  The First is always '0'
#
# Don't finish until you've got a correct entry
#
$Choice=READ-HOST '( 0 - '($CountDomains-1)')'
IF ($Choice -gt 0 -and $Choice -lt $CountDomains)
    { $DONE=$TRUE }
ELSE
    { $DONE=$FALSE ; Write-Host 'Please Make a Correct Selection' }
}
# When the $DONE Variable contains a Boolean $TRUE the loop ends.
Until ($DONE)

#
# We're going to pre-populate the "Credential box" but not the password
# The $Choice was from the prompt before this.  $Choice will reflect which
# member of $domainlist you're working on.
# 
# Accessing $DomainList[0][2] will access the FIRST member of the Domain list
# and the 3rd property of that record.  The '+' allows us to join two pieces together
# to let them be treated as one.  Putting the information within a set of ( ) keeps
# it Cleaner to view but also tells Powershell that "Everything here is MINE, don't mix
# it up with the rest of this line!" 
#
$CREDS=Get-Credential -Credential ($DomainList[$Choice][0]+'\'+$DomainList[$Choice][3])
#
# Connect to the Foreign domain with the Supplied credentials
#
Connect-QADSERVICE ($Domainlist[$Choice][2]+':389') -credential $CREDS
#
# Everything below here is up to you.  Take note if all you want is to have this script prompt
# for Credentials and connect you to the foreign Domain?  DONE! :)
# You can manually run GET-QADUSER and various commandlets manually at this point
#
# Future goodies to be added by Powershell people :)
