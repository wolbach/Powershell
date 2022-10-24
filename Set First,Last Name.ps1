$Users = Get-ADUser -SearchBase "OU=Trainer,OU=User,OU=SGB3,OU=Academy,DC=academy,DC=local" -Filter *

foreach($user in $Users){

    $sam = $user.SamAccountName

    $names = $sam.split(".") 

    Get-ADUser $user | Set-ADUser -Surname $names[1] -GivenName $names[0]
     
}