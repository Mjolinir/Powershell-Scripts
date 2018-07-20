
[CmdletBinding()]
param(
    [Parameter(position=0,Mandatory=$false)][ValidateSet("SWEET32","TLS1.0","Both")]$Solve="Both"
)

function Write-Log{
    [CmdletBinding()]
    #[Alias('wl')]
    [OutputType([int])]
    Param
    (
        # The string to be written to the log.
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias("LogContent")]
        [string]$Message,

        # The path to the log file.
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [Alias('LogPath')]
        [string]$Path=$DefaultLog,

        [Parameter(Mandatory=$false,
                    ValueFromPipelineByPropertyName=$true,
                    Position=2)]
        [ValidateSet("Error","Warn","Info","Load","Execute")]
        [string]$Level="Info",

        [Parameter(Mandatory=$false)]
        [switch]$NoClobber
    )

   
    Process
    {
        
        if ((Test-Path $Path) -AND $NoClobber) {
            Write-Warning "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name."
            Return
            }

        # If attempting to write to a log file in a folder/path that doesn't exist
        # to create the file include path.
        elseif (!(Test-Path $Path)) {
            Write-Verbose "Creating $Path."
            $NewLogFile = New-Item $Path -Force -ItemType File
            }

        else {
            # Nothing to see here yet.
            }

        # Now do the logging and additional output based on $Level
        switch ($Level) {
            'Error' {
                Write-Host $Message -ForegroundColor Red
                Write-Output "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") ERROR: `t $Message" | Out-File -FilePath $Path -Append
                break;
                }
            'Warn' {
                Write-Warning $Message
                Write-Output "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") WARNING: `t $Message" | Out-File -FilePath $Path -Append
                break;
                }
            'Info' {
                Write-Host $Message -ForegroundColor Green
                Write-Verbose $Message
                Write-Output "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") INFO: `t $Message" | Out-File -FilePath $Path -Append
                break;
                }
            'Load' {
                Write-Host $Message -ForegroundColor Magenta
                Write-Verbose $Message
                Write-Output "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") LOAD: `t $Message" | Out-File -FilePath $Path -Append
                break;
                }
            'Execute' {
                Write-Host $Message -ForegroundColor Green
                Write-Verbose $Message
                Write-Output "$(Get-Date -Format "yyyy-MM-dd HH:mm:ss") EXEC: `t $Message" | Out-File -FilePath $Path -Append
                break;
                }
            }
    }
}
function Test-RegistryValue {
    param (
        [parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()]$Path,
        [parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()]$Value
    )
    try{
        if( (Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value -ErrorAction Stop) -eq 0 ){
            return  $true
        }
        return $false
    }
    catch{
        return  $true
    }
}
function Test-RegistryProperty {
    param (
        [parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()]$Path,
        [parameter(Mandatory=$true)] [ValidateNotNullOrEmpty()]$Value
    )
    try{
        if( (Get-ItemProperty -Path $Path | Select-Object -ExpandProperty $Value) -eq 0 ){
            return  $true
        }
        return $false
    }
    catch{
        return  $true
    }
}

$Global:CleanUpGlobal=@()
$Global:CleanUpVar=@()

$global:ScriptLocation = $(get-location).Path
$global:DefaultLog = "$global:ScriptLocation\Sweet32.log"

$Global:CleanUpGlobal+="ScriptLocation"
$Global:CleanUpGlobal+="DefaultLog"
################################################################################SWEET32######################################################################
###                 Source : https://bobcares.com/blog/how-to-fix-sweet32-birthday-attacks-vulnerability-cve-2016-2183/3/                                 ###               
################################################################################SWEET32######################################################################

if( ($Solve -eq "Both") -or ($Solve -eq "SWEET32") ){
    Write-Log -Level Load -Message "Solving vulnerability --> SWEET32"

    $TripleDES168="HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168/168"
    $testkey = Test-path $TripleDES168


    #Create Key Triple DES 168 (A key is a folder in the registry)
    if(!$testkey){
        Write-Log -Level info -Message "Creating Key $TripleDES168"
        New-Item -Path $TripleDES168 -Force | Out-Null
    }
    else{
        Write-Log -Level Warn -Message "They key already exits ($TripleDES168)"
    }
    
    #Create The property "Enabled" with value 0
    $testentry= Test-RegistryValue -Path $TripleDES168 -Value "Enabled"
    if(!$testentry){
        Write-Log -Level Info -Message "Creating new Enabled Property with value 0"
        New-ItemProperty -Path $TripleDES168 -Name "Enabled" -Value 0  -Force | Out-Null
    }
    else{
        Write-Log -Level Info -Message "The registry entry with property enabled = 0, already exists"
    }
}

