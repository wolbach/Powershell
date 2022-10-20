<#
1.0.0 Anpassung der Domäne, der VMM-Erstellung; Erstellung Generate-Password; Fix für hinzufügen zu Team; Eingabe der Kursart und entsprechende Erstellung
#>

function New-VMMRole {
    param (
        $User
    )
    $Sam = $User.SamAccountName
    $TRKonto = "ACADEMY\"+$Sam
    

    $scopeToAdd = @()
        $scopeToAdd += Get-SCCloud -ID "7f2d03b7-cd8d-4d79-9859-4daee06e5671"
        $JobGroupID = [Guid]::NewGuid().ToString()
        Add-SCUserRolePermission -Cloud $cloud -JobGroup $JobGroupID
        Set-SCUserRole -JobGroup $JobGroupID -AddMember $TRKonto -AddScope $scopeToAdd -Permission @("CreateFromVHDOrTemplate", "Create", "AllowLocalAdmin", "PauseAndResume", "RemoteConnect", "Remove", "Shutdown", "Start", "Stop") -ShowPROTips $false -VMNetworkMaximumPerUser "11" -VMNetworkMaximum "11"
        Set-SCUserRoleQuota -Cloud $cloud -JobGroup $JobGroupID -CPUCount "8" -MemoryMB "16384" -StorageGB "2200" -UseCustomQuotaCountMaximum -VMCount "6"
        Set-SCUserRoleQuota -Cloud $cloud -JobGroup $JobGroupID -QuotaPerUser -CPUCount "8" -MemoryMB "16384" -StorageGB "2200" -UseCustomQuotaCountMaximum -VMCount "6"

        New-SCUserRole -Name $Sam -UserRoleProfile "TenantAdmin" -JobGroup $JobGroupID
        sleep 5
        $userRole =  Get-SCUserRole -VMMServer $vmm -Name $User.SamAccountName

        $vmNetwork = New-SCVMNetwork -AutoCreateSubnet -Name $Switch1 -LogicalNetwork $logicalNetwork -Description $User.SamAccountName
        Set-SCVMNetwork -VMNetwork $vmNetwork -RunAsynchronously -Owner $TRKonto -UserRole $userRole
    
        $vmNetwork = New-SCVMNetwork -AutoCreateSubnet -Name $Switch2 -LogicalNetwork $logicalNetwork -Description $User.SamAccountName
        Set-SCVMNetwork -VMNetwork $vmNetwork -RunAsynchronously -Owner $TRKonto -UserRole $userRole
    
        $vmNetwork = New-SCVMNetwork -AutoCreateSubnet -Name $Switch3 -LogicalNetwork $logicalNetwork -Description $User.SamAccountName
        Set-SCVMNetwork -VMNetwork $vmNetwork -RunAsynchronously -Owner $TRKonto -UserRole $userRole
    
        $vmNetwork = New-SCVMNetwork -AutoCreateSubnet -Name $Switch4 -LogicalNetwork $logicalNetwork -Description $User.SamAccountName
        Set-SCVMNetwork -VMNetwork $vmNetwork -RunAsynchronously -Owner $TRKonto -UserRole $userRole
    
        $vmNetwork = New-SCVMNetwork -AutoCreateSubnet -Name $Switch5 -LogicalNetwork $logicalNetwork -Description $User.SamAccountName
        Set-SCVMNetwork -VMNetwork $vmNetwork -RunAsynchronously -Owner $TRKonto -UserRole $userRole

        $libResource = Get-SCVMTemplate -Name "Windows 10 21H2"
        Grant-SCResource -VMMServer $vmm -Resource $libResource -UserRoleName $Sam
        $libResource = Get-SCVMTemplate -Name "Windows Server 2022 Standard (Desktop Experience)"
        Grant-SCResource -VMMServer $vmm -Resource $libResource -UserRoleName $Sam

}

function Generate-Password {

        $pwgen= -join ( (35..38) + (49..57) + (65..90) + (97..107) + (109..122) | Get-Random -Count 10 | Foreach-Object {[char]$_}) 

        $numCriteriaMet = (
          (
            ($pwgen -cmatch '[A-Z]'),    
            ($pwgen -match '[!@#%^&$]'),  
            ($pwgen -match '[0-9]')       
          ) -eq $true
        ).Count
        
        $valid = $numCriteriaMet -ge 3
        
        if (-not $valid) { 
            throw 'Invalid password.' 
        }elseif ($valid){
            $pw = ConvertTo-SecureString -AsPlainText $pwgen -Force
        }
  
}


$dateipfad = "C:\Skripte\"
$user = Import-Csv -Delimiter ";" -LiteralPath "$dateipfad\user.csv"
$Group = $null

# Connecting Services
Connect-MsolService
Connect-MicrosoftTeams

$kurs = Read-Host "Fachinformatiker-Kurs? y/n"

$Group = Read-Host "Gruppenname eingeben"

foreach ($usi in $user){
$UPN = ($usi.vorname+"."+$usi.name)+"@training.lug-ag.de"
$sam = $usi.vorname + "." + $usi.name

Generate-Password

# On-premise creation
New-ADUser -AccountPassword $pw -CannotChangePassword $true -UserPrincipalName $usi.UPN -DisplayName $sam -Name $usi.Name -GivenName $usi.Vorname 

if ($kurs -eq "y") {
    New-VMMRole -User $sam
}

# Azure/M365 creation
New-MsolUser -UserPrincipalName $UPN -FirstName $usi.vorname -LastName $usi.name -DisplayName $sam -Password $pw -LicenseAssignment "reseller-account:O365_BUSINESS_PREMIUM" -UsageLocation "DE"
Get-Team | where DisplayName -eq $Group |Add-TeamUser -User $UPN


"$UPN;$pwgen" >> "$dateipfad\Userlists\$Group.csv"

}