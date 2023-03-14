# gssntlm needed

[string]$userName = 'LG\adminmh'
[string]$userPassword = Read-Host -AsSecureString "Passwort eingeben"

# Convert to SecureString
[securestring]$secStringPassword = ConvertTo-SecureString $userPassword -AsPlainText -Force
[pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($userName, $secStringPassword)

$S = New-PSSession -ComputerName lgka-dc006 -Credential $credObject -Authentication Negotiate
Import-Module -PSsession $S -Name ActiveDirectory | Install-Module
#Hier Modulnam
