$serv = "vmm-hv01"
$path = Read-Host "Bitte Zielpfad angeben"

$pssess = New-PSSession -ComputerName $serv
Import-PSSession $pssess

$ovms = Get-VM | where VMName -like "Ondeso Client B"
$ovms += Get-VM | where VMName -like "Ondeso Server B"

foreach ($ovm in $ovms){
    Export-VM -VMName $ovm -Path $path
}
Write-Host "Durchgelaufen!"