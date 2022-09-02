<#Änderungslog

V2.6 Änderung der Vorlagen in KA HN S
     Standort S hinzugefügt
     Änderungslog hinzugefügt
     nicht funktionierende Else entfernt
V3.0 Objektorientiertes Design
     Vorlagen überarbeitet
V3.1 Anpassung an den neuen VMM in KA
V3.2 Fehler im Benutzeranlegenteil beseitigt. Es fehlte ein "s"
V3.3 Nürnberg VMM angepasst auf den neuen VMM
V3.4 DCs angepasst
v3.5 Pfade nach Heilbronn angepasst
V3.6 Pfade nach Stuttgart angepasst
     Vorlagen angepasst
V3.7 Pfade nach Karlsruhe angepasst
v3.7.1 Pfade richtig angepasst
v3.8 Vorlagen in KA angepasst
V3.9 Fileserver Pfade an neuen HN-AWFS02 angepasst
V3.9.1 Server 19 Vorlage KA
V3.9.2 1903 Vorlage KA
V3.9.3 Visual Studio 2019 Vorlage KA
V3.9.4 Anpassung KA Quotas
V3.9.5 UID Attribute hinzugefügt | repadmin /syncnow /Adep entfernt (Groupgen)
V3.9.6 SG_remotezugriff für VMM Benutzer hinzugefügt / längere Pause für NBG (Homelaufwerk)
V3.9.6 Passwort generierer unter usergen / CSV ausgabe überarbeitet unter usergen + Skriptteil / längere pause bei grpgen von 10s auf 30s
V3.9.8 Password never expires
V4.0.0 "Remote" Standort / Ondeso Abfrage / PM Abfrage
V4.1.0 O365 Benutzer Lizenzsierung + Teams erstellen - PMuser wech + O365 Benutzer erstellt
V4.1.1 Ondeso User Lizenzvergabe angepasst (nur Teams)
V4.1.2 VMMOndeso Hotfix
V4.1.3 Ubuntu für alle
V4.1.4 Gruppenzugehörigkeit Nürnberg angepasst / Änderung an Passwortgenerierung
V4.1.5 Gruppenexistenz-Prüfung hinzugefügt + Abfrage nach Trainerrechten, Anpassen der Erstellungs-OU + Überarbeitung der Gruppenprüfung
#>

<#

ToDo:

-   entfernen von abfrage nach sgb oder firmenkunden
-   Exception für Gruppenwarnung einbauen
-   VMM-Rollenerstellung anpassen --> Zuweisen von Admin-Rollen für Trainer u. Co
-   Add-TeamUser überarbeiten /wg ganzes Team wird hinzugefügt 

-   UI-Implementierung --> ongoing

#>

###Module importieren 


if (-not(Get-Module ActiveDirectory))
{ Import-Module ActiveDirectory }

if (-not(Get-Module virtualmachinemanager))
{ Import-Module virtualmachinemanager }

if (-not(Get-Module microsoftteams))
{ Import-Module microsoftteams}

if (-not(Get-Module msonline))
{ Import-Module msonline}



###Variablen deklarieren

$Users = Import-Csv C:\skripts\user.csv -Delimiter ";" -Encoding UTF8
$lizis = $null
$lizan = $null
$lizis = $Users | Measure-Object
$lizan = $lizis.Count
$Standort = $null
$Group = $null
$grouppruef = $null
$VMMuser = $null
$exp = Get-Date
$Switch1 = 'Netzwerk 1'
$Switch2 = 'Netzwerk 2'
$Switch3 = 'Netzwerk 3'
$Switch4 = 'Netzwerk 4'
$Switch5 = 'Netzwerk 5'
$trainer = $null
$trainers = "Trainers"
$Seminartyp = $null
$OU = $null
$OUGroup = $null
$MyVMM = $null
$dauer = $null
$dauerpruef = $null
$Benutzername = $null
$exportdatei = $null
$pw = $null
$pwgen = $null
$ONDESOuser = $null
$O365tn = $null
$a = $null
$Zahl = $null
$UPN = $null
$opruef =$null
$trainis =$null
$traini =$null
$membis = $null
$membi =$null
$trainiupn = $null
$teampruef = $null
$membiupn = $null
$membiiupn = $null
$membii = $null
$LizenzAbfrage = $null


## Connect O365

while($LizenzAbfrage -ne "y"){
    Write-Host "Bitte prüfen, ob genug Basic / Standard / Teams Lizenzen frei sind!"
    $LizenzAbfrage = Read-Host -Prompt "Wurden die Lizenzen gekauft bzw. sind genügend verfügbar? 
    Es werden mindestens $lizan Lizenzen benötigt! [y/n]"
}

Write-Host "training.lug-ag.de MS365 Admin eingeben"
Connect-MsolService
Connect-MicrosoftTeams


##Umlaute / Leerzeichen entfernen

foreach($user in $Users){

    $user.Name = $user.Name.replace("ü","ue")
    $user.Name = $user.Name.replace("Ü","Ue")
    $user.Name = $user.Name.replace("ö","oe")
    $user.Name = $user.Name.replace("Ö","Oe")
    $user.Name = $user.Name.replace("ä","ae")
    $user.Name = $user.Name.replace("Ä","Ae")
    $user.Name = $user.Name.replace("ß","ss")
    $user.Name = $user.Name.replace("é","e")
    $user.Name = $user.Name.replace(" ","-")

    $user.Vorname = $user.Vorname.replace("ü","ue")
    $user.Vorname = $user.Vorname.replace("Ü","Ue")
    $user.Vorname = $user.Vorname.replace("ö","oe")
    $user.Vorname = $user.Vorname.replace("Ö","Oe")
    $user.Vorname = $user.Vorname.replace("ä","ae")
    $user.Vorname = $user.Vorname.replace("Ä","Ae")
    $user.Vorname = $user.Vorname.replace("ß","ss")
    $user.Vorname = $user.Vorname.replace("é","e")
    $user.Vorname = $user.Vorname.replace(" ","-")

}

