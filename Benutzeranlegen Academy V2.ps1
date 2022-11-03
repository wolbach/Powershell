function New-VMMRole {
    param (
        $User,
        $art
    )
    $Sam = $User.SamAccountName
    $TRKonto = "ACADEMY\"+$Sam
    
    if ($art -eq "f") {
    
    $scopeToAdd = @()
        $scopeToAdd += Get-SCCloud -ID "7f2d03b7-cd8d-4d79-9859-4daee06e5671"
        $JobGroupID = [Guid]::NewGuid().ToString()
        Add-SCUserRolePermission -Cloud $cloud -JobGroup $JobGroupID
        Set-SCUserRole -JobGroup $JobGroupID -AddMember $TRKonto -AddScope $scopeToAdd -Permission @("CreateFromVHDOrTemplate", "Create", "AllowLocalAdmin", "PauseAndResume", "RemoteConnect", "Remove", "Shutdown", "Start", "Stop") -ShowPROTips $false -VMNetworkMaximumPerUser "11" -VMNetworkMaximum "11"
        Set-SCUserRoleQuota -Cloud $cloud -JobGroup $JobGroupID -CPUCount "8" -MemoryMB "16384" -StorageGB "2200" -UseCustomQuotaCountMaximum -VMCount "6"
        Set-SCUserRoleQuota -Cloud $cloud -JobGroup $JobGroupID -QuotaPerUser -CPUCount "8" -MemoryMB "16384" -StorageGB "2200" -UseCustomQuotaCountMaximum -VMCount "8"

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
    } elseif ($art -eq "o") {

        $Cloud = Get-SCCloud "Ondeso Training"

        $ACADuser = "ACADEMY\"+$User
        $JobGroupID = [Guid]::NewGuid().ToString()
        Get-SCUserRole -Name "Ondeso B" | Set-SCUserRole -AddMember $ACADuser -AddScope $Cloud -Permission @("AllowLocalAdmin", "RemoteConnect", "Start") -ShowPROTips $false -VMNetworkMaximumPerUser "2" -VMNetworkMaximum "2"
    
    }else{
    return "unexpected string has been received"
    }
}

function Generate-Password {

    $valid = $false
    while ($valid -eq $false) {
        
        $pwgen= -join ( (35..38) + (49..57) + (65..90) + (97..107) + (109..122) | Get-Random -Count 10 | Foreach-Object {[char]$_}) 

        $numCriteriaMet = (
          (
            ($pwgen -cmatch '[A-Z]'),    
            ($pwgen -match '[!@#%^&$]'),  
            ($pwgen -match '[0-9]')       
          ) -eq $true
        ).Count
        
        $valid = $numCriteriaMet -ge 3
        
         
        if ($valid){
            $pw = ConvertTo-SecureString -AsPlainText $pwgen -Force
        }


    }
  
}

function Create-User {
    param (
        $User
    )

    $UPN = ($User.vorname+"."+$User.name)+"@training.lug-ag.de"
    $sam = $User.vorname + "." + $User.name

    New-ADUser -AccountPassword $pw -Enabled $true -ChangePasswordAtLogon $false -CannotChangePassword $true -UserPrincipalName $UPN -DisplayName $sam -Name $sam -SurName $User.Name -GivenName $User.Vorname
    Add-ADGroupMember -Identity $Group -Members $sam
}

function Test-Credentials {
    param (
        
    )

    $domname = "ACADEMY\$sam"
    $creds = New-Object System.Management.Automation.PSCredential -ArgumentList ($domname, $pw)
    $cred = Get-Credential -Credential $creds
    $UserName = $cred.UserName
    $Password = $cred.GetNetworkCredential().Password
    $Root = "LDAP://" + ([ADSI]'').distinguishedName
    $Domain = New-Object System.DirectoryServices.DirectoryEntry($Root,$UserName,$Password)

    $valrunspace = [powershell]::Create()

    [void]$valrunspace.AddScript({
        param ($pw, $UPN)
    }).AddArgument($pw).AddArgument($UPN)

    $valrunspace.Close()

    if ($null -eq $Domain.name) {
        Write-Host "Not validated"
    }else{
        Write-Host "Validated"
    }
}

