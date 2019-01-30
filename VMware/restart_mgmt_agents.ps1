<#
.SYNOPSIS
    
   Script to execute "a rolling restart" of management agents on ESXi hosts in selected vi container (cluster, folder, datacenter)
 
.DESCRIPTION
 
   The script connects to vCenter indicated as parameter then searches for all accessible ESXi hosts in vi container (typically a cluster)
   indicated as second parameter. Subsequently credentials required to open SSH connection to all hosts are gathered as user input.
   It is assumed that SSH service is stopped on each ESXi host, so the script first starts it up, then establishes SSH connection using
   plink.exe executable (expected to be saved in script's working directory).
   A sequence of shell commands to restart hostd and vpxa agents is executed on each host.
   This sequence is saved in text file rstagtsqc.txt that is expected to be saved in script's working directory.
 
.PARAMETER vCenterServer
 
    Mandatory parameter indicating vCenter server to connect to (FQDN or IP address).
   
.PARAMETER Location
 
    Mandatory parameter indicating location (vi containter) where management agents need to be restarted (typically a host cluster).
 
.EXAMPLE
 
    restart_mgmt_agents.ps1 -vCenterServer vcenter.seba.local -Location Test-Cluster
    
    vCenter server indicated as FQDN.
    
.EXAMPLE
 
    restart_mgmt_agents.ps1 -vcenter 10.0.0.1 -location production-cluster
    
    vCenter server indicated as IP address.
 
.EXAMPLE
 
    restart_mgmt_agents.ps1
    
    Script will interactively ask for both mandatory parameters.
   
#>
 
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [ValidateNotNullOrEmpty()]
   [string]$vCenterServer,
	
   [Parameter(Mandatory=$True,Position=2)]
   [ValidateNotNullOrEmpty()]
   [string]$Location
)
 
 
Function Write-And-Log {
 
[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True,Position=1)]
   [ValidateNotNullOrEmpty()]
   [string]$LogFile,
	
   [Parameter(Mandatory=$True,Position=2)]
   [ValidateNotNullOrEmpty()]
   [string]$line,
 
   [Parameter(Mandatory=$False,Position=3)]
   [int]$Severity=0,
 
   [Parameter(Mandatory=$False,Position=4)]
   [string]$type="terse"
 
   
)
 
$timestamp = (Get-Date -Format ("[yyyy-MM-dd HH:mm:ss] "))
$ui = (Get-Host).UI.RawUI
 
switch ($Severity) {
 
        {$_ -gt 0} {$ui.ForegroundColor = "red"; $type ="full"; $LogEntry = $timestamp + ":Error: " + $line; break;}
        {$_ -eq 0} {$ui.ForegroundColor = "green"; $LogEntry = $timestamp + ":Info: " + $line; break;}
        {$_ -lt 0} {$ui.ForegroundColor = "yellow"; $LogEntry = $timestamp + ":Warning: " + $line; break;}
 
}
switch ($type) {
   
        "terse"   {Write-Output $LogEntry; break;}
        "full"    {Write-Output $LogEntry; $LogEntry | Out-file $LogFile -Append; break;}
        "logonly" {$LogEntry | Out-file $LogFile -Append; break;}
     
}
 
$ui.ForegroundColor = "white" 
 
}
 
#constans
 
#variables
$ScriptRoot = Split-Path $MyInvocation.MyCommand.Path
$StartTime = Get-Date -Format "yyyyMMddHHmmss_"
$logdir = $ScriptRoot + "\RestartMgmtAgentsLogs\"
$logfilename = $logdir + $StartTime + "restart_mgmt_agents.log"
$transcriptfilename = $logdir + $StartTime + "restart_mgmt_agents_Transcript.log"
$outputfilename = $ScriptRoot + "\invoke_plink_output.txt"
$plink = $ScriptRoot + "\plink.exe"
$remote_command = $ScriptRoot + "\rstagtsqc.txt"
$total_errors = 0
$total_vmhosts = 0
$index_vmhosts =0
 
#test for log directory, create one if needed
if ( -not (Test-Path $logdir)) {
	New-Item -type directory -path $logdir 2>&1 > $null
}
 
#start PowerShell transcript... or don't do it...
#Start-Transcript -Path $transcriptfilename
 