##Variablen Abfragen

while($Standort  -ne "hn" -and $Standort -ne "ka" -and $Standort -ne "nbg" -and $Standort -ne "s" -and $Standort -ne "r"){

    $Standort = Read-Host -Prompt "Wählen Sie einen Standort aus:(hn,nbg,ka,s,r)"

    switch($Standort){

        ka {"Karlsruhe"}
        hn {"Heilbronn"}
        nbg {"Nürnberg"}
        S {"Stuttgart"}
        r {"Remote"}
        default {"Fehler bitte Standort eingeben"}
    }
}

            if($Standort -eq "ka"){

            $pfad = "\\awfs01\Homelaufwerk"
            $KLpfad= "\\awfs01\Kursfreigaben"

            }

            if($Standort -eq "nbg"){

            $pfad = "\\nbg-awfs01\Homelaufwerk"
            $KLpfad= "\\nbg-awfs01\Kursfreigaben"

            }

            if($Standort -eq "s"){

            $pfad = "\\s-awfs03\Freigaben\Homelaufwerk"
            $KLpfad= "\\s-awfs03\Freigaben\Kursfreigaben"

            }

            if($Standort -eq "hn"){

            $pfad = "\\hn-awfs02\Freigaben\Homelaufwerk"
            $KLpfad= "\\hn-awfs02\Freigaben\Kursfreigaben"

            }

            if($Standort -eq "r"){

            $pfad = $null
            $KLpfad= "\\awfs01\Kursfreigaben"

            }

            while($trainer -ne "y" -and $trainer -ne "n"){

                if (($trainer = Read-Host -Prompt "Traineraccount? [y/n]") -ne "y" -and $trainer -ne "n") {
                    Write-Host "Bitte y oder n eingeben"
                    exit
                }
    
            }

        while($grouppruef -ne "y"){

            if ($trainer -eq "y") {
                $Group = "UG_Trainer"
                $grouppruef = "y"
            }else{
            $Group = Read-Host -Prompt "Bitte Gruppenname eingeben"
            Write-Host $Group
            $grouppruef = Read-Host -Prompt "Ist die Gruppe korrekt geschrieben? [y/n]"
            }
        }

        while($VMMuser -ne "y" -and $VMMuser -ne "n"){

            $VMMuser = read-host -Prompt "VMM user [y/n]"

            if($VMMuser -ne "y" -and $VMMuser -ne "n"){
                Write-Host "Bitte y oder n eingeben"
                }
        }

        while($O365tn -ne "y" -and $O365tn -ne "n"){

            $O365tn = read-host -Prompt "Office 365 Kurs? [y/n]"

            if($O365tn -ne "y" -and $O365tn -ne "n"){
                Write-Host "Bitte y oder n eingeben"
                }
        }

        while($ONDESOuser -ne "y" -and $ONDESOuser -ne "n" ){

            $ONDESOuser= read-host -Prompt "Ondeso user [y/n]"

            if($ONDESOuser -ne "y" -and $ONDESOuser -ne "n"){
                Write-Host "Bitte y oder n eingeben"
                if($ONDESOuser -eq "y"){
                $VMMuser = $null
                    }
                }
        }

        while($dauerpruef -ne "y"){

            $dauer = read-host -Prompt "Bitte Dauer des Kurses in Tagen + 1 angeben"
            Write-Host $dauer
            $dauerpruef = Read-Host -Prompt "Ist die Dauer korrekt? [y/n]"

        }

while($Seminartyp -ne "s" -and $Seminartyp -ne "f"){

    if ($trainers -eq "n") {
        $Seminartyp = read-host -Prompt "SGB3 oder Firmenseminar? [s/f]"
    } else {
        $Seminartyp = "trainer"
    }

    if($Seminartyp -ne "s" -and $Seminartyp -ne "f"){
        Write-Host "Bitte s oder f eingeben"
        }
}
            if($Seminartyp -eq "s"){
            $OU = 'OU=SGB3,OU=Teilnehmer,OU=Training,DC=training,DC=lug-ag,DC=de'
            $OUGroup = 'OU=Kurs,OU=Gruppen,OU=Training,DC=training,DC=lug-ag,DC=de'
            }
            elseif($Seminartyp -eq "f"){
            $OU = 'OU=Firmenschulung,OU=Teilnehmer,OU=Training,DC=training,DC=lug-ag,DC=de'
            $OUGroup = 'OU=Firmenschulung,OU=Gruppen,OU=Training,DC=training,DC=lug-ag,DC=de'
            }
            elseif ($Seminartyp -eq "trainer") {
               $OU = 'OU=Trainer,OU=Training,DC=training,DC=lug-ag,DC=de'
               $OUGroup = 'OU=Firmenschulung,OU=Gruppen,OU=Training,DC=training,DC=lug-ag,DC=de'
            }


### Funktionen


