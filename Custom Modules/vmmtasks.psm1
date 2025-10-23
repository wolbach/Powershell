function Check-ModuleRequirements {
    
    # TODO: Add a module manifest: https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/10-script-modules?view=powershell-7.5
    $moduleManifestParams = @{
        FunctionsToExport = 
        
    }
}

# ! Make sure to import the manifest, not the psm directly !

function Restore-VMMCheckpoint {
        [CmdletBinding()]
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

function New-VMMCheckpoint {
    [CmdletBinding()]
    [Parameter(mandatory=$true)]$VMMServer
    
try {
    Get-SCVMMServer $VMMServer    
}
catch {
    Write-Host -ForeGroundColor Red "Failed to connect to VMM-Server - Aborting!"
}


[regex]$Site = Read-Host "Please input a search Pattern"

if ($Site -ne $null -or $Site -ne "") {
    $vms = Get-SCVirtualMachine | where Name -like $Site 
    $vms += Get-SCVirtualMachine | where Name -like $Site

    foreach ($vm in $vms) {
       Get-SCVirtualMachine | Get-SCVMCheckpoint | Remove-SCVMCheckpoint
    
       Get-SCVirtualMachine | Get-SCVMCheckpoint | New-SCVMCheckpoint 

       Write-Host -ForegroundColor Red "Restoration of Checkpoint for machine $($vm.Name) was not successfull: ˋn $($error[-1])"
       sleep 5
    }else {
    Write-Host -ForeGroundColor Red 'Fehlerhafte Eingabe: $vm was empty'
    return 1
    }
}
}

function Add-VMMUserRole {
    [CmdletBinding()]
    [Parameter(mandatory=$true)]$ADGroup
    [Parameter(Mandatory=$true)]$Cloud
    [Parameter(Mandatory=$true)]$RoleName
    [Parameter(Mandatory=$false)]$Domain

<#
TODO:
- Check if GroupMembers were retrieved successfully
#>
$users=$null
$users= Get-ADGroupMember -Identity $ADGroup

# If Parameter Domain was not provided, set it to local computer scope
if (!$PSBoundParameters.ContainsKey("Domain")) {
    $Domain = "."
}

foreach ($user in $users) {
       
    $userrole = Get-SCUserRole -Name $user.SamAccountName
    $ACADuser = "$($Domain)\"+$user.SamAccountName
    $JobGroupID = [Guid]::NewGuid().ToString()
    Write-Host $userrole $ACADuser $JobGroupID
    Get-SCUserRole -Name $RoleName  | Set-SCUserRole -AddMember $ACADuser -AddScope $Cloud -Permission @("AllowLocalAdmin", "RemoteConnect", "Start") -ShowPROTips $false -VMNetworkMaximumPerUser "2" -VMNetworkMaximum "2"
    Write-Host -ForegroundColor Green ""
}


}