#############################################################################################################################################################
###   Protocols : https://blogs.msdn.microsoft.com/friis/2016/07/25/disabling-tls-1-0-on-your-windows-2008-r2-server-just-because-you-still-have-one/     ###
#############################################################################################################################################################

if( ($Solve -match "Both") -or ($Solve -match "TLS1.0") ){

    Write-Log -Level Load -Message "Solving vulnerability --> TLS1.0"

    #Define Variables and Arrays
    $TLSRoot = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"
    $TLSArray =@("TLS 1.0","TLS 1.1","TLS 1.2")
    $ClientServer= @("Client","Server")

    foreach($tls in $TLSArray){ #foreach root item check if it's there, 
        $rootpath = "$TLSRoot\$tls"

        if(! (Test-Path $rootpath)){ #if it's doesn't exists, create it  (Remember a key is a folder in registry).
            Write-Log -Level Info -Message "Create new Key ($rootpath)"
            new-item -Path $rootpath -Force | Out-Null
        }
    
        foreach($cs in $ClientServer){ #cs => Client/Server array.
            $cspath = "$rootpath\$cs"
	
            if(! (Test-Path $cspath) ){ #check if the cspath exists (if not create it, if it is, check the property "Enabled" for TLS 1.0 and TLS 1.1 , and "DisabledByDefault" for TLS 1.2
                New-Item -Path "$cspath" -Force | Out-Null
                if($tls -eq "TLS 1.0" -or $tls -eq "TLS 1.1"){ #If tls 1.0 enabled 0 (disabled)
                    if(! (Test-RegistryProperty  "$cspath" -Value "Enabled")){
                        Write-Log -Level Info -Message "Creating new property Enabled = 0 for $tls in ($cspath)"
                        New-ItemProperty -Path "$cspath" -Name "Enabled" -Value 0 -Force | Out-Null
						New-ItemProperty -Path "$cspath" -Name "DisabledByDefault" -Value 1 -Force | Out-Null
                    }
                }
                else{ #if tls 1.2 (is not disabled by default and it's enabled
                    if(! (Test-RegistryProperty "$cspath" -Value "DisabledByDefault")){
                        Write-Log -Level Info -Message "Creating 'Enabled' and 'DisabledByDefault' for $tls in ($cspath)"
                        New-ItemProperty -Path "$cspath" -Name "DisabledByDefault" -Value 0 -Force | Out-Null
                        New-ItemProperty -Path "$cspath" -Name "Enabled" -Value 4294967295 -Force | Out-Null #Enable tls 1.0 or 1.1
                    }
                }
            }
            else{ #if the root exists Check the property Enabled for tls1.0 and "Disabledbydefault" for 
				if($tls -eq "TLS 1.0" -or $tls -eq "TLS 1.1"){ #If tls 1.0 enabled 0 (disabled)
                    if(! (Test-RegistryProperty  "$cspath" -Value "Enabled")){
                        Write-Log -Level Info -Message "Creating new property Enabled = 0 for $tls in ($cspath)"
                        New-ItemProperty -Path "$cspath" -Name "Enabled" -Value 0 -Force | Out-Null
						New-ItemProperty -Path "$cspath" -Name "DisabledByDefault" -Value 1 -Force | Out-Null
                    }
                }
                else{
                    if(! (Test-RegistryProperty "$cspath" -Value "DisabledByDefault")){
                        Write-Log -Level Info -Message "Creating 'Enabled' and 'DisabledByDefault' for $tls in ($cspath)"
                        New-ItemProperty -Path "$cspath" -Name "DisabledByDefault" -Value 0 -Force | Out-Null
                        New-ItemProperty -Path "$cspath" -Name "Enabled" -Value 4294967295 -Force| Out-Null
                    }
                }
            }
        }
    }

}

Write-Log -Level Info "Cleaning up variables"
	$CleanUpVar | ForEach-Object{
		Remove-Variable $_
	}
	$CleanUpGlobal | ForEach-Object{
		Remove-Variable -Scope global $_
	}