function CreateUser($cuVorname, $cuNachname){


    $Konto = $cuVorname + "." + $cuNachname
    $TRKonto = "Training\" + $Konto
    $Benutzername = $cuNachname + " " + $cuVorname
    $uid = $Konto + "@training.lug-ag.de"
    $pwgen= -join ( (33..39) + (49..57) + (65..90) + (97..107) + (109..122) | Get-Random -Count 10 | Foreach-Object {[char]$_})
    $pw = ConvertTo-SecureString -AsPlainText $pwgen -Force

    if(-not(Get-ADuser -Filter {samaccountname -eq $Benutzername} -Server "training.lug-ag.de")){
        New-ADUser -Server "training.lug-ag.de" -Name $Benutzername -DisplayName ($User.Name + " " + $User.Vorname) -description $Group -UserPrincipalName ($Konto + "@training.lug-ag.de") -SamAccountName $Konto -GivenName $User.Vorname -Surname $User.Name -Path $OU –AccountPassword $pw -PasswordNeverExpires $true -Enabled 1 -OtherAttributes @{accountExpires=$exp.AddDays($dauer);uid=$uid}
        Add-adgroupmember -Identity $Group -Server "training.lug-ag.de" -Members $Konto

        "$cuVorname;$cuNachname;$Konto;$pwgen" >> $exportdatei

        return "Benutzer $Konto wurde angelegt"
    }
    else{return "Benutzer $Konto existiert schon"  }
}

function Homelaufwerkgen($cuVorname, $cuNachname, $pfad){

    $Konto = $cuVorname + "." + $cuNachname
    $TRKonto = "Training\" + $Konto
    $Komppfadh = $pfad + "\" + $Konto


    ###Homelaufwerk erstellen und berechtigen
    New-Item -type directory -name $Konto -path $pfad
    Start-Sleep -Seconds 30    

    $ac2 = get-acl $Komppfadh
    $BR2=new-object system.security.accesscontrol.filesystemaccessrule($TRKonto,"Modify",3,0,"allow")
    $ac2.setaccessrule($BR2)

    set-acl $Komppfadh $ac2

    return "Homelaufwerk $Komppfadh wurde angelegt"

}

function Gruppengen($Group,$OUGroup,$Klpfad){
    $TRGroup = "Training\" + $Group
    $Komppfad = $Klpfad + "\" + $Group
    
    if(-not(Get-ADGroup -Filter {name -eq $Group} -Server "Training.lug-ag.de")){
        new-adgroup -GroupScope Universal -Name $Group -Path $OUGroup -Server "training.lug-ag.de"
    } else {
        return "ACHTUNG! Gruppe existiert schon"
        
        $fortf = Read-Host "Trotzdem fortfahren? y/n"
        if ($fortf = "y") {
            Start-Sleep -Seconds 15
        }else {
            exit
        }
       
    }
    
    
    sleep -Seconds 30

    
    if(-not(Get-Item -Path $Komppfad -Filter{name -eq $group} -ErrorAction SilentlyContinue )){
        New-Item -type directory -name $Group -path $Klpfad

        $ac1 = get-acl $Komppfad
        $BR1 = new-object system.security.accesscontrol.filesystemaccessrule($TRGroup,"Modify",3,0,"allow")
        $ac1.setaccessrule($BR1)

        set-acl $Komppfad $ac1
    return "Die $Group wurde erstellt und $Komppfad wurde angelegt und berechtigt"
    }
}

