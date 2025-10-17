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
            Write-Host $grp.DisplayName # Not tested!
            # Get-ADGroupMember only applies when the local Admin Groups are administered through AD
            $members.Add($grp.samaccountname, @(Get-ADGroupMember $grp.samaccountname | select Name))
        }
        return $members
    }else {
        throw 'Parameter "Group" is not of Tyoe Array' 
    }
    
}

#Start-Transcript -OutputDirectory "C:\temp"
if(!(Test-Path "C:\temp\Export_LADM.csv")){
    New-Item -Path "C:\temp" -Name "Export_LADM.csv" -ItemType File
}else{
    $fileprompt = Read-Host "File Export_LADM.csv already exists: Do you want to renew it? (y/n)"
    if($fileprompt -eq "y"){
        Remove-Item "C:\temp\Export_LADM.csv"
        New-Item -Path "C:\temp" -Name "Export_LADM.csv" -ItemType File
    }else{
        continue
    }
}
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
