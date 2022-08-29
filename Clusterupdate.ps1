if (-not(Get-Module failoverclusters))
{ Import-Module failoverclusters }

if (-not(Get-Module PSWindowsUpdate))
{ Import-Module PSWindowsUpdate }

$clu = Read-Host "Welches Cluster updaten?"
$clunodes = Get-ClusterNode -Cluster $clu

foreach ($clunode in $clunodes) {
    
    Suspend-ClusterNode -TargetNode $clunode -Cluster $clu -Drain
    Write-Host "Knoten $clunode wurde pausiert"

    Get-WindowsUpdate -ComputerName $clunode
    $conf = Read-Host "Mit Updates fortfahren? y/n"

    if ($conf -eq "y"){
    try {
    Download-WindowsUpdate -ComputerName $clunode -AcceptAll
    Install-WindowsUpdate -ComputerName $clunode -AcceptAll
    }
        catch {
    Write-Host "Download oder Installation fehlgeschlagen"
        }
    

    Resume-ClusterNode -TargetNode $clunode -Cluster $clu
    Write-Host "Knoten $clunode fortgesetzt"

        $cluvol = Get-ClusterSharedVolume -Cluster $clu
    
        # Vorerst ein Sleep von 16h, sollte durch etwas eleganteres ersetzt werden; Wird wegen Rebuild gemacht
        sleep -s 57.600

    } elseif ($conf -eq "n") {
        
    }
    else {
        Write-Host "Ungültige Eingabe"
    }
}
