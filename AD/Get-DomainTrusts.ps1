$server = $args[0]

if ($server -eq $null -or $server -eq "") {
Write-Host -ForegroundColor "yellow" "Usage:  Get-DomainTrusts.ps1 [domain controller]"
exit
}

$colTrustList = Get-WmiObject -class Microsoft_DomainTrustStatus -ComputerName $server -Namespace "root\MicrosoftActiveDirectory"

Foreach ($objTrust in $colTrustList) {
	Write-Host ""
    Write-Host "Trusted domain: " $objTrust.TrustedDomain
		if ($objTrust.TrustDirection -eq 0) {
    Write-Host "Trust direction: Disabled" }
		if ($objTrust.TrustDirection -eq 1) {
    Write-Host "Trust direction: Inbound" }
		if ($objTrust.TrustDirection -eq 2) {
    Write-Host "Trust direction: Outbound" }
		if ($objTrust.TrustDirection -eq 3) {
    Write-Host "Trust direction: BiDirectional" }
		if ($objTrust.TrustType -eq 1) {
    Write-Host "Trust type: Pre-Win2K/NTLM Only" }
 		if ($objTrust.TrustType -eq 2) {
    Write-Host "Trust type: Windows Kerberos" }   
		if ($objTrust.TrustType -eq 3) {
    Write-Host "Trust type: UNIX Kerberos" }
		if ($objTrust.TrustType -eq 4) {
    Write-Host "Trust type: DCE Realm" }
		if ($objTrust.TrustAttributes -eq 4) {
    Write-Host "Trust attributes: External Trust,Bi-Directional,Intransitive" }
		if ($objTrust.TrustAttributes -eq 32) {
    Write-Host "Trust attributes: Tree Root Trust,Bi-Directional,Transitive" }
    Write-Host "Trusted domain controller name: " $objTrust.TrustedDCName
    Write-Host "Trust status: " $objTrust.TrustStatus
    Write-Host "Trust is OK: " $objTrust.TrustIsOK
	Write-Host ""
}
