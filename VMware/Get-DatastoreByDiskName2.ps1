param(
   [Parameter(Mandatory=$true)]
   [ValidateNotNullOrEmpty()]
   [string] $datastore
)

get-datastore |Where-Object { $_.extensiondata.info.vmfs.extent.diskname -like “*$datastore*”}
