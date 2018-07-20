# Create an array from LDAP search
$adobjs = Get-ADObject -LDAPFilter "(extensionAttribute1=*)" -pr extensionAttribute1 | Select-Object -ExpandProperty extensionAttribute1
# Create a new empty hash table object
$hash = @{}
# Add each item from the LDAP results to the hash table
$adobjs | % {$hash["$_"] += 1}
# Find the duplicates by examining the hash table
$hash.keys | ? {$hash["$_"] -gt 1} `
| % {write-host "Duplicate attribute value found: $_" }