###################################################################################################
# 
# The sample scripts are not supported under any Microsoft standard support 
# program or service. The sample scripts are provided AS IS without warranty 
# of any kind. Microsoft further disclaims all implied warranties including, without 
# limitation, any implied warranties of merchantability or of fitness for a particular 
# purpose. The entire risk arising out of the use or performance of the sample scripts 
# and documentation remains with you. In no event shall Microsoft, its authors, or 
# anyone else involved in the creation, production, or delivery of the scripts be liable 
# for any damages whatsoever (including, without limitation, damages for loss of business 
# profits, business interruption, loss of business information, or other pecuniary loss) 
# arising out of the use of or inability to use the sample scripts or documentation, 
# even if Microsoft has been advised of the possibility of such damages
#
###################################################################################################
#
# ActiveSyncReport.ps1
# Syntax Examples:
# .\ActiveSyncReport.ps1 -IISLogs "C:\inetpub\logs\LogFiles\W3SVC1" -LogparserExec "C:\Program Files (x86)\Log Parser 2.2\Logparser.exe" -ActiveSyncOutputFolder c:\EASReports -MinimumHits 1000
# .\ActiveSyncReport.ps1 -IISLogs "C:\Server1\W3SVC1","C:\Server2\W3SVC1" -LogparserExec "C:\Program Files (x86)\Log Parser 2.2\Logparser.exe" -ActiveSyncOutputFolder c:\EASReports -HTMLReport
# .\ActiveSyncReport.ps1 -IISLogs "C:\Server1\W3SVC1" -Date "12-06-2011" -LogparserExec "C:\Program Files (x86)\Log Parser 2.2\Logparser.exe" -ActiveSyncOutputFolder c:\EASReports -Hourly
# .\ActiveSyncReport.ps1 -IISLogs "C:\Server1\W3SVC1" -Date "12-06-2011" -DevideID abcdefg123 -LogparserExec "C:\Program Files (x86)\Log Parser 2.2\Logparser.exe" -ActiveSyncOutputFolder c:\EASReports -Hourly
#
# Written by Brian Drepaul <briandre@microsoft.com>
# Technical Documentation provided by Konstantin Papadakis <kpapadak@microsoft.com>
#
# IIS W3C Default Fields
# IIS 6.0
# 	date time s-sitename s-ip cs-method cs-uri-stem cs-uri-query s-port cs-username c-ip cs(User-Agent) sc-status sc-substatus sc-win32-status 
# IIS 7.0
#   date time s-ip cs-method cs-uri-stem cs-uri-query s-port cs-username c-ip cs(User-Agent) sc-status sc-substatus sc-win32-status time-taken
# IIS 7.5
#   date time s-ip cs-method cs-uri-stem cs-uri-query s-port cs-username c-ip cs(User-Agent) sc-status sc-substatus sc-win32-status time-taken

param(
	[string]$ActiveSyncOutputFolder, 	# CSV and HTML output directory
	[string]$ActiveSyncOutputPrefix, 	# Prefix a string in the file name EASyncOutputReport-
	[switch]$CreateZip=$false,																# Used with -SendEmailReport
	[int]$CreateZipSize=2,			# Used with -SendEmailReport and -CreateZip, Default is if the file is greater then 2MB
	[string]$Date,			# specify a date to parse on
	[string]$DeviceId,																		# DeviceID to parse on
	[switch]$DisableColumnDetect=$false,						# Disable the ability to add additional columns to the report that users may have enabled, Example: time-taken
	[switch]$Help,																			# Help File
	[int]$ReportBySeconds,																	# Generates the report bases in the value entered in seconds
	[switch]$Hourly,																		# Generates the report Hourly
	[switch]$HTMLReport=$false,																# Creates an HTML Report
	[string]$HTMLCSVHeaders="",		# CSV Headers to Export on in the HTML Report this will default to "DeviceID,Hits,Ping,Sync,FolderSync,DeviceType,User-Agent"
	[array]$IISLogs, 	# IIS Log Directory
	[string]$LogparserExec, # Path to LogParser.exe
	[int]$MinimumHits, 	# Hit Threshold value where the report will generate on CSV and HTML
	[switch]$SendEmailReport=$false,														# Enable Email report, $true of $false
	[string]$SMTPRecipient, 																# SMTP Recipient
	[string]$SMTPSender,																	# SMTP Sender
	[string]$SMTPServer,																	# SMTP Server
	[int]$TopHits																			# Top Hits to return Ex. TopHits 50, This cannot be used with Hourly or ReportBySeconds
)

###################################################################################################
##### Please do not modify anything below this line
###################################################################################################

# Last Updated
$builddate = "01.23.2012"

