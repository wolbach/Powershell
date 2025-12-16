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
        [Parameter(Mandatory=$false)][regex]$searchPattern

        try {
            Get-SCVMMServer $VMMServer
        }catch{
            Write-Host -ForeGroundColor Red "Failed to connect to VMM-Server - Aborting!"

            #return 0
        }

        if($null -eq $searchPattern){
            $searchPattern = Read-Host "Pattern for Restoration-VMs"
        }


            $vms = Get-SCVirtualMachine | where Name -like $searchPattern
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
    [Parameter(Mandatory=$false)][switch]$HyperVMode
    [Parameter(Mandatory=$false)][regex]$searchPattern

try {
    Get-SCVMMServer $VMMServer
}
catch {
    Write-Host -ForeGroundColor Red "Failed to connect to VMM-Server - Aborting!"
}

if($null -eq $searchPattern){
    [regex]$searchPattern = Read-Host "Please input a search Pattern"
}
switch $HyperVMode {
    $_ -eq $true {
        $vms = Get-VM -Filter * | where Name -match $searchPattern
    }
    default {

         $vms = Get-SCVirtualMachine | where Name -match $searchPattern

        foreach ($vm in $vms) {
            try{
                $vm | Get-SCVMCheckpoint | Remove-SCVMCheckpoint
                Write-Host -ForeGroundColor Green "Removed Checkpoint for $($vm.Name)"

                $vm | Get-SCVMCheckpoint | New-SCVMCheckpoint
                Write-Host -ForeGroundColor Green "Created new Checkpoint for $($vm.Name)"
            }
            catch{
                Write-Host -ForegroundColor Red "Restoration of Checkpoint for machine $($vm.Name) was not successfull: ˋn $($error[-1])"
                continue
            }
        }
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
