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
    $conf = Read-Host "Mit Updates fortfahren?"

    try {
    Download-WindowsUpdate -ComputerName $clunode -AcceptAll
    Install-WindowsUpdate -ComputerName $clunode -AcceptAll
    }
        catch {
    Write-Host "Download oder Installation fehlgeschlagen"
        }
    

    Resume-ClusterNode -TargetNode $clunode -Cluster $clu
    Write-Host "Knoten $clunode fortgesetzt"

        $volstate = Get-ClusterSharedVolume -Cluster $clu

    if ($volstate.State -eq ){

    }
}