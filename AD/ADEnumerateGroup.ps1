#This code demonstrates how to search and retrieve group object information from Active Directory 
#without adding any plug-ins.
#
#To run this script within your environment you should only need to copy and paste this script into
#either Windows Powershell ISE or PowerGUI Script Editor,(http://powergui.org) with the following
#changes to the script which I have numbered below.  
#  1.) Change the line, ($strGroupName = "YourGroupName"), so that you have real group name listed.
#  2.) You may also need to install Microsoft Update "http://support.microsoft.com/kb/968930".
#
#
#You can also search in a specific Active Directory OU's By changing the sections of 
#code that have "System.DirectoryServices.DirectoryEntry" listed within them.  
#From: "$objDomain = New-Object System.DirectoryServices.DirectoryEntry"
#To: "$objDomain = New-Object System.DirectoryServices.DirectoryEntry("LDAP://OU=ASDF,DC=asdf,DC=asdf")"

[int]$Global:intTemp = 0
Function GetNested
{
  [string]$strGroupName = $args[0].Name
  $strGroupName = $strGroupName.trim()
  If ( $intTemp -eq 0 )
  {
    $GroupArray = @{$intTemp = $strGroupName}
    $intTemp++
  }
  else
  {
    If ($GroupArray.ContainsValue($strGroupName) -ne $true)
    {
      $GroupArray.add($intTemp, $strGroupName)
      $intTemp ++
      Write-Host "`t" $strGroupName
    }
    else
    {
      break 
    }
  }
  $members = $args[0].member
  If ($members -ne $Null)
  {
    foreach ($i in $members)
    {
      $objMember = New-Object System.DirectoryServices.DirectoryEntry("LDAP://"+$i)
      If ($objMember.objectCategory.Value.Contains("Group"))
      {
        GetNested $objMember
      }
    }
  }
}

$strGroupName = $args[0]
$objDomain = New-Object System.DirectoryServices.DirectoryEntry

$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$strFilter = "(&(objectCategory=Group)(name=" + $strGroupName + "))"
$objSearcher.SearchRoot = $objDomain
$objSearcher.PageSize = 1000
$objSearcher.Filter = $strFilter
$objSearcher.SearchScope = "Subtree"
$colResults = $objSearcher.FindAll()

foreach ($objResult in $colResults)
{
  $objGroup = $objResult.GetDirectoryEntry()
  "Name: " + $objGroup.name
  "Description: " + $objGroup.Description
  "Info: " + $objGroup.Info
  $objManageBy = New-Object System.DirectoryServices.DirectoryEntry("LDAP://"+$objGroup.managedBy)
  If ($objManageBy.name -ne $Null)
  {"managedBy: " + $objManageBy.name}
  else
  {"managedBy: equals nothing!!"}
  $members = $objGroup.member
  If ($members -ne $Null)
  {
    foreach ($i in $members)
    {
      $objMember = New-Object System.DirectoryServices.DirectoryEntry("LDAP://"+$i)
      $objMember.name
      If ($objMember.objectCategory.Value.Contains("Group"))
      {
        $intTemp = 0
        GetNested $objMember
      }
    }
  }
  else
  {
    "There are no members in this group"
  }		
  Write-Host
}