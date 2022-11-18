function New-VMMRole {
    param (
        $User,
        $art
    )
    $script:sam = $User.SamAccountName
    $TRKonto = "ACADEMY\"+$script:sam
    
    if ($art -eq "f") {
    
    $scopeToAdd = @()
        $scopeToAdd += Get-SCCloud -ID "7f2d03b7-cd8d-4d79-9859-4daee06e5671"
        $JobGroupID = [Guid]::NewGuid().ToString()
        Add-SCUserRolePermission -Cloud $cloud -JobGroup $JobGroupID
        Set-SCUserRole -JobGroup $JobGroupID -AddMember $TRKonto -AddScope $scopeToAdd -Permission @("CreateFromVHDOrTemplate", "Create", "AllowLocalAdmin", "PauseAndResume", "RemoteConnect", "Remove", "Shutdown", "Start", "Stop") -ShowPROTips $false -VMNetworkMaximumPerUser "11" -VMNetworkMaximum "11"
        Set-SCUserRoleQuota -Cloud $cloud -JobGroup $JobGroupID -CPUCount "8" -MemoryMB "16384" -StorageGB "2200" -UseCustomQuotaCountMaximum -VMCount "6"
        Set-SCUserRoleQuota -Cloud $cloud -JobGroup $JobGroupID -QuotaPerUser -CPUCount "8" -MemoryMB "16384" -StorageGB "2200" -UseCustomQuotaCountMaximum -VMCount "8"

        New-SCUserRole -Name $script:sam -UserRoleProfile "TenantAdmin" -JobGroup $JobGroupID
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

        $vmInternet = Get-SCVMNetwork -Name "Internet"
        Grant-SCResource -Resource $vmInternet -UserRoleName $script:sam

        $libResource = Get-SCVMTemplate -Name "Windows 10 21H2"
        Grant-SCResource -VMMServer $vmm -Resource $libResource -UserRoleName $script:sam
        $libResource = Get-SCVMTemplate -Name "Windows Server 2022"
        Grant-SCResource -VMMServer $vmm -Resource $libResource -UserRoleName $script:sam

    } elseif ($art -eq "o") {

        $Cloud = Get-SCCloud "Ondeso Training"
        $urole = Get-SCUserRole -Name "Ondeso B" 
        $members = $urole.Members

        $remurole = Read-Host "Sollen vorherige Mitglieder aus der Benutzerrolle entfernt werden? y/n"

        if ($remurole -eq "y") {
            
        foreach ($member in $members) {
            Set-SCUserRole -UserRole $urole -RemoveMember $member.Name
        } 
        }

        $JobGroupID = [Guid]::NewGuid().ToString()
        Get-SCUserRole -Name "Ondeso B" | Set-SCUserRole -AddMember $Group -AddScope $Cloud -Permission @("AllowLocalAdmin", "RemoteConnect", "Start") -ShowPROTips $false -VMNetworkMaximumPerUser "2" -VMNetworkMaximum "2"
    
    }else{
    return "unexpected string has been received"
    }
}

function Generate-Password {

    $valid = $false
    while ($valid -eq $false) {
        
        $script:pwgen= -join ( (35..38) + (49..57) + (65..90) + (97..107) + (109..122) | Get-Random -Count 10 | Foreach-Object {[char]$_}) 

        $numCriteriaMet = (
          (
            ($script:pwgen -cmatch '[A-Z]'),    
            ($script:pwgen -match '[!@#%^&$]'),  
            ($script:pwgen -match '[0-9]')       
          ) -eq $true
        ).Count
        
        $valid = $numCriteriaMet -ge 3
        
         
        if ($valid){
            $script:pw = ConvertTo-SecureString -AsPlainText $script:pwgen -Force
        }


    }
  
}

