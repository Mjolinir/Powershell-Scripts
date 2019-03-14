Get-VM | select Name, NumCpu, MemoryGB, ProvisionedSpaceGB, UsedSpaceGB, VMHost | Export-Csv -path “vminventory.csv” -NoTypeInformation
