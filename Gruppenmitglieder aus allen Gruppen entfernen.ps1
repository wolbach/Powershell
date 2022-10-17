$TrainerGroup = Get-ADGroup -Identity "UG_Trainer"
$AllGroups = Get-ADGroup -SearchBase "OU=Groups,OU=SGB3,OU=Academy,DC=academy,DC=local" -Filter *
$users = Get-ADGroupMember -Identity $TrainerGroup

foreach($Group in $AllGroups){
    Remove-ADGroupMember -Members $users -Identity $Group -Confirm:$false
}