function Create-User {
    param (
        $User
    )

    if($User.Vorname.length + $User.Name.Length + 1 -ge 20){
        $User.Vorname = $User.Vorname.Remove(1)
        $User.Name = $User.Name

        if($User.Vorname.length + $User.Name.Length + 1 -gt 20){
            $User.Name = $User.Name.Remove(18)
        }
    } 

    $script:UPN = ($User.vorname+"."+$User.name)+"@academy.local"
    $script:msolupn = ($User.vorname+"."+$User.name)+"@training.lug-ag.de"
    $script:sam = $User.vorname + "." + $User.name
    $name = $User.vorname + " " + $User.name

    New-ADUser -AccountPassword $script:pw -Enabled $true -ChangePasswordAtLogon $false -CannotChangePassword $true -PasswordNeverExpires $true -UserPrincipalName $script:UPN -DisplayName $name -Name $name -SurName $User.Nachname -GivenName $User.Vorname -Path $upath -SamAccountName $script:sam -OtherAttributes @{accountExpires=$exp.AddDays($laufzeit);uid=$UPN}
    Add-ADGroupMember -Identity $Group -Members $script:sam
}

function Test-Credentials {
    param (
        
    )

    $domname = "ACADEMY\$script:sam"
    $creds = New-Object System.Management.Automation.PSCredential -ArgumentList ($domname, $script:pw)
    $cred = Get-Credential -Credential $creds
    $UserName = $cred.UserName
    $Password = $cred.GetNetworkCredential().Password
    $Root = "LDAP://" + ([ADSI]'').distinguishedName
    $Domain = New-Object System.DirectoryServices.DirectoryEntry($Root,$UserName,$Password)


    # Planned for 2.1: Msol Credential validation
<#     $valrunspace = [powershell]::Create()

    [void]$valrunspace.AddScript({
        param ($script:pw, $script:UPN)

    }).AddArgument($script:pw).AddArgument($script:UPN)

    $valrunspace.Close() #>

    if ($null -eq $Domain.name) {
        return "Not validated"
    }else{
        return "OK"
    }
}

$users = $null
$dateipfad = "C:\Skripte\"
$users = Import-Csv -Delimiter ";" -LiteralPath "$dateipfad\user.csv"
$Group = $null
$kurs = $null
$cont = $null
$exp = Get-Date

# Connecting Services
try {
    Get-MsolDomain -ErrorAction Stop > $null
}
catch {
    Connect-MsolService
    Connect-MicrosoftTeams
}

Write-Host -ForegroundColor Red "Überprüfen, ob genug Lizenzen verfügbar sind!"

$Group = Read-Host "Gruppenname eingeben"

try {
    (Get-ADGroup -Identity $Group -ErrorAction SilentlyContinue -or Get-MsolGroup)

}
catch {
    Write-Host "Gruppe existiert schon"
    $cont = Read-Host "Trotzdem fortfahren? y/n"
}

switch ($cont) {
    "n" { 
        exit 
    }
    $null { 
        New-ADGroup -DisplayName $Group -GroupScope Universal -Path $grpath -Name $Group 
        New-Team -DisplayName $Group -Owner "admin@lug-ag.de" -Visibility Private
    }
    Default {}
}

if ($Group.contains("Ondeso")) {
    $kurs = "o"
}elseif ($Group.contains("FI U")){
    $kurs = "fi"
}elseif ($Group.Contains("PPDT")){
    $kurs = "pp"
}elseif ($Group.Contains("DOM")){
    $kurs = "dom"
}elseif ($Group.Contains("E-Com")){
    $kurs = "ecom"
}elseif ($Group -eq "Trainers" -or "UG_Trainer"){
    $kurs = "traini"
}

