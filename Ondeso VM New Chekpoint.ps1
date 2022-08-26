$vmm = "vmm04.cloud.lug-ag.de"
Get-SCVMMServer $vmm

$Site = Read-Host "Welche Umgebung? a/b"

if ($Site -eq "a") {
    $vms = Get-SCVirtualMachine | where Name -like "Ondeso A" 
    $vms += Get-SCVirtualMachine | where Name -like "Ondeso A*"

    foreach ($vm in $vms) {
       Get-SCVirtualMachine | Get-SCVMCheckpoint | Remove-SCVMCheckpoint
    
       Get-SCVirtualMachine | Get-SCVMCheckpoint | New-SCVMCheckpoint 

       echo "VM $vm bearbeitet"
       sleep 5
    }
} elseif ($Site -eq "b") {
    $vms = Get-SCVirtualMachine | where Name -like "Ondeso B" 
    $vms += Get-SCVirtualMachine | where Name -like "Ondeso B*"

    foreach ($vm in $vms) {
       Get-SCVirtualMachine | Get-SCVMCheckpoint | Remove-SCVMCheckpoint
    
       Get-SCVirtualMachine | Get-SCVMCheckpoint | New-SCVMCheckpoint 

       echo "VM $vm bearbeitet"
       sleep 5
    }
} else {
    echo "Fehlerhafte Eingabe"
    return
}