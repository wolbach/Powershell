function Restore-VMMCheckpoint {
        [Parameter(mandatory=$true)]$VMMServer    

        try {
            Get-SCVMMServer $VMMServer
        }catch{
            Write-Host -ForeGroundColor Red "Failed to connect to VMM-Server - Aborting!"
            
            #return 0
        }
        
        [regex]$Site = Read-Host "Pattern for Restoration-VMs"

        
            $vms = Get-SCVirtualMachine | where Name -like $Site 
            <#
                Only used when you want to check a different but similar pattern additionally;
                Not required by default tho:
                $vms += Get-SCVirtualMachine | where Name -like $Site

            #>
            
        if ($Site -ne $null -or $Site -ne "") {
            foreach ($vm in $vms) {
                try {
                    Get-SCVirtualMachine | Get-SCVMCheckpoint | Restore-Checkpoint 

                    Write-Host -ForegroundColor Green "VM $vm bearbeitet"
                    sleep 5
                }
                catch {
                    Write-Host -ForegroundColor Red "Restoration of Checkpoint for machine $($vm.Name) was not successfull: ˋn $($error[-1])"
                }
            }
        
        } else {
            Write-Host -ForeGroundColor Red 'Fehlerhafte Eingabe: $vm was empty'
            return 0
        }
        return 1
    }
