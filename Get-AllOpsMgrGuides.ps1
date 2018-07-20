############################################################################### 
# Download all OpsMgr Guides from 
# http://www.microsoft.com/downloads/details.aspx?displaylang=en&FamilyID=19bd0eb5-7ca0-41be-8c0f-2d95fe7ec636 
# in one-go using PowerShell and Bits. 
# Remark: Use PowerShell 2.0 because it makes use of the BitsTransfer Module 
# Author: Stefan Stranger 
# v1.001 - 19/02/2010 - stefstr - initial release 
###############################################################################

$global:path = "D:\Documents\OpsManager"

Import-Module BitsTransfer #Loads the BitsTransfer Module 
Write-Host "BitsTransfer Module is loaded"

$OpsMgrGuides = @("http://download.microsoft.com/download/7/4/d/74deff5e-449f-4a6b-91dd-ffbc117869a2/Linked.Reporting.MP.xml", 
"http://download.microsoft.com/download/B/F/D/BFDD0F66-1637-4EA3-8E6E-8D03001E5E66/OM2007_AuthGuideXplat.exe", 
"http://download.microsoft.com/download/B/F/D/BFDD0F66-1637-4EA3-8E6E-8D03001E5E66/OM2007_ReportAuthoringGuide.docx", 
"http://download.microsoft.com/download/B/F/D/BFDD0F66-1637-4EA3-8E6E-8D03001E5E66/OM2007R2_CrossPlatformMPAuthoringGuide.docx", 
"http://download.microsoft.com/download/B/F/D/BFDD0F66-1637-4EA3-8E6E-8D03001E5E66/OM2007R2_CrossPlatformMPAuthoringGuide_Samples.zip", 
"http://download.microsoft.com/download/B/F/D/BFDD0F66-1637-4EA3-8E6E-8D03001E5E66/OM2007R2_CrossPlatformMPAuthoringGuide_Samples.zip", 
"http://download.microsoft.com/download/B/F/D/BFDD0F66-1637-4EA3-8E6E-8D03001E5E66/OM2007R2_DesignGuide.docx", 
"http://download.microsoft.com/download/B/F/D/BFDD0F66-1637-4EA3-8E6E-8D03001E5E66/OM2007R2_DeploymentGuide.docx", 
"http://download.microsoft.com/download/B/F/D/BFDD0F66-1637-4EA3-8E6E-8D03001E5E66/OM2007R2_MPAuthoringGuide.docx", 
"http://download.microsoft.com/download/B/F/D/BFDD0F66-1637-4EA3-8E6E-8D03001E5E66/OM2007R2_MPModuleReference.docx", 
"http://download.microsoft.com/download/B/F/D/BFDD0F66-1637-4EA3-8E6E-8D03001E5E66/OM2007R2_OperationsAdministratorsGuide.docx", 
"http://download.microsoft.com/download/B/F/D/BFDD0F66-1637-4EA3-8E6E-8D03001E5E66/OM2007R2_OperationsUsersGuide.docx", 
"http://download.microsoft.com/download/B/F/D/BFDD0F66-1637-4EA3-8E6E-8D03001E5E66/OM2007R2_SecurityGuide.docx", 
"http://download.microsoft.com/download/B/F/D/BFDD0F66-1637-4EA3-8E6E-8D03001E5E66/OM2007R2_UpgradeGuide.docx")

Foreach ($OpsMgrGuide in $OpsMgrGuides) { Start-BitsTransfer $OpsMgrGuide $path} 
Write-Host "OpsMgr Guides are downloaded to $path"