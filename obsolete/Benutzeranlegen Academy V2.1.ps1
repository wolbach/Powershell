function New-VMMRole {
    param (
        $User,
        $art
    )
    $TRKonto = "ACADEMY\"+$script:sam
    $Switch1 = "Netzwerk 1"
    $Switch2 = "Netzwerk 2"
    $Switch3 = "Netzwerk 3"
    $Switch4 = "Netzwerk 4"
    $Switch5 = "Netzwerk 5"
    $logicalNetwork = Get-SCLogicalNetwork -Name "LogicalNetwork"

    $vmm = Get-SCVMMServer "vmm01"

    if ($art -eq "f") {

    $cloud = Get-SCCloud -VMMServer $vmm -Name "Academy"
    
    $scopeToAdd = @()
        $scopeToAdd += Get-SCCloud -ID "7f2d03b7-cd8d-4d79-9859-4daee06e5671"
        $JobGroupID = [Guid]::NewGuid().ToString()
        
        Add-SCUserRolePermission -Cloud $cloud -JobGroup $JobGroupID
        Set-SCUserRole -JobGroup $JobGroupID -AddMember $TRKonto -AddScope $scopeToAdd -Permission @("CreateFromVHDOrTemplate", "Create", "AllowLocalAdmin", "PauseAndResume", "RemoteConnect", "Remove", "Shutdown", "Start", "Stop") -ShowPROTips $false -VMNetworkMaximumPerUser "11" -VMNetworkMaximum "11"
        Set-SCUserRoleQuota -Cloud $cloud -JobGroup $JobGroupID -CPUCount "8" -MemoryMB "16384" -StorageGB "2200" -UseCustomQuotaCountMaximum -VMCount "8"
        Set-SCUserRoleQuota -Cloud $cloud -JobGroup $JobGroupID -QuotaPerUser -CPUCount "8" -MemoryMB "16384" -StorageGB "2200" -UseCustomQuotaCountMaximum -VMCount "8"
        New-SCUserRole -Name $script:sam -UserRoleProfile "TenantAdmin" -JobGroup $JobGroupID

        sleep 5
        $userRole =  Get-SCUserRole -VMMServer $vmm -Name $sam

        $vmNetwork = New-SCVMNetwork -AutoCreateSubnet -Name $Switch1 -LogicalNetwork $logicalNetwork -Description $sam
        Set-SCVMNetwork -VMNetwork $vmNetwork -RunAsynchronously -Owner $TRKonto -UserRole $userRole
    
        $vmNetwork = New-SCVMNetwork -AutoCreateSubnet -Name $Switch2 -LogicalNetwork $logicalNetwork -Description $sam
        Set-SCVMNetwork -VMNetwork $vmNetwork -RunAsynchronously -Owner $TRKonto -UserRole $userRole
    
        $vmNetwork = New-SCVMNetwork -AutoCreateSubnet -Name $Switch3 -LogicalNetwork $logicalNetwork -Description $sam
        Set-SCVMNetwork -VMNetwork $vmNetwork -RunAsynchronously -Owner $TRKonto -UserRole $userRole
    
        $vmNetwork = New-SCVMNetwork -AutoCreateSubnet -Name $Switch4 -LogicalNetwork $logicalNetwork -Description $sam
        Set-SCVMNetwork -VMNetwork $vmNetwork -RunAsynchronously -Owner $TRKonto -UserRole $userRole
    
        $vmNetwork = New-SCVMNetwork -AutoCreateSubnet -Name $Switch5 -LogicalNetwork $logicalNetwork -Description $sam
        Set-SCVMNetwork -VMNetwork $vmNetwork -RunAsynchronously -Owner $TRKonto -UserRole $userRole

        $vmInternet = Get-SCVMNetwork -Name "Internet mit Proxy"
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
        #return 1
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

        #return $pw
    }
  
}