function VMMrolegen($cuVorname, $cuNachname, $Standort){
    $Konto = $cuVorname + "." + $cuNachname
    $TRKonto = "Training\" + $Konto

    <#if($Standort -eq "nbg"){

        repadmin /syncall training.lug-ag.de /AdeP

        $MyVMM = "nbg-vmm.cloud.lug-ag.de"
        Get-SCVMMServer -ComputerName $MyVMM
        $cloud = Get-SCCloud -Name Training

        ###VMM Userrole erstellen + Member hinzufügen
        $scopeToAdd = @()
        $scopeToAdd += Get-SCCloud -ID "e16e8268-5de5-4ffd-87f5-db9f17771051"
        $JobGroupID = [Guid]::NewGuid().ToString()
        Add-SCUserRolePermission -Cloud $cloud -JobGroup $JobGroupID
        Set-SCUserRole -JobGroup $JobGroupID -AddMember $TRKonto -AddScope $scopeToAdd -Permission @("CreateFromVHDOrTemplate", "Create", "AllowLocalAdmin", "PauseAndResume", "RemoteConnect", "Remove", "Shutdown", "Start", "Stop") -ShowPROTips $false -VMNetworkMaximumPerUser "11" -VMNetworkMaximum "11"
        Set-SCUserRoleQuota -Cloud $cloud -JobGroup $JobGroupID -CPUCount "10" -MemoryMB "20480" -StorageGB "1200" -UseCustomQuotaCountMaximum -VMCount "8"
        Set-SCUserRoleQuota -Cloud $cloud -JobGroup $JobGroupID -QuotaPerUser -CPUCount "10" -MemoryMB "20480" -StorageGB "1200" -UseCustomQuotaCountMaximum -VMCount "8"

        $libResource = Get-SCVMTemplate -Name "Windows 10 Edu v1703"
        Grant-SCResource -Resource $libResource -JobGroup $JobGroupID
        $libResource = Get-SCVMTemplate -Name "Windows 10 Edu v1703 (Visual Studio)"
        Grant-SCResource -Resource $libResource -JobGroup $JobGroupID
        $libResource = Get-SCVMTemplate -Name "Windows 8.1 Enterprise"
        Grant-SCResource -Resource $libResource -JobGroup $JobGroupID
        $libResource = Get-SCVMTemplate -Name "Windows Server 2012 R2"
        Grant-SCResource -Resource $libResource -JobGroup $JobGroupID
        $libResource = Get-SCVMTemplate -Name "Windows Server 2016 v1607"
        Grant-SCResource -Resource $libResource -JobGroup $JobGroupID
        $libResource = Get-SCVMNetwork -Name "Internet"
        Grant-SCResource -Resource $libResource -JobGroup $JobGroupID
        $libResource = Get-SCVMTemplate -Name "Pfsense 2.3.4"
        Grant-SCResource -Resource $libResource -JobGroup $JobGroupID


        New-SCUserRole -Name $Konto -UserRoleProfile "TenantAdmin" -Description $Group -JobGroup $JobGroupID
    }#>



    if($Standort -eq "ka" -or $Standort -eq "s" -or $Standort -eq "hn" -or $Standort -eq "r" -or $Standort -eq "nbg"){

        $MyVMM = "vmm04.cloud.lug-ag.de"
        Get-SCVMMServer -ComputerName $MyVMM
        $cloud = Get-SCCloud -Name Training

        $scopeToAdd = @()
        $scopeToAdd += Get-SCCloud -ID "41646759-ff2b-402a-a472-a37391e3664f"
        $JobGroupID = [Guid]::NewGuid().ToString()
        Add-SCUserRolePermission -Cloud $cloud -JobGroup $JobGroupID
        Set-SCUserRole -JobGroup $JobGroupID -AddMember $TRKonto -AddScope $scopeToAdd -Permission @("CreateFromVHDOrTemplate", "Create", "AllowLocalAdmin", "PauseAndResume", "RemoteConnect", "Remove", "Shutdown", "Start", "Stop") -ShowPROTips $false -VMNetworkMaximumPerUser "11" -VMNetworkMaximum "11"
        Set-SCUserRoleQuota -Cloud $cloud -JobGroup $JobGroupID -CPUCount "10" -MemoryMB "20480" -StorageGB "2200" -UseCustomQuotaCountMaximum -VMCount "8"
        Set-SCUserRoleQuota -Cloud $cloud -JobGroup $JobGroupID -QuotaPerUser -CPUCount "10" -MemoryMB "20480" -StorageGB "2200" -UseCustomQuotaCountMaximum -VMCount "8"

        $libResource = Get-SCVMTemplate -Name "Windows 10 Edu v1903"
        Grant-SCResource -Resource $libResource -JobGroup $JobGroupID
        $libResource = Get-SCVMTemplate -Name "(Visual Studio 2019) Windows 10 Edu v1903"
        Grant-SCResource -Resource $libResource -JobGroup $JobGroupID
        $libResource = Get-SCVMTemplate -Name "Windows 8.1 Enterprise v9600"
        Grant-SCResource -Resource $libResource -JobGroup $JobGroupID
        $libResource = Get-SCVMTemplate -Name "Windows Server 2012 R2"
        Grant-SCResource -Resource $libResource -JobGroup $JobGroupID
        $libResource = Get-SCVMTemplate -Name "Windows Server 2016 v1607"
        Grant-SCResource -Resource $libResource -JobGroup $JobGroupID
        $libResource = Get-SCVMTemplate -Name "Windows Server 2019 v1809"
        Grant-SCResource -Resource $libResource -JobGroup $JobGroupID
        $libResource = Get-SCVMTemplate -Name "Windows Server 2016 v1607 (Core)"
        Grant-SCResource -Resource $libResource -JobGroup $JobGroupID
        $libResource = Get-SCVMTemplate -Name "Ubuntu 1904"
        Grant-SCResource -Resource $libResource -JobGroup $JobGroupID
        $libResource = Get-SCVMNetwork -Name "Internet"
        Grant-SCResource -Resource $libResource -JobGroup $JobGroupID
        

        New-SCUserRole -Name $Konto -UserRoleProfile "TenantAdmin" -Description $Group -JobGroup $JobGroupID

    }

    $userRole = Get-SCUserRole -Name $Konto

    $logicalNetwork = Get-SCLogicalNetwork -Name "VM-CrossHypervisor-VLANs"
    $vmNetwork = New-SCVMNetwork -AutoCreateSubnet -Name $Switch1 -LogicalNetwork $logicalNetwork -Description $Group
    Set-SCVMNetwork -VMNetwork $vmNetwork -RunAsynchronously -Owner $TRKonto -UserRole $userRole

    $vmNetwork = New-SCVMNetwork -AutoCreateSubnet -Name $Switch2 -LogicalNetwork $logicalNetwork -Description $Group
    Set-SCVMNetwork -VMNetwork $vmNetwork -RunAsynchronously -Owner $TRKonto -UserRole $userRole

    $vmNetwork = New-SCVMNetwork -AutoCreateSubnet -Name $Switch3 -LogicalNetwork $logicalNetwork -Description $Group
    Set-SCVMNetwork -VMNetwork $vmNetwork -RunAsynchronously -Owner $TRKonto -UserRole $userRole

    $vmNetwork = New-SCVMNetwork -AutoCreateSubnet -Name $Switch4 -LogicalNetwork $logicalNetwork -Description $Group
    Set-SCVMNetwork -VMNetwork $vmNetwork -RunAsynchronously -Owner $TRKonto -UserRole $userRole

    $vmNetwork = New-SCVMNetwork -AutoCreateSubnet -Name $Switch5 -LogicalNetwork $logicalNetwork -Description $Group
    Set-SCVMNetwork -VMNetwork $vmNetwork -RunAsynchronously -Owner $TRKonto -UserRole $userRole

    }