# Create a Zip file that will be used with Sending HTML Report
Function Create-Zip {
param([string]$zipfilename,[array]$files)

	# Create a new empty Zip FIle
	set-content $zipfilename ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
	(ls $zipfilename).IsReadOnly = $false	
	
	$shellApplication = new-object -com shell.application
	$zipPackage = $shellApplication.NameSpace($zipfilename)

	# Add the Zip Files
	foreach($file in $files) {
		$zipPackage.CopyHere($file)
		Start-sleep -milliseconds 500
	}
}

# Build the Log Parser Query
Function Build-LogParserQuery {
param([string]$DeviceID,[array]$in,[array]$iisFiles,[switch]$MinimumHitsQuery,[string]$out,[int]$ReportBySeconds)

	Write-Host "Building Log Parser Query..."
	# Create FROM string
	$in | % { $string += [string]$_ + "," }
	$in = $string.TrimEnd(",")
	
	if (!$DisableColumnDetect) {
		# Check to see if the IIS Log has sc-bytes, cs-bytes, time-taken
		$args = "-h -i:w3c " + "`"$(($iisFiles | select -First 1).FullName)`""
		$cmd = "& '$($LogparserExec)' $($args)"
		$results = iex $cmd
	}
	
	if ($MinimumHitsQuery) {
			
		if ([bool]($results | Select-String "LargestBytesSentToClient")) {
			Write-Host "Found LargestBytesSentToClient in the IIS Log, adding this column."
			$additionalQuery = "LargestBytesSentToClient,"
		}
		if ([bool]($results | Select-String "LargestBytesReceivedFrClient")) {
			Write-Host "Found LargestBytesReceivedFrClient in the IIS Log, adding this column."
			$additionalQuery += "LargestBytesReceivedFrClient,"
		}
		if ([bool]($results | Select-String "LongestRequestTime")) {
			Write-Host "Found LongestRequestTime in the IIS Log, adding this column."
			$additionalQuery += "LongestRequestTime(s),"
		}
		if ([bool]($results | Select-String "AVGRequestTime")) {
			Write-Host "Found AVGRequestTime in the IIS Log, adding this column."
			$additionalQuery += "AVGRequestTime(s),"
		}
		if ([bool]($results | Select-String "ServerName")) {
			Write-Host "Found ServerName in the IIS Log, adding this column."
			$additionalQuery += "ServerName,"
		}

		$query = @"
SELECT

"@
		if ($ReportBySeconds) {
			$query += @"
		Date,

"@
		}
		$query += @"
		User,
		DeviceId,
		DeviceType,
		User-Agent,
		Hits,
		Ping,
		Sync,
		FolderSync,
		SendMail,
		SmartReply,
		MeetingResponse,
		GetAttachment,
		SmartForward,
		GetHierarchy,
		CreateCollection,
		DeleteCollection,
		MoveCollection,
		FolderCreate, 
		FolderDelete,
		FolderUpdate,
		MoveItems,
		GetItemEstimate,
		Search, 
		Settings,
		ItemOperations, 
		Provision, 
		ResolveRecipients,
		ValidateCert,
		$additionalQuery
		/* Common Status Codes - http://msdn.microsoft.com/en-us/library/ee218647(v=exchg.80).aspx */
		InvalidContent,
		ServerError,
		ServerErrorRetryLater,
		MailboxQuotaExceeded,
		DeviceIsBlockedForThisUser ,
		AccessDenied,
		SyncStateNotFound,
		DeviceNotFullyProvisionable,
		DeviceNotProvisioned,
		ItemNotFound,
		UserDisabledForSync,
		/* End Common Status Codes */
		TooManyJobsQueued,
		/* 	More Info on TooManyJobsQueued
			Unable to connect using Exchange ActiveSync due to Exchange resource consumption
			http://support.microsoft.com/kb/2469722 
		*/
		OverBudget,
		IIS_5xx,
		IIS_4xx,
		IIS_503,
		/*
			The server is currently unable to handle the request due to a
			temporary overloading or maintenance of the server. The implication
			is that this is a temporary condition which will be alleviated after
			some delay. If known, the length of the delay MAY be indicated in a
			Retry-After header. If no Retry-After is given, the client SHOULD
			handle the response as it would for a 500 response.

			Note: The existence of the 503 status code does not imply that a
			server must use it when becoming overloaded. Some servers may wish
			to simply refuse the connection.

			http://tools.ietf.org/html/rfc2616#section-10.5.4
		*/
		IIS_507, 
		/* 
			The 507 (Insufficient Storage) status code means the method could not
			be performed on the resource because the server is unable to store
			the representation needed to successfully complete the request.  This
			condition is considered to be temporary.  If the request that
			received this status code was the result of a user action, the
			request MUST NOT be repeated until it is requested by a separate user
			action.
			http://tools.ietf.org/html/rfc4918#section-11.5
		*/
		IIS_409,
		/* 
			409 (Conflict) - A collection cannot be made at the Request-URI until
			one or more intermediate collections have been created.  The server
			MUST NOT create those intermediate collections automatically.
			http://tools.ietf.org/html/rfc4918#section-9.8.5
		*/
		IIS_451
		/*
			Exchange 2007 returns an HTTP 451 response to an Exchange ActiveSync 
			client when it determines that the device should be using a "better" 
			Client Access server for ActiveSync connectivity. The logic used to 
			determine if a Client Access server is "better" for a device to be 
			using is based on Active Directory sites and whether a Client Access
			server is considered "Internet-facing." If the ExternalUrl property 
			on the Microsoft-Server-ActiveSync virtual directory is specified, 
			then that Client Access server is considered to be "Internet-Facing"
			for Microsoft ActiveSync connectivity.
			http://technet.microsoft.com/en-us/library/dd439372(EXCHG.80).aspx
		*/
INTO '$out'
FROM '$in'
WHERE Hits >= $MinimumHits

"@
	}
	else {
		$query = @"
SELECT

"@
			if ($TopHits) {
		$query += "TOP $TopHits"
		}
		# Check the $results to see if the W3C log has additional fields that are useful
		if ([bool]($results | Select-String "sc-bytes")) {
			Write-Host "Found sc-bytes in the IIS Log, adding this column."
			$additionalQuery = "MAX(sc-bytes)						AS LargestBytesSentToClient,"
		}
		if ([bool]($results | Select-String "cs-bytes")) {
			Write-Host "Found cs-bytes in the IIS Log, adding this column."
			$additionalQuery += "MAX(cs-bytes)						AS LargestBytesReceivedFrClient,"
		}
		if ([bool]($results | Select-String "time-taken")) {
			Write-Host "Found time-taken in the IIS Log, adding this column."
			$additionalQuery += "DIV(MAX(time-taken),1000)			AS LongestRequestTime(s),"
			$additionalQuery += "DIV(AVG(time-taken),1000)			AS AVGRequestTime(s),"
		}
		
		if ($ReportBySeconds) {
			$query += @"
			QUANTIZE(TO_TIMESTAMP(date, time), $ReportBySeconds) 	AS Date,
			
"@
		}
		
		$query += @"
			TO_LOWERCASE (cs-username) 			AS User,
			MyDeviceId	                		AS DeviceId,
			MyDeviceType                   		AS DeviceType,
			cs(User-Agent)	                	AS User-Agent,
			COUNT(*)                         	AS Hits,
			SUM (MyPing)						AS Ping,
			SUM (MySync)                       	AS Sync,
			SUM (MyFolderSync)                  AS FolderSync,
			SUM (MySendMail)                    AS SendMail,
			SUM (MySmartReply)                  AS SmartReply,
			SUM (MyMeetingResponse)         	AS MeetingResponse,
			SUM (MyGetAttachment)             	AS GetAttachment,
			SUM (MySmartForward)				AS SmartForward,
			SUM (MyGetHierarchy)				AS GetHierarchy,
			SUM (MyCreateCollection)			AS CreateCollection,
			SUM (MyDeleteCollection)			AS DeleteCollection,
			SUM (MyMoveCollection)				AS MoveCollection,
			SUM (MyFolderCreate)				AS FolderCreate, 
			SUM (MyFolderDelete)				AS FolderDelete,
			SUM (MyFolderUpdate)				AS FolderUpdate,
			SUM (MyMoveItems)					AS MoveItems,
			SUM (MyGetItemEstimate)				AS GetItemEstimate,
			SUM (MySearch)						AS Search,
			SUM (MySettings)					AS Settings,
			SUM (MyItemOperations)				AS ItemOperations, 
			SUM (MyProvision)					AS Provision, 
			SUM (MyResolveRecipients)			AS ResolveRecipients,
			SUM (MyValidateCert)				AS ValidateCert,
			$additionalQuery
			SUM (MyInvalidContent)				AS InvalidContent,
			SUM (MyServerError)					AS ServerError,
			SUM (MyServerErrorRetryLater)		AS ServerErrorRetryLater,
			SUM (MyMailboxQuotaExceeded)		AS MailboxQuotaExceeded,
			SUM (MyDeviceIsBlockedForThisUser)	AS DeviceIsBlockedForThisUser, 
			SUM (MyAccessDenied)				AS AccessDenied,
			SUM (MySyncStateNotFound)			AS SyncStateNotFound,
			SUM (MyDeviceNotFullyProvisionable)	AS DeviceNotFullyProvisionable,
			SUM (MyDeviceNotProvisioned)		AS DeviceNotProvisioned,
			SUM (MyItemNotFound)				AS ItemNotFound,
			SUM (ADD(MyDisabledForSyncCnt1,MyDisabledForSyncCnt2))                      AS UserDisabledForSync,
			SUM (MyTooManyJobsQueued)			AS TooManyJobsQueued,
			SUM (MyOverBudget)					AS OverBudget,
			SUM (MyIIS_5xx)						AS IIS_5xx,
			SUM (MyIIS_4xx)						AS IIS_4xx,
			SUM (MyIIS_503)						AS IIS_503,
			SUM (MyIIS_507)						AS IIS_507,
			SUM (MyIIS_409)						AS IIS_409,
			SUM (MyIIS_451)						AS IIS_451

USING
			EXTRACT_VALUE(cs-uri-query,'DeviceType') AS MyDeviceType,
			EXTRACT_VALUE(cs-uri-query,'DeviceId') AS MyDeviceId,
			EXTRACT_VALUE(cs-uri-query,'User-Agent') AS MyUser-Agent,
			EXTRACT_VALUE(cs-uri-query,'Cmd') AS MyCmd,
			EXTRACT_VALUE(cs-uri-query,'Log') AS MyLog,
			
			SUBSTR(TO_STRING(sc-status),0,1) AS StatusCode,
			
			/* Getting any error's that might be in MyLog */
			SUBSTR (MyLog, ADD (INDEX_OF (MyLog, 'Error:'), 6),
			INDEX_OF (SUBSTR(MyLog, ADD (INDEX_OF (MyLog, 'Error:'), 6)), '_')) AS MyLogError,
												
			/* Detect if ActiveSync is disabled for User */
			/* Exchange 2003 */
            CASE EXTRACT_TOKEN(MyLog,0,':')
                                    WHEN 'VNATNASNC' THEN 1
                                    ELSE 0
            END AS MyDisabledForSyncCnt1,
			
			/* Exchange 2010 */
            CASE MyLogError
                                    WHEN 'UserDisabledForSync' THEN 1
                                    ELSE 0
            END AS MyDisabledForSyncCnt2,
			
			/* END -- Detecting if ActiveSync is disabled for User */
					
            CASE MyLogError
                                    WHEN 'OverBudget' THEN 1
                                    ELSE 0
            END AS MyOverBudget,
			
            CASE MyLogError
                                    WHEN 'TooManyJobsQueued' THEN 1
                                    ELSE 0
            END AS MyTooManyJobsQueued,
			
            CASE MyLogError
                                    WHEN 'InvalidContent' THEN 1
                                    ELSE 0
            END AS MyInvalidContent,
			
			CASE MyLogError
                                    WHEN 'ServerError' THEN 1
                                    ELSE 0
            END AS MyServerError,
			
			CASE MyLogError
                                    WHEN 'ServerErrorRetryLater' THEN 1
                                    ELSE 0
            END AS MyServerErrorRetryLater,
			
			CASE MyLogError
                                    WHEN 'MailboxQuotaExceeded' THEN 1
                                    ELSE 0
            END AS MyMailboxQuotaExceeded,
			
			CASE MyLogError
                                    WHEN 'DeviceIsBlockedForThisUser' THEN 1
                                    ELSE 0
            END AS MyDeviceIsBlockedForThisUser,
			
			CASE MyLogError
                                    WHEN 'AccessDenied' THEN 1
                                    ELSE 0
            END AS MyAccessDenied,
			
			CASE MyLogError
                                    WHEN 'SyncStateNotFound' THEN 1
                                    ELSE 0
            END AS MySyncStateNotFound,
			
			CASE MyLogError
                                    WHEN 'DeviceNotFullyProvisionable' THEN 1
                                    ELSE 0
            END AS MyDeviceNotFullyProvisionable,
			
			CASE MyLogError
                                    WHEN 'DeviceNotProvisioned' THEN 1
                                    ELSE 0
            END AS MyDeviceNotProvisioned,
			
			CASE MyLogError
                                    WHEN 'ItemNotFound' THEN 1
                                    ELSE 0
            END AS MyItemNotFound,
 			
			CASE StatusCode
						WHEN '5' THEN 1 
						ELSE 0
			END AS MyIIS_5xx, 
			
			CASE StatusCode
						WHEN '4' THEN 1 
						ELSE 0
			END AS MyIIS_4xx, 

			CASE TO_STRING(sc-status)
						WHEN '503' THEN 1 
						ELSE 0
			END AS MyIIS_503, 
			
			CASE TO_STRING(sc-status)
						WHEN '507' THEN 1 
						ELSE 0
			END AS MyIIS_507, 
			
			CASE TO_STRING(sc-status)
						WHEN '409' THEN 1 
						ELSE 0
			END AS MyIIS_409, 

			CASE TO_STRING(sc-status)
						WHEN '451' THEN 1 
						ELSE 0
			END AS MyIIS_451, 
			
            CASE MyCmd
                        WHEN 'Sync' THEN 1
                        ELSE 0
            END AS MySync,
          
            CASE MyCmd
                        WHEN 'Ping' THEN 1
                        ELSE 0
            END AS MyPing,

            CASE MyCmd
                        WHEN 'SendMail' THEN 1
                        ELSE 0
            END AS MySendMail,

            CASE MyCmd
                        WHEN 'SmartReply' THEN 1
                        ELSE 0
            END AS MySmartReply,

            CASE MyCmd
                        WHEN 'MeetingResponse' THEN 1
                        ELSE 0
            END AS MyMeetingResponse,

            CASE MyCmd
                        WHEN 'GetAttachment' THEN 1
                        ELSE 0
            END AS MyGetAttachment,

            CASE MyCmd
                        WHEN 'FolderSync' THEN 1
                        ELSE 0
						
            END AS MyFolderSync,
			
			CASE MyCmd
                        WHEN 'SmartFoward' THEN 1
                        ELSE 0
            END AS MySmartForward,
			
			CASE MyCmd
                        WHEN 'GetHierarchy' THEN 1
                        ELSE 0
            END AS MyGetHierarchy,
			
			CASE MyCmd
                        WHEN 'CreateCollection' THEN 1
                        ELSE 0
            END AS MyCreateCollection,
			
			CASE MyCmd
                        WHEN 'DeleteCollection' THEN 1
                        ELSE 0
            END AS MyDeleteCollection,		
			
			CASE MyCmd
                        WHEN 'MoveCollection' THEN 1
                        ELSE 0
            END AS MyMoveCollection,
			
			CASE MyCmd
                        WHEN 'FolderCreate' THEN 1
                        ELSE 0
            END AS MyFolderCreate,
			
			CASE MyCmd
                        WHEN 'FolderDelete' THEN 1
                        ELSE 0
            END AS MyFolderDelete,	
			
			CASE MyCmd
                        WHEN 'FolderUpdate' THEN 1
                        ELSE 0
            END AS MyFolderUpdate,	
			
			CASE MyCmd
                        WHEN 'MoveItems' THEN 1
                        ELSE 0
            END AS MyMoveItems,	
			
			CASE MyCmd
                        WHEN 'GetItemEstimate' THEN 1
                        ELSE 0
            END AS MyGetItemEstimate,
			
			CASE MyCmd
                        WHEN 'Search' THEN 1
                        ELSE 0
            END AS MySearch,

			CASE MyCmd
                        WHEN 'Settings' THEN 1
                        ELSE 0
            END AS MySettings,

			CASE MyCmd
                        WHEN 'ItemOperations' THEN 1
                        ELSE 0
            END AS MyItemOperations,

			CASE MyCmd
                        WHEN 'Provision' THEN 1
                        ELSE 0
            END AS MyProvision,

			CASE MyCmd
                        WHEN 'ResolveRecipients' THEN 1
                        ELSE 0
            END AS MyResolveRecipients,

			CASE MyCmd
                        WHEN 'ValidateCert' THEN 1
                        ELSE 0
            END AS MyValidateCert

INTO '$out'
FROM '$in'

"@

		if ($DeviceID) {
			$query += @"
WHERE EXTRACT_VALUE(cs-uri-query,'DeviceId') = '$DeviceID'

"@
		}
		else {
			$query += @"
WHERE cs-uri-stem LIKE '%/Microsoft-Server-ActiveSync%'

"@
		}
		if ($ReportBySeconds) {
			$query += @"
GROUP BY QUANTIZE(TO_TIMESTAMP(date,time), $ReportBySeconds),User,DeviceType,DeviceId,User-Agent

"@
		}
		else {
			$query += @"
GROUP BY User,DeviceType,DeviceId,User-Agent
ORDER BY Hits DESC
"@
		}
	}
	return $query
}

# Create the HTML file for HTML Report
Function Create-HTML {
param([array]$table,$title,$MinimumHits,$outfile)
	
	# Set the Style 
	$HTMLHeader = "<head><title>ActiveSync Report on $title</title><style>"
	$HTMLHeader += "TABLE{font: normal 8pt Verdana;width:100%;border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
	$HTMLHeader += "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;}"
	$HTMLHeader += "TD{border-width: 1px;padding: 4px;border-style: solid;border-color: black;bordercolor=red;}"
	$HTMLHeader += "</style></head><body>"

	$html = ConvertTo-HTML -Head $HTMLHeader -Body $body
	$body = "<h2><TT>Exchange ActiveSync Report on $title<TT></h2><TT>For additional <b>unfiltered</b> information on device hits please refer to the CSV $outfile</TT><BR /><BR />"
	
	if ($table.count -le 0) {
		$body += "No Devices have excited the Minimum Number of Hits (<b>$MinimumHits</b>)"
	}
	else { $body += ($table | Select $HTMLCSVHeaders.split(",") | ConvertTo-HTML -Fragment) }
	
	$body += "</body></html>"
	return ($HTMLHeader += $body) 
}

# Help!
if ($Help) {

	Write-Host @"

ActiveSynReports.ps1 ($($builddate))
Written by Brian Drepaul

Mandatory Switches
-ActiveSyncOutputFolder     # CSV and HTML output directory
-IISLogs                    # IIS Log Directory
    Ex. -IISLogs D:\Server,'D:\Server 2'
-LogparserExec              # Path to LogParser.exe

Optional Swicthes
-ActiveSyncOutputPrefix     # Prefix a string in the file name EASyncOutputReport
-CreateZip                  # Creates a ZIP file. Can only be used SendHTMLReport
-CreateZipSize              # Threshold file size. The Default is 2MB. Once this has been exceeded 
                            # the file will be compressed. Requires SendHTMLReport and CreateZip to be true
                            # If the files are greater then X it will tell CreateZip to zip the files
-Date                       # Specify a date to parse on. Enter date in the format: MM-DD-YYYY
    Ex. -Date "12-02-11"
-DeviceId                   # Active Sync DeviceID to parse on
-DisableColumnDetect        # Disable the ability to add additional columns to the report that 
                            # users may have enabled, Example: time-taken
-Hourly                     # Generates the report on a per hourly basis
-HTMLReport                 # Creates an HTML Report
-HTMLCSVHeaders             # IIS CSV Headers to Export on in the -HTMLReport
                            # Defaults: "DeviceID,Hits,Ping,Sync,FolderSync,DeviceType,User-Agent"
-MinimumHits                # Minimum Hit Threshold value where the report will generate on CSV and HTML
-ReportBySeconds            # Generates the report bases in the value entered in seconds
-SendEmailReport            # Enable Email reporting
-SMTPRecipient              # SMTP Recipient
-SMTPSender                 # SMTP Sender
-SMTPServer                 # SMTP Server
-TopHits                    # Top Hits to return. Ex. TopHits 50, This cannot be used with Hourly or ReportBySeconds

Examples: 

Return only the Hits that are greater than 1000
.\ActiveSyncReport.ps1 -IISLogs "C:\inetpub\logs\LogFiles\W3SVC1" -LogparserExec "C:\Program Files (x86)\Log Parser 2.2\Logparser.exe" -ActiveSyncOutputFolder c:\EASReports -MinimumHits 1000

Return the results and also include an HTML Report
.\ActiveSyncReport.ps1 -IISLogs "C:\Server1\W3SVC1","C:\Server2\W3SVC1" -LogparserExec "C:\Program Files (x86)\Log Parser 2.2\Logparser.exe" -ActiveSyncOutputFolder c:\EASReports -HTMLReport

Return the results and format it per Hour
.\ActiveSyncReport.ps1 -IISLogs "C:\Server1\W3SVC1" -Date "12-06-2011" -LogparserExec "C:\Program Files (x86)\Log Parser 2.2\Logparser.exe" -ActiveSyncOutputFolder c:\EASReports -Hourly

Return the results for only the device that matches WP7abcdef and format it based on hourly
.\ActiveSyncReport.ps1 -IISLogs "C:\Server1\W3SVC1" -Date "12-06-2011" -DevideID WP7abcdef -LogparserExec "C:\Program Files (x86)\Log Parser 2.2\Logparser.exe" -ActiveSyncOutputFolder c:\EASReports -Hourly

"@
	Exit
}

# Sanity checks

if ($ActiveSyncOutputFolder -eq $null) { Write-Host "-ActiveSyncOutputFolder must be defined. Please use -Help for additional information." -ForegroundColor Red; Exit}
if ($IISLogs -eq $null) { Write-Host "-IISLogs must be defined. Please use -Help for additional information." -ForegroundColor Red; Exit}
if ($LogparserExec -eq $null) { Write-Host "-LogparserExec must be defined. Please use -Help for additional information." -ForegroundColor Red; Exit}

if ($Hourly -and $ReportBySeconds) {
	Write-Host "WARNING: The switches Hourly and ReportBySeconds was used, the ReportsBySeconds will be ignored." -ForegroundColor Yellow
}

# Make sure Top Hits cannot be ran with Hourly or Reports By Seconds
if (($Hourly -or $ReportBySeconds) -and $TopHits ) {
	Write-Host "ERROR: The switch TopHits cannot be used with Hourly and ReportBySeconds." -ForegroundColor Red
	Exit
}

# Test the log parser path
if (!(Test-Path -Path "$LogparserExec")) {
	Write-Host	"LogParser.exe can not be found." -ForegroundColor Red
	Exit
}

# If using Hourly or ReportBySeconds set the seconds correctly
if ($Hourly) {
	$QUANTIZE = 3600
} elseif ($ReportBySeconds) {
	$QUANTIZE = $ReportBySeconds
}


# Determine what IIS Logs files we are going to use
Foreach ($item in $IISLogs) {
	if (Test-Path -LiteralPath $item){
		if ((get-item -LiteralPath $item).Attributes -like "*directory*")  { 

			if ($date) {
				# Date should be in YYYY-MM-DD format
				$filterdate = (Get-Date $date -format yyMMdd)
				Write-Host "Trying to find IIS logs from this date: $title"
				$filter = "*" + $filterdate + "*.log"
				[array]$LogParserFromPath += $item +  "\" + $filter
			} 
			else {
				$filter = "*.log"
				[array]$LogParserFromPath += $item +  "\" + $filter
			}

			# Make sure there are files in the path before we continue
			$iisFiles = Get-ChildItem -LiteralPath $item -Filter $filter

		} else {
				$iisFiles = Get-Item $item
				[array]$LogParserFromPath += $item
		}
	}
	else { 
		Write-Host "Path does not exists: $item, please correct the path and try again." -ForegroundColor Red
		Exit
	}
}

if ($IISLogs -gt 1) { 
	if ($date) { $title = $date }
	else { $title = "Multiple Files" }
}
else {$title = $iisFiles.BaseName}

# Create the ActiveSync Output Folder
md $ActiveSyncOutputFolder -Force | Out-Null

# Handle -DeviceID switch
if ($DeviceId) {

	# Set the Base file name for the files
	if ($Hourly) { $title = $title + " Hourly " + $DeviceId }
	elseif ($ReportBySeconds) { $title = $title + " " + $ReportBySeconds + " Seconds " + $DeviceId }
	elseif ($TopHits) { $title = $title + " Top " + $TopHits + " Hits " + $DeviceId }
	else { $title = $title + " " + $DeviceId }

	# Append the Prefix
	if ($ActiveSyncOutputPrefix) {$title = $ActiveSyncOutputPrefix + "_" + $title}
	
	$baseFileName = "EASyncOutputReport-" + $title.replace(" ","_")

	# Build the output file
	[string]$outfile = $ActiveSyncOutputFolder + "\" + $baseFileName + ".csv"
	
	# Create the file incase log parser comes back with 0 results 
	# LogParsers default action is to NOT create a file if no elements are found
	try {
		"No Active Sync information was found in the IIS Logs." | Out-File $outfile -Force
	} 
	catch [System.IO.IOException] {
		Write-Host "ERROR: Can not create the file $outfile because it is in use, please close the application using this file." -ForegroundColor Red
		exit
	}

	# Query for DeviceId
	if ($Hourly -or $ReportBySeconds) { $query = Build-LogParserQuery -DeviceID $DeviceID -in $LogParserFromPath -out $outfile -iisFiles $iisFiles -ReportBySeconds $QUANTIZE}
	else { $query = Build-LogParserQuery -DeviceID $DeviceID -in $LogParserFromPath -out $outfile -iisFiles $iisFiles }

	Write-Debug $query

	Write-Host "Gathering Statistical data for device: $DeviceID"
	if ($Hourly) { Write-Host "On a per hourly basis." }
	Write-Host "Running Log Parser Command against the IIS Log(s): $LogParserFromPath"
	& $LogparserExec $query -i:w3c -o:CSV

	if ((Test-Path -LiteralPath $outfile) -eq $false) { 
		"No Active Sync information was found in the IIS Logs." | Out-File $outfile -Force 
		if ($MinimumHits) { 
			Write-Warning "No Active Sync information was found in the IIS Logs. Minimum Hits will be skipped."
			$MinimumHits = $null 
		}
		if ($HTMLReport) {
			Write-Warning "No Active Sync information was found in the IIS Logs. HTML Reports will be skipped."
			$HTMLReport = $null 
		}

	} 
	else { $table = Import-CSv $outfile }
}
else {

	# Set the Base file name for the files
	if ($Hourly) { 	$title = $title + " " + "Hourly" }
	elseif ($ReportBySeconds) { $title = $title + " " + $ReportBySeconds + " Seconds" }
	elseif ($TopHits) { $title =  $title + " Top " + $TopHits + " Hits" }

	# Append the Prefix
	if ($ActiveSyncOutputPrefix) {$title = $ActiveSyncOutputPrefix + "_" + $title}

	$baseFileName = "EASyncOutputReport-" + $title.replace(" ","_")

	# Build the output file
	[string]$outfile = $ActiveSyncOutputFolder + "\" + $baseFileName + ".csv"
	
	# Create the file incase log parser comes back with 0 results 
	# LogParsers default action is to NOT create a file if no elements are found
	try {
		"No Active Sync information was found in the IIS Logs." | Out-File $outfile -Force
	} 
	catch [System.IO.IOException] {
		Write-Host "ERROR: Can not create the file $outfile because it is in use, please close the application using this file." -ForegroundColor Red
		exit
	}

	# General Overview Query
	if ($Hourly -or $ReportBySeconds) { $query = Build-LogParserQuery -in $LogParserFromPath -out $outfile -iisFiles $iisFiles -ReportBySeconds $QUANTIZE}
	else { $query = Build-LogParserQuery -in $LogParserFromPath -out $outfile -iisFiles $iisFiles }
	
	Write-Debug $query
	
	# Run Log Parse against the IISLog(s)
	Write-Host "Gathering Statistical data"
	if ($Hourly) { Write-Host "On a per hourly basis." }
	Write-Host "Running Log Parser Command against the IIS Log(s): $LogParserFromPath"
	& $LogparserExec $query -i:w3c -o:CSV
	
	if ((Test-Path -LiteralPath $outfile) -eq $false) { 
		"No Active Sync information was found in the IIS Logs." | Out-File $outfile -Force 
		if ($MinimumHits) { 
			Write-Warning "No Active Sync information was found in the IIS Logs. Minimum Hits will be skipped."
			$MinimumHits = $null 
		}
		if ($HTMLReport) {
			Write-Warning "No Active Sync information was found in the IIS Logs. HTML Reports will be skipped."
			$HTMLReport = $null 
		}

	}
}

# Sort by the most Hits if needed
if ($MinimumHits) {
	
	Write-Host "Generating the Minimum Hits Report."
	
	# Set the Base file name for the files
	$baseFileName = $baseFileName + "_Minimum_Hits_of_$MinimumHits"
	
	# Create the Output file for the Min Hits CSV
	[string]$outfile2 = $ActiveSyncOutputFolder + "\" + $baseFileName + ".csv"

	# Create the file incase log parser comes back with 0 results 
	# LogParsers default action is to NOT create a file if no elements are found
	try {
		"No Active Sync information was found in the IIS Logs." | Out-File $outfile2 -Force
	} 
	catch [System.IO.IOException] {
		Write-Host "ERROR: Can not create the file $outfile2 because it is in use, please close the application using this file." -ForegroundColor Red
		exit
	}

	# Min Hits Query
	if ($Hourly -or $ReportBySeconds) { $query = Build-LogParserQuery -MinimumHitsQuery -in $outfile -out $outfile2 -iisFiles [array](Get-Item $outfile) -ReportBySeconds $QUANTIZE }
	else { $query = Build-LogParserQuery -MinimumHitsQuery -in $outfile -out $outfile2 -iisFiles [array](Get-Item $outfile) }

	Write-Debug $query

	Write-Host "Running Log Parser Command against the CSV results to determine Minimum hits of $MinimumHits"
	[string]$title += " Filtered by Minimum Hits of $MinimumHits"
	& $LogparserExec $query -i:CSV -o:CSV
	$outfile = $outfile2
}
else { [string]$title += " UnFiltered" }

if ($outfile2 -and (Test-Path -path $outfile2)) {	Write-Host "LogParser Command finished CSV, File location: $outfile2" }
elseif ($outfile -and (Test-Path -path $outfile)) {	Write-Host "LogParser Command finished CSV, File location: $outfile" }
else { Write-Host "LogParser Command finished with zero results."}

# Create the HTML File
if ($HTMLReport) {
	Write-Host "Creating HTML Output..."
	
	# Import the CSV so we can generate the HTML File
	$table = Import-CSv $outfile
		
	# Determine the Headers to display
	if (($Hourly -or $ReportBySeconds) -and !$HTMLCSVHeaders) { $HTMLCSVHeaders = "Date,User,DeviceID,Hits,Ping,Sync,FolderSync,DeviceType,User-Agent" }
	elseif (!$HTMLCSVHeaders) { $HTMLCSVHeaders = "User,DeviceID,Hits,Ping,Sync,FolderSync,DeviceType,User-Agent" }
	
	$HTMLReportFile = $ActiveSyncOutputFolder + "\" + $baseFileName + ".html"
	try {
		Create-HTML -table $table -title $title -MinimumHits $MinimumHits -outfile $outfile | Out-File $HTMLReportFile -Force	
	} 
	catch [System.IO.IOException] {
		Write-Host "ERROR: Can not create the file $HTMLReportFile because it is in use, please close the application using this file." -ForegroundColor Red
		exit
	}
	
	Write-Host "HTML File location: $HTMLReportFile"
}

# Send the Email
if ($SendEmailReport) {
	Write-Host "Sending Files via Email to $SMTPRecipient"
	[array]$attachments = "$outfile"
	if ($outfile2) { $attachments += "$outfile2" }
	if ($HTMLReportFile) { $attachments += "$HTMLReportFile" }
	
	if ($CreateZip) {
		foreach ($attachment in $attachments) {
			[int]$attachmentsize += (Get-Item $attachment).Length  / 1MB
		}
		if ($attachmentsize -ge $CreateZipSize) { 
			Write-Host "Files are larger then $CreateZipSize MB, creating zip file..."
			Create-Zip -files $attachments -zipfilename ($ActiveSyncOutputFolder + "\" + $baseFileName + ".zip")
			$attachments = $ActiveSyncOutputFolder + "\" + $baseFileName + ".zip"
		} 
		else {
			Write-Host "Attachment size is less than the CreateZipSize, file compression will be skipped."
		}
	}
	if ($HTMLReportFile) { [string]$body =  Get-Content $HTMLReportFile }
	else { [string]$body = "Active Sync report have been attached this email." }
	
	Write-Host "Sending Email Report..."
	Send-MailMessage -To $SMTPRecipient -From $SMTPSender -SmtpServer $SMTPServer -Subject "Exchange ActiveSync Report $title" -BodyAsHtml $body -Attachments $attachments
}