#load PowerCLI snap-in
$vmsnapin = Get-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue
$Error.Clear()
if ($vmsnapin -eq $null) {
	Add-PSSnapin VMware.VimAutomation.Core
	if ($error.Count -eq 0) {
		write-and-log $logfilename "PowerCLI VimAutomation.Core Snap-in was successfully enabled." 0 "full"
	}
	else{
		write-and-log $logfilename "Could not enable PowerCLI VimAutomation.Core Snap-in, exiting script." 1 "full"
		Exit
	}
}
else{
	write-and-log $logfilename "PowerCLI VimAutomation.Core Snap-in is already enabled." 0 "full"
}
 
#check PowerCLI version
if (($vmsnapin.Version.Major -gt 5) -or (($vmsnapin.version.major -eq 5) -and ($vmsnapin.version.minor -ge 1))) {
	
 
    #assume everything is OK at this point
	$Error.Clear()
 
	#connect vCenter from parameter
	Connect-VIServer -Server $vCenterServer -ErrorAction SilentlyContinue 2>&1 > $null
 
	#execute only if connection successful
	if ($error.Count -eq 0){
	    
        #measuring execution time is really hip these days
        $stop_watch = [Diagnostics.Stopwatch]::StartNew()
    	
        #use previously defined function to inform what is going on, anything else than "terse" will cause the message to be written both in logfile and to screen
    	Write-And-Log $logfilename "vCenter $vCenterServer successfully connected." $error.count "full"
 
    	#get the vmhosts in location
		$vmhosts_in_cluster = get-vmhost -Location $location | where-object {$_.connectionstate -eq "Connected"}
		
		if ($vmhosts_in_cluster) {
			$total_vmhosts = $vmhosts_in_cluster.count
            
			#gather credentials to SSH to these hosts
			$cred = $Host.UI.PromptForCredential("ESX Host access credentials","Please provide credentials for SSH to ESXi hosts in $Location","","")
		
			#convert SecureString password to plain-text
			$pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($cred.password)
			$decrypt_pass = [Runtime.InteropServices.Marshal]::PtrToStringAuto($pointer)
		
			#and pretend we weren't there at all
			[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer)
		
			$plink_opts = "-l $($cred.username) -pw $decrypt_pass -m $remote_command "
			$invoke_plink = "echo Y | " + $plink + " " + $plink_opts
		
			foreach ($vmhost in $vmhosts_in_cluster) {
				write-progress -Activity "Restarting management agents for $Location container" -Status "Percent complete $("{0:N2}" -f (($index_vmhosts / $total_vmhosts) * 100))%" -PercentComplete (($index_vmhosts / $total_vmhosts) * 100) -CurrentOperation "Processing vSphere host: $($vmhost.name)"	
				
				#start SSH service if needed
				$ssh_service = get-vmhostservice -vmhost $vmhost | where-object { $_.Key -eq "TSM-SSH"}
				if ( -not $ssh_service.Running){
						Start-vmhostservice -hostservice $ssh_service -confirm:$false 2>&1 > $null
						$flag = $true
					}
				
				#call plink with command sequence prepared earlier.
				$command = $invoke_plink + $vmhost.name
				$output += invoke-expression -command $command 2>&1
				
                Start-Sleep -seconds 30
                
				#stop SSH service if we had started it (the loop is there to vait for vpxd to restart)
				while ($flag){
						$flag = $false
						
						try {
							Stop-Vmhostservice -hostservice $ssh_service -confirm:$false -ErrorAction Stop 2>&1 > $null
						}
						catch {
							$flag = $true
                            start-sleep -seconds 30
						}
					}
								
				$index_vmhosts++
			}
        
        #only paranoid will survive, so lets clear all the traces of plaintext password we had
		remove-variable -name plink_opts
		remove-variable -name decrypt_pass
		
        $output | out-file -filepath $outputfilename
		}
		else {
			write-and-log $logfilename "There are no VMHosts connected to $Location VI-Container." 1 "full"
			$total_errors += 1
		}
		
		$stop_watch.Stop()
        $elapsed_seconds = ($stop_watch.elapsedmilliseconds)/1000
        
        #farewell message before disconnect
		Write-And-Log $logfilename "Management agents successfully restarted for $index_vmhosts hosts in $Location VI-Container." $total_errors "full"
		Write-And-Log $logfilename "Script took $("{0:N2}" -f $elapsed_seconds)s to execute, exiting." -1 "full"	
 
		#disconnect vCenter
		Disconnect-VIServer -Confirm:$false -Force:$true
	}
	else{
	Write-And-Log $logfilename "Error connecting vCenter server $vCenterServer, exiting." $error.count "full"
	}
}
else {
	write-and-log $logfilename "This script requires PowerCLI 5.1 or greater to run properly." 1 "full"
}
 
#Stop-Transcript ...well, if you had started it