function VMMondeso ($cuVorname, $cuNachname, $Standort){
    $MyVMM = "vmm04.cloud.lug-ag.de"
    Get-SCVMMServer -ComputerName $MyVMM
    $cloud = Get-SCCloud -Name Training
    
    
    $Konto = $cuVorname + "." + $cuNachname
    $TRKonto = "Training\" + $Konto

    $scopeToAdd += Get-SCCloud -name "Training"
    Get-SCUserRole -Name "Ondeso" | Set-SCUserRole -AddMember $TRKonto -AddScope $scopeToAdd -Permission @("AllowLocalAdmin", "RemoteConnect", "Start") -ShowPROTips $false -VMNetworkMaximumPerUser "2" -VMNetworkMaximum "2"
    #$libResource = Get-SCVMNetwork -Name "Internet"
    #Grant-SCResource -Resource $libResource

}

#Skriptteil

Gruppengen -Group $Group -OUGroup $OUGroup -Klpfad $KLpfad
$exportdatei = "C:\skripts\Userlists\$Group.csv"

if(-not(Get-ChildItem $exportdatei -ErrorAction Ignore)){
New-Item $exportdatei
"Vorname;Nachname;Benutzername;Passwort" > $exportdatei
}


Foreach($user in $Users){

    $CUVorname = $User.Vorname
    $CUNachname = $user.Name

    if($cuVorname.length + $CuNachname.Length + 1 -gt 20){
            $cuVorname = $cuVorname.remove(1)
            $CuNachname = $CuNachname
     

            if($cuVorname.length + $CuNachname.Length + 1 -gt 20){
                $CuNachname = $CuNachname.Remove(18)
            }

        } 


    CreateUser -cuVorname $CUVorname -cuNachname $CUNachname
    Start-Sleep -Seconds 30
    if($Standort -eq "nbg"){
        sleep -Seconds 90
    }

    if($null -ne $pfad){
        Homelaufwerkgen -cuVorname $CUVorname -cuNachname $CUNachname -pfad $pfad
    }

    if($VMMuser -eq "y"){
        VMMrolegen -cuVorname $CUVorname -cuNachname $CUNachname -Standort $Standort
    }

    if($ONDESOuser -eq "y"){
        VMMondeso -cuVorname $CUVorname -cuNachname $CUNachname -Standort $Standort
    }

    
}



if($Standort -eq "ka" -or $Standort -eq "s" -or $Standort -eq "hn" -or $Standort -eq "r" -or $Standort -eq "nbg"){
        Add-ADGroupMember -Identity "SG_rdszugriff" -Members "$Group" -Server "training.lug-ag.de"
        Add-ADGroupMember -Identity "SG_rdszugriff_KZH" -Members "$Group" -Server "training.lug-ag.de"
        Add-ADGroupMember -Identity "sg_rdszugriff_APP_Explorer" -Members "$Group" -Server "training.lug-ag.de"
        Write-Host "$Group wurde SG_Remotezugriff hinzugefügt"
}



### Prüfung ob Benutzer Syncronisiert wurde

$UPN = $CUVorname + "." + $CUNachname + "@training.lug-ag.de"

Write-Host "Warten auf Office 365 Sync..."
do {
      Sleep 60
      $a = Get-MsolUser -UserPrincipalName $UPN -ErrorAction SilentlyContinue
      if($null -ne $a) {
            $opruef = "schuppi"
      }
      [int]$Zahl = $Zahl + 1
      Write-Host "Wartezeit: $Zahl Minuten"
      }while ($null -eq $a -or $Zahl -gt 40)


if($opruef -eq "schuppi"){
### Team erstellen und Member hinzufügen

    $teampruef = get-team | where DisplayName -eq $Group
    If($null -eq $teampruef){
    New-Team -DisplayName $Group -Description $Group -Visibility Private -Owner admin@lug-ag.de
    write-host "Team $Group wurde erstellt"
    Start-Sleep -Seconds 20
    }
    

    $membis = Get-ADGroupMember -Identity $Group -Server training.lug-ag.de
    $trainis = Get-ADGroupMember -Identity $trainers -Server training.lug-ag.de

        foreach($membi in $membis){

        $membiupn = $membi.samaccountname +'@training.lug-ag.de'
        get-team | Where-Object DisplayName -eq $Group | Add-TeamUser -User $membiupn

        }

        foreach($traini in $trainis){

        $trainiupn = $traini.samaccountname +'@training.lug-ag.de'
        get-team | Where-Object DisplayName -eq $Group | Add-TeamUser -User $trainiupn

        }

### Benutzer O365 Lizenzen zuweisen

    if($O365tn -eq "n" -and $ONDESOuser -eq "n"){

        foreach($membii in $membis){

        $membiiUPN = $membii.samaccountname + "@training.lug-ag.de"
        Set-MsolUser -UserPrincipalName $membiiUPN -UsageLocation DE
        Set-MsolUserLicense -UserPrincipalName $membiiUPN -AddLicenses "reseller-account:O365_BUSINESS_ESSENTIALS"

        }


    }

    if($O365tn -eq "y" -and $ONDESOuser -eq "n"){

        foreach($membii in $membis){

        $membiiUPN = $membii.samaccountname + "@training.lug-ag.de"
        Set-MsolUser -UserPrincipalName $membiiUPN -UsageLocation DE
        Set-MsolUserLicense -UserPrincipalName $membiiUPN -AddLicenses "reseller-account:O365_BUSINESS_PREMIUM"


        }
    

    }

    if($O365tn -eq "n" -and $ONDESOuser -eq "y"){

        foreach($membii in $membis){

        $membiiUPN = $membii.samaccountname + "@training.lug-ag.de"
        Set-MsolUser -UserPrincipalName $membiiUPN -UsageLocation DE
        Set-MsolUserLicense -UserPrincipalName $membiiUPN -AddLicenses "reseller-account:TEAMS_EXPLORATORY"


        }
    

    }


}
$pw = $null
$pwgen = $null