function Create-User {
    param (
    )

    if($usi.Vorname.length + $usi.Name.Length + 1 -ge 20){
        $usi.Vorname = $usi.Vorname.Remove(1)
        $usi.Name = $usi.Name

        if($usi.Vorname.length + $usi.Name.Length + 1 -gt 20){
            $usi.Name = $usi.Name.Remove(18)
        }
    } 

    $script:UPN = ($usi.vorname+"."+$usi.name)+"@academy.local"
    $script:msolupn = ($usi.vorname+"."+$usi.name)+"@training.lug-ag.de"
    $script:sam = $usi.vorname + "." + $usi.name
    $name = $usi.vorname + " " + $usi.name

    New-ADUser -AccountPassword $script:pw -Enabled $true -ChangePasswordAtLogon $false -CannotChangePassword $true -PasswordNeverExpires $true -UserPrincipalName $script:UPN -DisplayName $name -Name $name -SurName $Usi.Name -GivenName $Usi.Vorname -Path $upath -SamAccountName $script:sam -OtherAttributes @{accountExpires=$exp.AddDays($laufzeit);uid=$UPN}
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

    $ParamList = @{
        PW = $script:pw
        UPN = $script:UPN
    }

    [void]$valrunspace.AddScript({
        param ($PW, $UPN)

        $creds = New-Object System.Management.Automation.PSCredential -ArgumentList ($UPN, $PW)
        $cred = Get-Credential -credential $creds
        try{
            Connect-MsolService -Credential $creds
        } catch {
            return = "Msol-Authentifizierung fehlgeschlagen"
        }

    }).AddParameters($ParamList)

    $valrunspace.Close() #>

    if ($null -eq $Domain.name) {
        return "Not validated"
    }else{
        return "OK"
    }
}

function Validate-License {
    param (
        $AccSku
    )

    # Check License naming

    $mslicenses = Get-MsolAccountSku 

    $comp = Compare-Object -ReferenceObject $AccSku -DifferenceObject $mslicenses.AccountSkuId -IncludeEqual
    foreach ($c in $comp){
    if ($c.SideIndicator -eq "==") {

        $mslicense = Get-MsolAccountSku | where AccountSkuID -eq $c.InputObject
        $TNcount = $Users.Count
        $maxLicen = $mslicense.ActiveUnits
        $usedLicen = $mslicense.ConsumedUnits

        if (($usedLicen + $TNcount) -ge $maxLicen) {
            Write-Host -ForegroundColor Red "Nicht genügend Lizenzen verfügbar"
            Read-Host "Mit Enter fortfahren, wenn Lizenzen gekauft wurden"
            return
        }elseif (($usedLicen + $TNcount) -lt $maxLicen) {
            Write-Host "Genügend Lizenzen vorhanden"
            return
        }
    }}else {
        Write-Error -Message "Angegebene Lizenz ist ungültig!"
        exit
    }

    
}

$users = $null
$dateipfad = "C:\Skripte\"
$users = Import-Csv -Delimiter ";" -LiteralPath "$dateipfad\user.csv"
$user = $null
$Group = $null
$kurs = $null
$cont = $null
$exp = Get-Date
$pwgen = $null
$vmmtype = $null

# Connecting Services
try {
    Get-MsolDomain -ErrorAction Stop > $null
}
catch {
    Connect-MsolService
    Connect-MicrosoftTeams
}

$Group = Read-Host "Gruppenname eingeben"

$Grget = Get-ADGroup -Identity $Group
$msolGrget = Get-MsolGroup | where DisplayName -eq $Group
if ($Grget.Name -eq $Group -or $msolGrget.DisplayName -eq $Group) {
    Write-Host "Gruppe existiert schon"
    $cont = Read-Host "Trotzdem fortfahren? y/n"
}else {
    Write-Host "Gruppe ist frei"
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
}else{
    $kurs = "fi"
}

