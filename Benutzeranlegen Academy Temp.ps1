$dateipfad = "C:\Skripte\"
$user = Import-Csv -Delimiter ";" -LiteralPath "$dateipfad\user.csv"
$Group = $null

Connect-MsolService
Connect-MicrosoftTeams

$Group = Read-Host "Gruppenname eingeben:"

foreach ($usi in $user){
$UPN = ($usi.vorname+"."+$usi.name)+"@training.lug-ag.de"
$sam = $usi.vorname + "." + $usi.name

$pwgen= -join ( (33..39) + (49..57) + (65..90) + (97..107) + (109..122) | Get-Random -Count 10 | Foreach-Object {[char]$_})
$pw = ConvertTo-SecureString -AsPlainText $pwgen -Force 

New-ADUser -AccountPassword $pw -CannotChangePassword $true -UserPrincipalName $usi.UPN -DisplayName $sam -Name $sam

New-MsolUser -UserPrincipalName $UPN -FirstName $usi.vorname -LastName $usi.name -DisplayName ($usi.vorname+"."+$usi.name) -Password $pw -LicenseAssignment "reseller-account:O365_BUSINESS_PREMIUM" -UsageLocation "DE"
Get-Team | where DisplayName -eq $Group |Add-TeamUser -User $UPN

"$UPN;$pwgen" >> "$dateipfad\Userlists\$Group.csv"

}