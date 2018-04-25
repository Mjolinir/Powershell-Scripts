##################################################
# Main
##################################################
#--------------------
# Set Config Vars
#--------------------
$Machine_CSV = "RejoinDomain.csv"
$DomainName = "UISAD"

#--------------------
# Define DataTables
#--------------------
$MachinesTable = new-object System.Data.DataTable
$MachinesTable.TableName = "Machines"
[Void]$MachinesTable.Columns.Add("Name")
[Void]$MachinesTable.Columns.Add("Status")
[Void]$MachinesTable.Columns.Add("UnJoinStatus")
[Void]$MachinesTable.Columns.Add("JoinStatus")

#--------------------
# Get Domain Creds
#--------------------
$DomainCred = Get-Credential

#--------------------
# Define General Trap
#--------------------
trap{write-host $_ -Foregroundcolor Red;
    Continue}
    
$Machine_List = Import-Csv $Machine_CSV

foreach ($Record in $Machine_List){
    &{
        $MachineName = $($Record.MachinePath).Split(",")
        $MachineParentOU = $($Record.MachinePath).SubString($($MachineName[0].Length + 1))
        $MachineName = $($MachineName[0].Split("="))[1]
        
        Add-Member -inputObject $Record -membertype noteProperty `
                -name "MachineName" -value $MachineName
        
        Write-Host "Checking $($Record.MachineName)" -NoNewline
        
        .{
            trap{Continue}
            
            $Ping = new-object Net.NetworkInformation.Ping
            $Result = $Ping.Send($Record.MachineName)
        }
    
        if ($Result.Status -eq "Success"){
            write-host `t "[ONLINE]" -Foregroundcolor Green
            Add-Member -inputObject $Record -membertype noteProperty `
                -name "Status" -value "Online"
            }
        else{
            write-host `t "[OFFLINE]" -Foregroundcolor Red
            Add-Member -inputObject $Record -membertype noteProperty `
                -name "Status" -value "Offline"
            }
            
        If ($Record.Status -eq "Online"){
            $LocalMachineCred = Get-Credential
                        
            $BSTR = [System.Runtime.InteropServices.marshal]::SecureStringToBSTR($DomainCred.Password)
            $Password = [System.Runtime.InteropServices.marshal]::PtrToStringAuto($BSTR)

            $ObjMachine = Get-WMIObject -class "Win32_ComputerSystem" -namespace "root\cimv2" -Computer $Record.MachineName -credential $LocalMachineCred -Authentication 6 -Impersonation 3
            $UnJoinStatus = $ObjMachine.UnjoinDomainOrWorkgroup($Null, $Null)
            $JoinStatus = $ObjMachine.JoinDomainOrWorkgroup($DomainName, $Password, $($DomainCred.UserName), $MachineParentOU, 3)
            }
        
        [Void]$MachinesTable.Rows.Add($Record.MachineName, $Record.Status, $UnJoinStatus.ReturnValue, $JoinStatus.ReturnValue)
        }
    }

Write-Host
$MachinesTable