$diskName=$args[0]

function Get-DatastoreByDiskName {
   
  [CmdletBinding()]
  param(
    [parameter(Mandatory = $true,
               ValueFromPipeline = $true,
               ValueFromPipelineByPropertyName = $true)]
    [string[]] $DiskName
  )
   
  begin {   
    $DatastoresView = Get-View -ViewType Datastore -Property Name,Info
  }
   
  process {
    ForEach ($Datastore in $DatastoresView)
    {
      if ($Datastore.Info.GetType().Name -eq "VmfsDatastoreInfo")
      {
        ForEach ($Disk in $DiskName)
        {
          $Datastore.Info.Vmfs.Extent |
            ForEach-Object {
              if ($_ -and $_.Diskname -eq $Disk)
              {
                $Datastore | Get-VIObjectByVIView
              }
            }
        }
      }
    }
  }
}
Get-DatastoreByDiskName "$diskName"