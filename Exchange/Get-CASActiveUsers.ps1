$var = $args[0]

if ($var -eq $null -or $var -eq "") {
Write-Host -ForegroundColor "yellow" "Usage:  Get-CASActiveUsers.ps1 [servername],[servername],[servername]"
exit
}

function Get-CASActiveUsers {
  [CmdletBinding()]
    param(
    [Parameter(Position=0, ParameterSetName="Value", Mandatory=$true)]
    [String[]]$ComputerName,
    [Parameter(Position=0, ParameterSetName="Pipeline", ValueFromPipelineByPropertyName=$true, Mandatory=$true)]
    [String]$Name
  )

  process {
    switch($PsCmdlet.ParameterSetName) {
      "Value" {$servers = $ComputerName}
      "Pipeline" {$servers = $Name}
    }
    $servers | %{
      $RPC = Get-Counter "\MSExchange RpcClientAccess\User Count" -ComputerName $_
      $OWA = Get-Counter "\MSExchange OWA\Current Users" -ComputerName $_
                  $OA = Get-Counter "\RPC/HTTP Proxy\Current Number of Incoming RPC over HTTP Connections" -ComputerName $_
                  $EWS = Get-Counter "\MSExchangeWS\Requests/sec" -ComputerName $_
                  $IMAP = Get-Counter "\MSExchangeImap4(1)\Current Connections" -ComputerName $_
                 $AS = Get-Counter "\MSExchange ActiveSync\Current Requests" -ComputerName $_
                  $IIS = Get-Counter "\Web Service(_Total)\Current Connections" -ComputerName $_
      New-Object PSObject -Property @{
        Server = $_
        "RPC Client Access (User Count)" = $RPC.CounterSamples[0].CookedValue
        "Outlook Web App (Current Users)" = $OWA.CounterSamples[0].CookedValue
                                "Outlook Anywhere (Connection Count)" = $OA.CounterSamples[0].CookedValue
                                "EWS (Req/Sec)" = [int]$EWS.CounterSamples[0].CookedValue
                                "IMAP (Current Connections)" = $IMAP.CounterSamples[0].CookedValue
                                "ActiveSync (Request Count)" = $AS.CounterSamples[0].CookedValue
                                "Web Services (Connection Count)" = $IIS.CounterSamples[0].CookedValue
      }
    }
  }
}

Get-CASActiveUsers -ComputerName $args[0] | select Server,"ActiveSync (Request Count)","Outlook Web App (Current Users)","Outlook Anywhere (Connection Count)","EWS (Req/Sec)","Web Services (Connection Count)","RPC Client Access (User Count)","IMAP (Current Connections)"
