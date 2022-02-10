$OSList = (Get-VM).ExtensionData.Config.GuestFullName
"" | Select @{N='Windows'; E={ ($OSList | Where { $_ -like '*windows*' } | Measure).Count }},
@{N='Linux'; E={ ($OSList | Where { $_ -like '*linux*' } | Measure).Count }},
@{N='Other'; E={ ($OSList | Where { $_ -inotmatch '(linux|windows)' } | Measure).Count }} | Format-Table -Autosize