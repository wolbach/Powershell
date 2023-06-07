function Get-LADMGroup {
    param (
        $Name
    )
    
    switch ($Name) {
        $null { 
            $admingroups = Get-ADGroup -Filter * | where samaccountname -Match "LADM" | select samaccountname 
            Write-Host $admingroups
            return $admingroups
        }
        Default {
            $admingroup = Get-ADGroup $Name
            return $admingroup
        }
    }
}

function Get-LADMGroupMember {
    param (
        $Group
    )
    if ($Group -is [array]) {
        $members = @{}
        foreach ($grp in $Group) {
            Write-Host $grp
            $members.Add($grp.samaccountname, @(Get-ADGroupMember $grp.samaccountname | select Name))
        }
        return $members
    }else {
        Write-Host "nope"
    }
    
}

#Start-Transcript -OutputDirectory "C:\temp"
New-Item -Path "C:\temp" -Name "Export_LADM.csv" -ItemType File
$Groups = Get-LADMGroup
$membs = Get-LADMGroupMember -Group $Groups #| Export-Csv -Path "C:\temp\LADM_Export.csv" -Delimiter ";" -Encoding utf8
foreach ($memb in ($membs.Keys)) {
    $Values = Join-String -InputObject $membs.Item($memb) -Separator " "
    $Values = $Values.Replace('@',"")
    $Values = $Values.Replace('}',"")
    $Values = $Values.Replace('{',"")
    $Values = $Values.Replace('Name=',"")
    $memb+";"+$Values >> "C:\temp\Export_LADM.csv"
}
#Export-Excel -InputObject $membs -Path "C:\temp\Export.xlsx"
#Stop-Transcript