Write-Host "Fertig!"



# SIG # Begin signature block
# MIIUCgYJKoZIhvcNAQcCoIIT+zCCE/cCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUk1plcR8pd5oaKCVrJ9NSzdld
# WoOgghFMMIIIXjCCBkagAwIBAgITSQAAAeYOeNFVKwnfZwABAAAB5jANBgkqhkiG
# 9w0BAQsFADBvMRIwEAYKCZImiZPyLGQBGRYCZGUxFjAUBgoJkiaJk/IsZAEZFgZs
# dWctYWcxFTATBgoJkiaJk/IsZAEZFgVjbG91ZDEqMCgGA1UEAxMhTHV0eiB1bmQg
# R3J1YiBBRyBDbG91ZCBJc3N1aW5nIENBMB4XDTE5MDQwNTA3MzIwN1oXDTIxMDQw
# NTA3NDIwN1owgYoxEjAQBgoJkiaJk/IsZAEZFgJkZTEWMBQGCgmSJomT8ixkARkW
# Bmx1Zy1hZzEVMBMGCgmSJomT8ixkARkWBWNsb3VkMQ4wDAYDVQQLEwVDTE9VRDER
# MA8GA1UECxMIQWNjb3VudHMxDzANBgNVBAsTBkFkbWluczERMA8GA1UEAxMIYWRt
# aW4gcncwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDTiVHxoEdPuWpM
# dWwpWnhVAH+0xMRzrdFSk7LDnlwswGV9uDnOgLCGy6m2tVaCjHXA4v08bGoifOrh
# nUhOgNZ1ZIT3LiTK6uVsj3x5UUKmZuF6BVlA4BtXvElt4UIZaMu1c3zzw/LxofST
# xn78iRDwyusKRFoNnscU5GxcNlJqv1/G08pklokSp9QB7XtkGMnKL5sNj0jyYXav
# NzZyv2f/t06y2r9jYoUt41y1qPBRXre1/J3NqI2xv3L7Dqhoo1z4pE17c4u/AAGO
# XvyxU2YNx0SGaAxfK0QIbYohVNw7LL7HfZG9i5YBImWvh4D38xy0ATfSdvA3OYVP
# f8ecrvEFAgMBAAGjggPVMIID0TA8BgkrBgEEAYI3FQcELzAtBiUrBgEEAYI3FQiE
# uuBnhPbzBIWdhTzU0gWF7+8xWoHi90iC/4ZQAgFkAgEKMBMGA1UdJQQMMAoGCCsG
# AQUFBwMDMA4GA1UdDwEB/wQEAwIHgDAbBgkrBgEEAYI3FQoEDjAMMAoGCCsGAQUF
# BwMDMB0GA1UdDgQWBBQKrK+VWYpWi4OjyvfHZr+w9j73TjAfBgNVHSMEGDAWgBR7
# TtzNniUkOTzdnPLHMd3Dsi9v/TCCAVAGA1UdHwSCAUcwggFDMIIBP6CCATugggE3
# hoHgbGRhcDovLy9DTj1MdXR6JTIwdW5kJTIwR3J1YiUyMEFHJTIwQ2xvdWQlMjBJ
# c3N1aW5nJTIwQ0EsQ049Q0EtSXNzdWluZzAxLENOPUNEUCxDTj1QdWJsaWMlMjBL
# ZXklMjBTZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWNs
# b3VkLERDPWx1Zy1hZyxEQz1kZT9jZXJ0aWZpY2F0ZVJldm9jYXRpb25MaXN0P2Jh
# c2U/b2JqZWN0Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnSGUmh0dHA6Ly9jbG91
# ZGlzc3VpbmdjYS9DZXJ0RW5yb2xsL0x1dHolMjB1bmQlMjBHcnViJTIwQUclMjBD
# bG91ZCUyMElzc3VpbmclMjBDQS5jcmwwggGEBggrBgEFBQcBAQSCAXYwggFyMIHT
# BggrBgEFBQcwAoaBxmxkYXA6Ly8vQ049THV0eiUyMHVuZCUyMEdydWIlMjBBRyUy
# MENsb3VkJTIwSXNzdWluZyUyMENBLENOPUFJQSxDTj1QdWJsaWMlMjBLZXklMjBT
# ZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWNsb3VkLERD
# PWx1Zy1hZyxEQz1kZT9jQUNlcnRpZmljYXRlP2Jhc2U/b2JqZWN0Q2xhc3M9Y2Vy
# dGlmaWNhdGlvbkF1dGhvcml0eTByBggrBgEFBQcwAoZmaHR0cDovL2NybC5sdWct
# YWcuZGUvQ0EtSXNzdWluZzAxLmNsb3VkLmx1Zy1hZy5kZV9MdXR6JTIwdW5kJTIw
# R3J1YiUyMEFHJTIwQ2xvdWQlMjBJc3N1aW5nJTIwQ0EoMSkuY3J0MCYGCCsGAQUF
# BzABhhpodHRwOi8vb2NzcC5sdWctYWcuZGUvb2NzcDAzBgNVHREELDAqoCgGCisG
# AQQBgjcUAgOgGgwYYWRtaW5fcndAY2xvdWQubHVnLWFnLmRlMA0GCSqGSIb3DQEB
# CwUAA4ICAQCDFMoHhoxpchVptpn+vDHQUuCmmBgnY1lsN1VA5zsBsW2TR0+EOYUU
# JaPQhXNvK/2BF/WhGx+QBkX38Ll9vNnQRQPwsef/JStnKkpzS18B0I8fcCqjDuDh
# PIvE3zHIa5IHmuw60QoHZHjyFPerPd17tCG4YQv7o6msL3R0Ql2qOACPYNGSf1nv
# M27v/SVYlDLsIDPVD1Wq95ZMzq/96SmX/7ZYH+6Ie0+zbAjuIVAZ4cM+ak+k+PsS
# viT8V6vZKxZE8UYfm5g+Ro2iu/3AoplYw3sQNW7pQDynwpFOhHoV8/NI03+MVsTF
# ZAIwWsSDxxkHNpH5DzZX4kYCgjhcItVtM75aU+n2PtbqaRXPLnsgcd4g9TkMQKmZ
# h5ZbOTsa1J5mtHcOO3uZxFpoxikplkJG4NX4ePWRLzAua0JMHmhf6Cw2BIldDQr5
# 1SolW8YivC0fs5n2cTCDysfyUO5zQHhNN4KKGWcihFfylTspn8WQ+jwTE4Mjsarn
# G44fZZizvJjxl0lar/0yTh0Ej0mKnW7h3l+W1heDu9IoIOTctY+AtHQwjQGKwVcW
# LSOskv/Dsrb5ucriTJlD0Atc2ABwcrvisH8LBIHB/Q0bBENipzy3kyNAq5OpzBRR
# 9SeN3xXiuXTr42r20q/QTVvS1fEBfmwZfxqRw8SZqJrPdQgb5PjS3jCCCOYwggbO
# oAMCAQICEx4AAAAGu1+9Zll8jUwAAQAAAAYwDQYJKoZIhvcNAQELBQAwbDESMBAG
# CgmSJomT8ixkARkWAmRlMRYwFAYKCZImiZPyLGQBGRYGbHVnLWFnMRUwEwYKCZIm
# iZPyLGQBGRYFY2xvdWQxJzAlBgNVBAMTHkx1dHogdW5kIEdydWIgQUcgQ2xvdWQg
# Um9vdCBDQTAeFw0xNjA5MTYxMTAzMjRaFw0yNjA5MTYxMTEzMjRaMG8xEjAQBgoJ
# kiaJk/IsZAEZFgJkZTEWMBQGCgmSJomT8ixkARkWBmx1Zy1hZzEVMBMGCgmSJomT
# 8ixkARkWBWNsb3VkMSowKAYDVQQDEyFMdXR6IHVuZCBHcnViIEFHIENsb3VkIElz
# c3VpbmcgQ0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC6ebiein8B
# +O2SS5kVCQijjlYGt36SVtLXgLJU3GA8f1v2xl3xT1P4gmpreQn7H13p9mw7W2wm
# wXLQklwD5iNvdVSpJuOXRuvMbwpFS8E/wfUHdE3VMWtTMItdGjJSxtTuVHFBg23a
# uaUPsJLvBaM+F0bo1hkcFjACCGdTyxAocTmEhzJQBeFfMUufpi1/4oHoYsgWZYLE
# DXdGF3TEcNb1HkbXOwODnV7ta3FDIwyZwPXwM8QdYvqa2G+XIaiAERLvKe47VB6Y
# hb0y9crlAgHhBe+RB8j9TnYOgApTGxsioOrj2EDTQkJbLfJNrxhahP7zuB+4VJjC
# hmicm6TCAVelRck3PSXCXD7GR0ZVP/uQb5m6DSCE80OdtwUXWCQ61c5QVtpf1i2g
# aleQVxbyJw6V8X3f4A74nmPZmwu2WCGAkMJIHfEWaneBD8K4cZ0FFRpIcquu9RxD
# o/1gxW8R6vPgUlFAV+2k8f2NSZWV9ZAer57bhlB+naCP1Kt/T3NV29ppfFpRZrmI
# Bm0Ubx71otvtDlUKCnT0MLlueug7su2UCTvng/7XjMBAJhNbmi0pywWraRrKYVv/
# yeSFAQWagds7gPZkaJw4U7/3hf1NXc9UcPoz9OqedgSqM/cArrP/hkFssR+ZO0vc
# 7mWxQoxS2pYa/NlbvIw7042LLqpbT9fj2QIDAQABo4IDfDCCA3gwEAYJKwYBBAGC
# NxUBBAMCAQEwIwYJKwYBBAGCNxUCBBYEFBhdPmPW9oRnme1mq+gmHpUroNDuMB0G
# A1UdDgQWBBR7TtzNniUkOTzdnPLHMd3Dsi9v/TAZBgkrBgEEAYI3FAIEDB4KAFMA
# dQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAW
# gBTwcm4LthNw1Tn1Ihpvd2klLv/HSzCCAUMGA1UdHwSCATowggE2MIIBMqCCAS6g
# ggEqhoHfbGRhcDovLy9DTj1MdXR6JTIwdW5kJTIwR3J1YiUyMEFHJTIwQ2xvdWQl
# MjBSb290JTIwQ0EoMSksQ049Q2xvdWRSb290Q0EsQ049Q0RQLENOPVB1YmxpYyUy
# MEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9
# Y2xvdWQsREM9bHVnLWFnLERDPWRlP2NlcnRpZmljYXRlUmV2b2NhdGlvbkxpc3Q/
# YmFzZT9vYmplY3RDbGFzcz1jUkxEaXN0cmlidXRpb25Qb2ludIZGaHR0cDovL2Ny
# bC5sdWctYWcuZGUvTHV0eiUyMHVuZCUyMEdydWIlMjBBRyUyMENsb3VkJTIwUm9v
# dCUyMENBKDEpLmNybDCCAX0GCCsGAQUFBwEBBIIBbzCCAWswgdAGCCsGAQUFBzAC
# hoHDbGRhcDovLy9DTj1MdXR6JTIwdW5kJTIwR3J1YiUyMEFHJTIwQ2xvdWQlMjBS
# b290JTIwQ0EsQ049QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNl
# cnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9Y2xvdWQsREM9bHVnLWFnLERDPWRl
# P2NBQ2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0aW9uQXV0
# aG9yaXR5MG4GCCsGAQUFBzAChmJodHRwOi8vY3JsLmx1Zy1hZy5kZS9DbG91ZFJv
# b3RDQS5jbG91ZC5sdWctYWcuZGVfTHV0eiUyMHVuZCUyMEdydWIlMjBBRyUyMENs
# b3VkJTIwUm9vdCUyMENBKDEpLmNydDAmBggrBgEFBQcwAYYaaHR0cDovL29jc3Au
# bHVnLWFnLmRlL29jc3AwDQYJKoZIhvcNAQELBQADggIBADueQUzd0ac8alCin1Wi
# AVh57tItPT+Oh3Fg5H4WGlPGz4GAQ6AwVhzxpNppJdnX2rBkdnrNAk2hLUcnHA9w
# SSiX8p9uqNM3z6hSlzXLw7svziiO3uiPNaxB9wolNS4UEsd6AMjW3nuYnpAnb05H
# 0a7KXQxhf77OJ3K/07HA6iI65y68zw8VDqygqs5Egq9YnjXs7lClo5Bh3ovjomj6
# tbii2oBy51zeGPRXoPnU7MDfMRBT4rN6qIj5M2SkWL0YN2PW6u50Kj8qzbGkCGTZ
# dlBW3MUUdKGPqsXyWPWgZvzqBbROjJ2OVOfEhE4v71f+sqAui8IwjNGkpD6peUTb
# 7Zh4pao3GtLyiY/7K8eOsMzUicpUVrJLgpCp861XPI9T9W/tyhZUTsvBrhG25Ota
# YKo3hqti+ftYFOFvyFvWDSbGCdQutqZY5BdDA2i+GJj63KDAwpzQsmsgvluqwXF/
# D8m8jJZG4qpyrh9SoacpANBg/7er1KzJGSbKcKiqGExg5Z3eBBkeVGmjBnx+t7ZS
# c2ovdhSuizUhNNUX+JB4kwq7bNnvaWNyPYZTPvWM+QVMvo4aheJpY03frzGCyHj3
# SWgilMAcxEs9qMNBj1/VoN852Ci8N27nxUZALfJziR7zKgH4N3II5uItHwLQUVk8
# H8BsjjzYbShWIaVLmui+Sh88MYICKDCCAiQCAQEwgYYwbzESMBAGCgmSJomT8ixk
# ARkWAmRlMRYwFAYKCZImiZPyLGQBGRYGbHVnLWFnMRUwEwYKCZImiZPyLGQBGRYF
# Y2xvdWQxKjAoBgNVBAMTIUx1dHogdW5kIEdydWIgQUcgQ2xvdWQgSXNzdWluZyBD
# QQITSQAAAeYOeNFVKwnfZwABAAAB5jAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIB
# DDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEE
# AYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUo1VmP45iL97U
# QEw2d2HuZXmnUsswDQYJKoZIhvcNAQEBBQAEggEACLO2KwFhFGQd+dOPLWsv+PTf
# L4/PTLpnCN+b7DJyVVstCHtepUFAs8MPQNKbpJ4m3lb/O1kOVHicLYZlDacBB4W6
# nZn7VJpTjSlvlMflkb2H4Dn2prdEihYJRAXgqnHkakxoz0sUR2RBYabC9dxS23uJ
# JGSFlp0Dpm9wTQfbVO2QfzP/o1PVdYua/t+rqrb04hjV/qohUqO0nrU8mXGMYVtR
# LpBsmpldxXEDPJbPcAIubzCalebDVOdHWY5oQwubNynpAdEtU6oQch6O1K2VGwIN
# oCwjWDjv/HAJrcn1lgbo4fbXo/DxUW1DM4CkVxQI5gc8tvLzvQrJYjOYhD2vKg==
# SIG # End signature block