switch ($kurs) {
    "o" { 

        $grpath = "OU=Groups,OU=Firmenschulung,OU=Academy,DC=academy,DC=local" 
        $upath = "OU=User,OU=Firmenschulung,OU=Academy,DC=academy,DC=local"
        $msolicense = "reseller-account:TEAMS_EXPLORATORY"
        $vmmtype = "o"
        $laufzeit = 35
        Write-Host "Ondeso"

    }
    "fi"{ 

        $grpath = "OU=Groups,OU=SGB3,OU=Academy,DC=academy,DC=local"
        $upath = "OU=User,OU=SGB3,OU=Academy,DC=academy,DC=local"
        $msolicense = "reseller-account:O365_BUSINESS_PREMIUM"
        $vmmtype = "f"
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
        $Group = "DOM 365 Onboarding", "DOM 365"
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
        $msolicense = "reseller-account:O365_BUSINESS_PREMIUM"
        $laufzeit = 190
        Write-Host "PePe"

     }
    Default {
        Write-Error -Message "Nicht unterstützte Gruppenangabe" -Category InvalidType 
    }
}

Validate-License -AccSku $msolicense

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

Write-Host "Passwort wird generiert"
Generate-Password

# On-premise creation
Write-Host "Benutzer wird erstellt"
Create-User

    if ($null -ne $vmmtype){
        Write-Host "Benutzerrolle wird angelegt"
        New-VMMRole -User $script:sam -art $vmmtype
    }

# Azure/M365 creation

Write-Host "Msol-Benutzer wird erstellt"
New-MsolUser -UserPrincipalName $script:msolupn -FirstName $usi.vorname -LastName $usi.name -DisplayName $script:sam.replace("."," ") -Password $script:pw -UsageLocation "DE" 
Set-MsolUserLicense -UserPrincipalName $script:msolupn -AddLicenses $msolicense
sleep 10

Write-Host "Es wird versucht den User $msolupn zu pullen"
    while ($null -eq $msolcheck -or $Error -in $msolcheck) {
        $msolcheck = Get-MsolUser -UserPrincipalName $script:msolupn
        sleep 10
        # Falls das nicht hilft, muss nach der ObjektID des Benutzers in die Gruppe hinzugefügt werden
    }

    if ($null -ne $msolcheck) {
        foreach ($Gruppe in $Group) {
            $gruppie = Get-MsolGroup -SearchString $Gruppe | select ObjectID
            $userid = Get-MsolUser -SearchString $msolupn | select objectid
            Write-Host "Hinzufügen des Benutzers $msolupn zu der Gruppe " $gruppie.ObjectID.toString()
                if ($usi.Intune -eq 1) {
                Add-MsolGroupMember -GroupObjectId "048426db-bc07-4bce-b2dd-38bd3ea8fed0" -GroupMemberType User -GroupMemberObjectId $userid.ObjectId
            }
    # Mit MSTeams Modul, da Mail-enabled Gruppen nicht über Msol-Cmdlets gemanaged werden können
    Add-TeamUser -GroupId $gruppie.ObjectId.ToString() -User $msolupn -Role Member
    <# Add-MsolGroupMember -GroupObjectId $gruppie.ObjectId.ToString() -GroupMemberObjectId $userid.ObjectId.ToString() -GroupMemberType User -- not working becaue of mai-enabled group  #>
    # Alternativ: Get-Team | where DisplayName -eq $Group | Add-TeamUser -User $script:msolupn
    }

    foreach ($msolicense in $msolicense) {
        Write-Host "Setzen der Lizenz $msolicense"
        Set-MsolUserLicense -UserPrincipalName $script:msolupn -AddLicenses $msolicense
    }

    Write-Host "Testen der Credentials für $sam"
        if (Test-Credentials -eq "OK") {
            "$script:msolupn;$script:sam;$script:pwgen" >> "$dateipfad\Userlists\$Group.csv"
            Write-Host "Okidoki"
        }else{
            Write-Error -Message "Nutzerdaten von $sam konnten nicht validiert werden" -Category AuthenticationError
            Read-Host "Enter drücken um fortzufahren"
        }
    }
}