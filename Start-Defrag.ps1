function Start-Defrag { 
[CmdletBinding(SupportsShouldProcess=$true)] 
param ([string]$computer=".", 
       [string]$drive 
) 
    if ($drive -notlike "?:"){  
    Throw "Drive should be submitted as letter and colon e.g. C:"} 
    
    $filt = "Name=’" + $drive + "\\’" 
    $vol = Get-WmiObject -Class Win32_Volume -Filter $filt -ComputerName $computer 
    
    $res = $vol.Defrag($false) 
    
    if ($res.ReturnValue -eq 0) { 
        Write-Host "Defrag succeeded" 
        $res.DefragAnalysis |  
        Format-List AverageFileSize, AverageFragmentsPerFile,  
        AverageFreeSpacePerExtent, ClusterSize, 
        ExcessFolderFragments, FilePercentFragmentation,  
        FragmentedFolders, FreeSpace, FreeSpacePercent,  
        FreeSpacePercentFragmentation,  
        LargestFreeSpaceExtent, MFTPercentInUse,  
        MFTRecordCount, PageFileSize, TotalExcessFragments,  
        TotalFiles, TotalFolders, TotalFragmentedFiles,  
        TotalFreeSpaceExtents, TotalMFTFragments,  
        TotalMFTSize, TotalPageFileFragments,  
        TotalPercentFragmentation, TotalUnmovableFiles,  
        UsedSpace, VolumeName, VolumeSize  
    } 
    else {Write-Host "Defrag failed Result code: " $res.ReturnValue} 
}
Start-Defrag $args[0]