$dateipfad = "C:\Skripte\"
$users = Import-Csv -Delimiter ";" -LiteralPath "$dateipfad\user.csv"
$Group = $null
$kurs = $null

# Connecting Services
Connect-MsolService
Connect-MicrosoftTeams

Write-Host -ForegroundColor Red "Überprüfen, ob genug Lizenzen verfügbar sind!"

$kurs = Read-Host "Fachinformatiker-Kurs? y/n"


Test-Cred

$Group = Read-Host "Gruppenname eingeben"


if ($Group.contains("Ondeso")) {
    $kurs = "o"
}elseif ($Group.contains("FI")) {
    $kurs = "fi"
}

switch ($kurs) {
    "o" { 
        $grpath = "OU=Groups,OU=Firmenschulung,OU=Academy,DC=academy,DC=local" 
        $upath = "OU=User,OU=Firmenschulung,OU=Academy,DC=academy,DC=local"
        Write-Host "Ondeso"

    }
    "fi"{ 
        $grpath = "OU=Groups,OU=SGB3,OU=Academy,DC=academy,DC=local"
        $upath = "OU=User,OU=Firmenschulung,OU=Academy,DC=academy,DC=local"
        Write-Host "FI"
     }
    Default {
        Write-Error -Message "Nicht unterstützte Gruppenangabe"
    }
}
New-ADGroup -DisplayName $Group -GroupScope Universal -Path $grpath -Name $Group
Add-ADGroupMember -Identity "ACL_VMM_Users" -Members $Group

foreach ($usi in $users){

Generate-Password

# On-premise creation
Create-User -User $usi

if ($kurs -eq "y") {
    New-VMMRole -User $sam -art "f"
}elseif ($kurs -ne "n" -and $ondeso -eq "y"){
    $urole = Get-SCUserRole -Name "Ondeso B" 
    $members = $urole.Members

    foreach ($member in $members) {

        Set-SCUserRole -UserRole $urole -RemoveMember $member.Name
    }
    New-VMMRole -User $sam -art "o"
}

# Azure/M365 creation
New-Team -DisplayName $Group -Owner "admin@lug-ag.de" -Visibility Private
New-MsolUser -UserPrincipalName $UPN -FirstName $usi.vorname -LastName $usi.name -DisplayName $sam -Password $pw -LicenseAssignment "reseller-account:TEAMS_EXPLORATORY" -UsageLocation "DE"
sleep 10
Get-Team | where DisplayName -eq $Group |Add-TeamUser -User $UPN ## Hinzufügen funktioniert nicht

if (Test-Credentials -eq "OK") {
    "$UPN;$pwgen" >> "$dateipfad\Userlists\$Group.csv"
}

}


foreach ($usi in $users) {
    [string]$UPN = ($usi.vorname+"."+$usi.name)+"@training.lug-ag.de"
    $sam = $usi.vorname + "." + $usi.name
    #New-MsolUser -UserPrincipalName $UPN -FirstName $usi.vorname -LastName $usi.name -DisplayName $sam -Password $pw -LicenseAssignment "reseller-account:TEAMS_EXPLORATORY" -UsageLocation "DE"
    
    $valid = $false
    while ($valid -eq $false) {
        
        $pwgen= -join ( (35..38) + (49..57) + (65..90) + (97..107) + (109..122) | Get-Random -Count 10 | Foreach-Object {[char]$_}) 

        $numCriteriaMet = (
          (
            ($pwgen -cmatch '[A-Z]'),    
            ($pwgen -match '[!@#%^&$]'),  
            ($pwgen -match '[0-9]')       
          ) -eq $true
        ).Count
        
        $valid = $numCriteriaMet -ge 3
        
         
        if ($valid){
            $pw = ConvertTo-SecureString -AsPlainText $pwgen -Force
        }


    }
    
    Get-MsolUser -UserPrincipalName $UPN | Set-MsolUser -DisplayName $sam
    Set-MsolUserPassword -UserPrincipalName $UPN -NewPassword $pw
    
    Write-Host $UPN, $pwgen
sleep 10
#Get-Team | where DisplayName -eq $Group | Add-TeamUser -User $UPN ## Hinzufügen funktioniert nicht

Set-ADAccountPassword -Identity $sam -NewPassword $pw
Set-ADUser -Enabled $true -Identity $sam
}
