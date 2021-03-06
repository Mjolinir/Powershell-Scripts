$acls = @{};
# Folder to be copied from
Get-ChildItem z:\owsfiles -Recurse |
    Where-Object { $_.PSIsContainer } |# Object is a folder
    ForEach-Object {
        $acls[$_.Name] = Get-Acl $_.FullName ;
    #    write-host $_.FullName
    }
    
# Folder to be copied to
Get-ChildItem d:\owsfiles -Recurse |
    Where-Object { $_.PSIsContainer -and $acls.ContainsKey($_.Name) } |# Object is a folder
    ForEach-Object {
        Set-Acl $_.FullName $acls[$_.Name] ;
    #    write-host $_.FullName
    }