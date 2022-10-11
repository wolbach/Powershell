$user = Import-Csv 

foreach ($usi in $user) {

    New-MsolUser 

$pwgen= -join ( (33..39) + (49..57) + (65..90) + (97..107) + (109..122) | Get-Random -Count 10 | Foreach-Object {[char]$_})
$pw = ConvertTo-SecureString -AsPlainText $pwgen -Force
}