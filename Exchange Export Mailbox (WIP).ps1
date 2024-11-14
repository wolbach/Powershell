$ExchangeCred = Get-Credential -UserName "in-klr\administrator"
$ExchangeSess = New-PSSession -ConfigurationName Microsoft.Exchange -Credential $ExchangeCred -ConnectionUri "http://exchange-srv.in-klr.com/powershell/" -Authentication Kerberos

Import-PSSession $ExchangeSess -DisableNameChecking

while ($repeat) {
    
$MailboxName = Read-Host "Welche Mailbox soll exportiert werden?"
if (!(Get-Mailbox -Identity $MailboxName)) {
    $repeat = $true
} else {
    $repeat = $false
}
}

$PSTName = $MailboxName+".pst"
$TargetPath = Read-Host "Pfad auf dem die PST gespeichert werden soll"
$FullTargetPath = $TargetPath+$PSTName

Test-Path -Path $TargetPath


Remove-PSSession $ExchangeSess