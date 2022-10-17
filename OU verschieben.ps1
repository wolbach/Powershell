$users = Get-ADUser -Filter * -SearchBase "OU=User,OU=Academy,DC=academy,DC=local"
$trainer = Get-ADGroupMember -Identity "Dig Officemanagement"

foreach ($traini in $trainer) {
    try {
    Move-ADObject -Identity $traini -TargetPath "OU=User,OU=SGB3,OU=Academy,DC=academy,DC=local"
}
catch {
    Write-Error -Message "Konnte nicht verschoben werden"
    exit
}
}