switch ($kurs) {
    "o" { 

        $grpath = "OU=Groups,OU=Firmenschulung,OU=Academy,DC=academy,DC=local" 
        $upath = "OU=User,OU=Firmenschulung,OU=Academy,DC=academy,DC=local"
        $msolicense = "reseller-account:TEAMS_EXPLORATORY"
        $laufzeit = 35
        Write-Host "Ondeso"

    }
    "fi"{ 

        $grpath = "OU=Groups,OU=SGB3,OU=Academy,DC=academy,DC=local"
        $upath = "OU=User,OU=SGB3,OU=Academy,DC=academy,DC=local"
        $msolicense = "reseller-account:O365_BUSINESS_ESSENTIALS" 
        $laufzeit = 730
        Write-Host "Fachinformatiker"
     }
     "ecom"{

        $grpath = "OU=Groups,OU=SGB3,OU=Academy,DC=academy,DC=local"
        $upath = "OU=User,OU=SGB3,OU=Academy,DC=academy,DC=local"
        $msolicense = "reseller-account:O365_BUSINESS_PREMIUM"
        $laufzeit = 730
        Write-Host "Office-Kurs"

     }
     "dom"{
        $grpath = "OU=Groups,OU=SGB3,OU=Academy,DC=academy,DC=local"
        $upath = "OU=User,OU=SGB3,OU=Academy,DC=academy,DC=local"
        $msolicense = "reseller-account:O365_BUSINESS_PREMIUM"
        $Group = "DOM 365 Onboarding"
        $laufzeit = 130
        Write-Host "DOM"
        
     }
     "traini"{

        $upath = "OU=Trainer,OU=User,OU=SGB3,OU=Academy,DC=academy,DC=local" 
        $msolicense = "reseller-account:TEAMS_EXPLORATORY"
        $laufzeit = 1
        Write-Host "Trainer" 

     }
     "pp"{

        $grpath = "OU=Groups,OU=SGB3,OU=Academy,DC=academy,DC=local"
        $upath = "OU=User,OU=SGB3,OU=Academy,DC=academy,DC=local"
        $msolicense = "reseller-account:INTUNE_A_D"
        $laufzeit = 190
        Write-Host "PePe"

     }
    Default {
        Write-Error -Message "Nicht unterstützte Gruppenangabe" -Category InvalidType 
    }
}

Add-ADGroupMember -Identity "ACL_VMM_Users" -Members $Group

foreach ($usi in $users){

    $usi.Name = $usi.Name.replace("ü","ue")
    $usi.Name = $usi.Name.replace("Ü","Ue")
    $usi.Name = $usi.Name.replace("ö","oe")
    $usi.Name = $usi.Name.replace("Ö","Oe")
    $usi.Name = $usi.Name.replace("ä","ae")
    $usi.Name = $usi.Name.replace("Ä","Ae")
    $usi.Name = $usi.Name.replace("ß","ss")
    $usi.Name = $usi.Name.replace("é","e")
    $usi.Name = $usi.Name.replace(" ","-")

    $usi.Vorname = $usi.Vorname.replace("ü","ue")
    $usi.Vorname = $usi.Vorname.replace("Ü","Ue")
    $usi.Vorname = $usi.Vorname.replace("ö","oe")
    $usi.Vorname = $usi.Vorname.replace("Ö","Oe")
    $usi.Vorname = $usi.Vorname.replace("ä","ae")
    $usi.Vorname = $usi.Vorname.replace("Ä","Ae")
    $usi.Vorname = $usi.Vorname.replace("ß","ss")
    $usi.Vorname = $usi.Vorname.replace("é","e")
    $usi.Vorname = $usi.Vorname.replace(" ","-")

Generate-Password

# On-premise creation
Create-User -User $usi

if ($kurs -eq "fi") {

    New-VMMRole -User $script:sam -art "f"

}elseif ($kurs -eq "o"){
    
    New-VMMRole -User $script:sam -art "o"

}

# Azure/M365 creation
New-MsolUser -UserPrincipalName $script:msolupn -FirstName $usi.vorname -LastName $usi.name -DisplayName $script:sam.Replace("."," ") -Password $script:pw -UsageLocation "DE" 
Set-MsolUserLicense -UserPrincipalName $script:msolupn -AddLicenses $msolicense
sleep 10
Get-Team | where DisplayName -eq $Group | Add-TeamUser -User $script:msolupn

if (Test-Credentials -eq "OK") {
    "$script:msolupn;$script:sam;$script:pwgen" >> "$dateipfad\Userlists\$Group.csv"
}else{
    Write-Error -Message "Nutzerdaten von $sam konnten nicht validiert werden"
}
}