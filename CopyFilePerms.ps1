$acls = @{};
# Folder to be copied from
Get-ChildItem z:\owsfiles -Recurse |
    Where-Object { -not $_.PSIsContainer } |# Object is a file
    ForEach-Object {
        $acls[$_.Name] = Get-Acl $_.FullName ;
    #    write-host $_.FullName
    }
    
# Folder to be copied to
Get-ChildItem d:\owsfiles -Recurse |
    Where-Object { -not $_.PSIsContainer -and $acls.ContainsKey($_.Name) } |# Object is a file
    ForEach-Object {
        Set-Acl $_.FullName $acls[$_.Name] ;
    #    write-host $_.FullName
    }