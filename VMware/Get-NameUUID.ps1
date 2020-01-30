$outputfile = "VMnamesandID.csv"
$Response_file = @()

Get-VM | ForEach-Object {
    $VM = $_
    $VMview = $VM | Get-View
    $Report =  " " | Select VMname, VMIP, VMID, VMOS, VMNote
    $Report.VMName = $VMview.config.Name
    $Report.VMIP = $VMview.guest.IpAddress
    $Report.VMID = $VMview.config.Uuid
    $Report.VMOS = $VMview.config.GuestFullName
    $Report.VMNote = $VMview.config.Annotation
    $Response_file += $Report
    }
    $Response_file | Sort-Object -Property VMName | Export-Csv $outputfile -NoTypeInformation
