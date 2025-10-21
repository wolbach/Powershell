## Class Definition
class VMMServer {
    [string]$VMMServerName

    [int] RestoreCheckpoint() {
        try {
            Get-SCVMMServer ($this.$VMMServerName)
        }catch{
            return "Failed to connect to VMM-Server - Aborting!"
        }
        
        $Site = Read-Host "Pattern for Restoration-VMs"

        if ($Site -eq "a") {
            $vms = Get-SCVirtualMachine | where Name -like "Ondeso Client A" 
            $vms += Get-SCVirtualMachine | where Name -like "Ondeso Client A*"

            foreach ($vm in $vms) {
            Get-SCVirtualMachine | Get-SCVMCheckpoint | Restore-Checkpoint 

            echo "VM $vm bearbeitet"
            sleep 5
            }
        
        } else {
            echo "Fehlerhafte Eingabe"
            return 0
        }
        return 1
    }
}