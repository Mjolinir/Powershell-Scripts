$server_name = $args[0]

if ($server_name -eq $null -or $server -eq "") {
Write-Host -ForegroundColor "yellow" "Usage:  ListDiskFreeSpace.ps1 [servername]"
exit
}


$outData = @("")
$server = $args[0]
$dataFromServer = Get-WmiObject Win32_Volume -ComputerName $server_name | Select-Object SystemName,Label,Name,DriveLetter,DriveType,Capacity,Freespace
foreach ($currline in $dataFromServer) {
    if ((-not $currline.name.StartsWith("\\")) -and ($currline.Drivetype -ne 5)) {
        [float]$tempfloat = ($currline.Freespace / 1000000) / ($currline.Capacity / 1000000)
        $temppercent = [math]::round(($tempfloat * 100),2)
        add-member -InputObject $currline -MemberType NoteProperty -name FreePercent -value "$temppercent %"
        $outData = $outData + $currline
    }
}
$outData | Select-Object SystemName,Label,Name,Capacity,FreePercent | sort-object -property FreePercent | format-table -autosize