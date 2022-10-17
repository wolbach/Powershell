$users=$null
$Cloud =Get-SCCloud "Ondeso Training"

$users= Get-ADGroupMember -Identity "Ondeso 22-14"



foreach ($user in $users) {
     
    
    $userrole = Get-SCUserRole -Name $user.SamAccountName
    $ACADuser = "ACADEMY\"+$user.SamAccountName
    $JobGroupID = [Guid]::NewGuid().ToString()
    Get-SCUserRole -Name "Ondeso B" | Set-SCUserRole -AddMember $ACADuser -AddScope $Cloud -Permission @("AllowLocalAdmin", "RemoteConnect", "Start") -ShowPROTips $false -VMNetworkMaximumPerUser "2" -VMNetworkMaximum "2"
    
}

