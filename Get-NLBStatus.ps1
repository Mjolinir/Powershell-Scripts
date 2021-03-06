#Define Nodes
$node1 = $args[0]
$node2 = $args[1]

if ($node1 -eq $null -or $node1 -eq "" -or $node2 -eq $null -or $node2 -eq "") {
Write-Host -ForegroundColor "yellow" "Usage:  GetNLBStatus.ps1 [node1 name] [node2 name]"
exit
}

#get NLB status on NLB Nodes

$Node1status = Get-WmiObject -Class MicrosoftNLB_Node -computername $node1 -namespace root\MicrosoftNLB | Select-Object __Server, statuscode
$Node2status = Get-WmiObject -Class MicrosoftNLB_Node -computername $node2 -namespace root\MicrosoftNLB | Select-Object __Server, statuscode

IF ($Node1status.statuscode -eq "1008" -or $Node1status.statuscode -eq "1007")
{
 write-host "NLB Status of $node1 is: Converged" 
}
else
{
 write-host "NLB Status of $node1 is: Error" $Node1status.statuscode
}
IF ($Node2status.statuscode -eq "1008" -or $Node2status.statuscode -eq "1007")
{
write-host "NLB Status of $node2 is: Converged" 
}
else
{
write-host "NLB Status of $node2 is: Error" $Node2status.statuscode
}