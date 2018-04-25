$objSID = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-21-2410797950-865614936-3316745272-498")
$objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
$objUser.Value

