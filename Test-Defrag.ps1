function Test-Defrag { 
[CmdletBinding(SupportsShouldProcess=$true)] 
param ([string]$computer=".") 
    "`n $computer"  
    Get-WmiObject -Class Win32_Volume -ComputerName $computer |  
      where {$_.Name -like "?:\"} |  
      foreach { 
       $_.Name 
       $dfa = $_.DefragAnalysis() 
      
       if ($dfa.DefragRecommended){ 
            $dfa.DefragAnalysis | Format-List AverageFileSize,  
            AverageFragmentsPerFile, AverageFreeSpacePerExtent,  
            ClusterSize,ExcessFolderFragments, FilePercentFragmentation,  
            FragmentedFolders, FreeSpace, FreeSpacePercent,  
            FreeSpacePercentFragmentation, LargestFreeSpaceExtent,  
            MFTPercentInUse, MFTRecordCount, PageFileSize,  
            TotalExcessFragments, TotalFiles, TotalFolders,  
            TotalFragmentedFiles, TotalFreeSpaceExtents,  
            TotalMFTFragments, TotalMFTSize, TotalPageFileFragments,  
            TotalPercentFragmentation, TotalUnmovableFiles,  
            UsedSpace, VolumeName, VolumeSize  
       } 
       else {Write-Host "`t Drive does not need defrag at this time"}
    } 
}
Test-Defrag $args[0]