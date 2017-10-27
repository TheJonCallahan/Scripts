$Boundaries = Get-CMBoundaryGroup | ForEach-Object {
    $groupName = $_.Name
    Get-CMBoundary -BoundaryGroupId $_.GroupID | ForEach-Object { 
        [PSCustomObject]@{
            "Group Name" = $groupName;
            "Boundary"   = $_.DisplayName;
            "Value"      = $_.Value;
        }
    }
}

$Boundaries | Export-CSV -Path $pathCSV