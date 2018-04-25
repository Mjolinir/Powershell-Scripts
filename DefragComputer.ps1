# ==============================================================================================
# Script Name: Servers Defrag  
# 
# AUTHOR: Mohamed Garrana , 
# DATE  : 09/04/2010
# 
# COMMENT: 
# This Script performs defrag on a list of computers or a single computer, it runs the defrag as a PowerShell background job , 
# allowing multiple defrag instances on different computers to run at the same time
#the script checks if the volume needs a defrag before performing a defrag on it
#when a defrag finished on a volume the script checks other volumes on the same server for defrag
#an execution example: defrag C: on serverA and defrag C: on server B simultaneously , when defragging C: on server A finishes, 
#the script defrags D: on serverA and so on
#the script keeps track of the already defragged drives using $jobtracker dictionary
# ==============================================================================================

Get-Job | Remove-Job #removing any background jobs in the shell
[int]$jobid = -1 #job id counter to track background defrag jobs in the jobtracker hashtable
$jobtracker = @{} #hash table in the format of @{jobid = computername,Driveletter} used to track already defraged drives
$compvolid=@() #array , in the format of computername,Driverletter , used as a value in $jobtracker
function Wmidefrag {
	#this function lists all the disk volumes of a computer and checks if defrag is needed on any of them
	#and runs the defrag as a background job moving onto the next computer if any
	
	#parameter can be a string of the computername
	#parameter can be a pipelined object of a type.string
	param(
	[Parameter(Mandatory=$true,valuefrompipeline=$true)]
	[string]$compname)
	
	begin {Write-Output "running wmi defrag"}
	Process {
	$wmivol = Get-WmiObject Win32_Volume -ComputerName $compname
	foreach ( $vol in $wmivol ) {
		$compvolid = $compname,($vol.Driveletter)
		#notdefraged checks to see whether the volume of the server($compvolid) has been defragmented before , returns true
		foreach ($val in $jobtracker.Values) 
				{  if (!(Compare-Object $val $compvolid))  #if array $compvolid is eq to $val the compare-object returns nul value (!) 
						{$notdefraged=$false;break}
						else {$notdefraged=$true}
							} 
		if (($jobtracker.Count) -eq 0) {$notdefraged = $true} #first run $jobtracker hash table is not built yet
		Write-Output "checking on volume $($vol.Driveletter) for server $($compname)" 
		#only run degrag if defraganalysis().Defragrecommended is true and if the volume has not been defraged before
		if (($vol.Defraganalysis().DefragRecommended -eq $True) -and ($vol.Drivetype -eq 3) -and ($notdefraged))

			{$vol | Invoke-WmiMethod -name "defrag" -ArgumentList $true -asjob 
			Write-Output "Disk Defragmentation Started on $($compname) on volume $($vol.DriveLetter) as a PS background job .. Continuing "
			$jobid = $jobid + 2 # stepping 2 because foreach background job there is a child job
			$jobtracker[$jobid] = $compvolid #adding [jobid] = compname , driveletter to the jobtracker hash table
			break #break for volume hopping per computer to another pipelined object since defrag can only be run once per server
			
			}
			#if volume does not need a defrag skip it
		elseif (($vol.Defraganalysis().DefragRecommended -eq $false) -and ($vol.Drivetype -eq 3) )
				{Write-Output "Disk Defragmentation is not needed on volume $($vol.DriveLetter) for server $($compname) .. Continuing "}
	}
	}
	end {
		Start-Sleep -Seconds 10
		iteratejobs
			}
						}

function iteratejobs {
	#this function works with the back ground defrag jobs, checking to see the return value of the jobs
	Write-output " running iterate jobs "
	$alljobs =  Get-Job 
	#run the following if there are any jobs either running or completed
	if ($alljobs) {
	
	$completedjobs =  Get-Job | where {$_.state -eq "Completed"}
	#checking if any of the jobs are completed yet
	#completed means that the background job has returned a return value
	if ($completedjobs) {
	foreach ($job in $completedjobs) {
		#geting computername and driverletter from the @jobtracker hash table using jobid
		$server = $jobtracker[$job.id][0]
		$driveletter = $jobtracker[$job.id][1]
		# receive the job but keep it in memory 
		$receivedjob = Receive-Job -id ($job.id) -Keep
		#check for job return value
		switch ($receivedjob.ReturnValue) {
      0  {Write-output "Defragmentation Completed on Volume $($driveletter) for server $($server)"
      		Get-Job -Id $job.id | Remove-Job # remove the completed defragmentaion job
      		Wmidefrag $server #running Wmidefrag again against the server to defrag any remaining volumes  
      		}
      1  {Write-Output "Access Denied on Volume $($driveletter) for server $($server)"}
      2  {Write-Output "Not Supported on Volume $($driveletter) for server $($server)"}
      3  {Write-Output "Volume Dirty Bit set on Volume $driveletter for server $($server)"}
      4  {Write-Output "Not Enough Free Space on Volume $($driveletter) for server $($server)"}
      5  {Write-Output "Corrupt MFT Detected on Volume $($driveletter) for server $($server)"}
      6  {Write-Output "Call Cancelled on Volume $($driveletter) for server $($server)"}
      7  {Write-Output "Cancellation Request Requested Too Late"}
      8  {Write-Output "Defrag In Progress on server $($server)"}
      9  {Write-Output "Defrag Engine Unavailable on server $($server)"}
      10 {Write-Output "Defrag Engine Error on server $($server) .. probably process is stopped on remote server" }
      11 {Write-Output "Unknown Error on server $($server) ... probably Access Denied "}
    }   Get-Job -Id $job.id | Remove-Job }
	#sleep then do iteratejobs again
	Start-Sleep -Seconds 60
	iteratejobs
	}
	#no background jobs are completed but some are running
	else { Write-output " Waiting for completed Defragmention jobs "
		#Write-Output "second sleep sleeping for 60 second"
		Start-Sleep -Seconds 600
		iteratejobs
			}
			}
	# if there are no jobs running or completed
	else {Write-output "END ... Defrag is Done here "}
}



#--------------------------------------
#you can run the script this way , to defrag a single server 
#wmidefrag server1
#-------------------------------------------
#you can run the script this way , to defrag multiple computers
#c:\servers.txt is a text file in the format of a servername per line  
#get-content c:\servers.txt | Wmidefrag | Tee-object -filepath C:\ds.txt
