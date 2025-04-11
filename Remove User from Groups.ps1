if(-not(Get-Module IpPbx)){
    Import-Module IpPbx
}

Connect-IpPbx -ServerName "SWYX-SRV"

do{
$kürzel = Read-Host "Benutzerkürzel (z.B. MAH)"

$targetUser = Get-IpPbxUser -UserName $kürzel
}while($targetUser -eq $null)

$UserName = $targetUser.Name
$UserGroups = Get-IpPbxUserGroupMapping -UserName $UserName
$GroupCount = 0

foreach($userGroup in $UserGroups){
    $GroupData = $UserGroups.Get($GroupCount)
    $GroupName = $GroupData.Name
    Write-Host "($GroupCount)"$GroupName
    $GroupCount++
}

[array]$targetGroups = (Read-Host "Welche Gruppen sollen entfernt werden?").Replace(" ", "").Split(",")

<# $CheckEntry = (
    ($targetGroup.Count -le 1),
    ($targetGroup -ccontains [char])
) #>

foreach($targetGroup in $targetGroups){
    $removeGroup = $userGroups[$targetGroup].Name
    if($null -ne $targetGroup){
        $GroupName = Get-IpPbxGroup -GroupName $removeGroup
        Remove-IpPbxGroupMember -GroupName $GroupName.Name -UserName $UserName
    }
    
}
Write-Host -ForegroundColor Red "Nicht vergessen die Gruppendurchwahl zu ändern!"