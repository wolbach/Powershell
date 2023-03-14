## v 1.0 Manuel Boll
## v 1.2 Filehashen
## v 1.3 Filehash Wert überprüfen
## v 1.4 Homelaufwerk
## v 1.5 Gruppen angepasst LG-Ankündigungen Lizenzen verteilt
## v 1.6 Office 365 sync Timer eingebaut
## v 1.7 Debugging 
## v 1.8 Rastatt und Woerth
## v 1.9 Debugging
## v 1.9.1 Experation und disabled option
## v 2.0 Aufwandserfassung
## v 2.1 RW Hashprüfung entfernt, als admin starten entfernt,
## V 2.2 RW Lieferantenmgm. hinzugefügt. Gruppenvorlagen angepasst, Lizenzsierung O365 angepasst.
    
    <#
    ToDo

    Anpassung der zugewiesenen Gruppenmitgliedschaften
    Anredegedöhns anders machen
    Lizenzname überprüfen
    Exchange Online Stuff
    evtl auslagerung in Funktionen
    #>
  
 ### Variablen

 try {
    Get-MsolDomain -ErrorAction Stop > $null
}
catch {
    Connect-MsolService
    Connect-MicrosoftTeams
}

 $user = $null
 $Vorname = $null
 $Nachname = $null
 $richtig = $null
 $Benutzername = $null
 $ou = $null
 $groups = @()
 $group = $null
 $user = $null
 $groups = $null
 $abteilung = $null
 $dis = $null
 $OU = 'OU=LutzundGrub,OU=Benutzer,DC=lg,DC=local,DC=de'
 $driveletter = "Z:"
 $acl = $null
 $fileSystemRights = [System.Security.AccessControl.FileSystemRights]"Modify"
 $accesscontrolType = [System.Security.AccessControl.AccessControlType]::Allow
 $inhertanceFlags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
 $propagationflags = [System.Security.AccessControl.PropagationFlags]"None"
 $homeshare = $null
 $accessrule = $null
 $user = $null
 $LO = $null
 $aktiv = $null
 $anrede = $null
 $daimler = $null
 $insertquery2 = $null
 $groups = @()
 
 
 
 ### Abfragen
 
 do{
     Write-Host "Office365 Admin eingeben"
     #$credential = Get-Credential -Message "Office365 Admin eingeben"
     $Vorname = Read-Host -Prompt "Geben Sie den Vornamen ein"
     $Nachname = Read-Host -Prompt "Geben Sie den Nachnamen ein"
     $beschreibung = Read-Host -Prompt "Geben Sie eine Beschreibung ein"
     
     $aktiv = Read-Host -Prompt "Soll Account aktiv sein? y/n"
    
    $Nachname = $Nachname.replace("ü","ue")
    $Nachname = $Nachname.replace("Ü","Ue")
    $Nachname = $Nachname.replace("ö","oe")
    $Nachname = $Nachname.replace("Ö","Oe")
    $Nachname = $Nachname.replace("ä","ae")
    $Nachname = $Nachname.replace("Ä","Ae")
    $Nachname = $Nachname.replace("ß","ss")
    $Nachname = $Nachname.replace("é","e")
    $Nachname = $Nachname.replace(" ","-")

    $Vorname = $Vorname.replace("ü","ue")
    $Vorname = $Vorname.replace("Ü","Ue")
    $Vorname = $Vorname.replace("ö","oe")
    $Vorname = $Vorname.replace("Ö","Oe")
    $Vorname = $Vorname.replace("ä","ae")
    $Vorname = $Vorname.replace("Ä","Ae")
    $Vorname = $Vorname.replace("ß","ss")
    $Vorname = $Vorname.replace("é","e")
    $Vorname = $Vorname.replace(" ","-")

     $beschreibung = $beschreibung.Replace("ä", "ae")
     $beschreibung = $beschreibung.Replace("ö", "oe")
     $beschreibung = $beschreibung.Replace("ü", "ue")
     $beschreibung = $beschreibung.Replace("ß", "ss")
     
  
 
     while( $daimler -ne "0" -and $daimler -ne "1"){
  
 
     $daimler = Read-Host -Prompt " Daimler support? (y/n)"
 
         switch($daimler){
             1 {Write-Host "Daimler Support: JA"}
             0 {Write-Host "Daimler Support: Nein" }
         }
     }

     $Vorname
     $Nachname
     $beschreibung
 
     $Benutzername = ($Vorname.Substring(0,1) + $Nachname).ToLower() 
     $dis = $Vorname + " " + $Nachname
     $upn = $Benutzername+"@lutzundgrub.de"
     
     $fullPath = "\\LGKA-AWFS003\Homelaufwerke\$Benutzername"
     Write-Host $Benutzername
     
     $richtig = read-host -Prompt "Sind die Eingaben Richtig (y/n)"
 
 
  
 
 }while ($richtig -eq "n")
 
 while( $null -eq $abteilung ){
 
     write-host "1 = Schuelerpraktikant / Externer Benutzer"
     write-host "2 = normaler Mitarbeiter / Praktikanten / Daimler"
     write-host "3 = Coach"
     write-host "4 = Trainer"
     write-host "5 = IT"
     write-host "6 = Verwaltung"
     write-host "7 = Personalmanagement"
     write-host "8 = Hotline"
     Write-host "9 = Buchhaltung"
     Write-host "10 = Vertrieb"
 
 
 
     $abteilung = Read-Host -Prompt "Wählen Sie eine Kategorie aus:(1,2,3,4,5,6,7,8,9,10)"
 
         switch($abteilung){
             1 {$groups = @("Domänen-Gäste", "SZ_Verbot Webserver")}
             2 {$groups = @("00 Basis", "MA-LG", "SZ_Office365_Sync_User", "SZ_Verbot Webserver")}
             3 {$groups = @("00 Basis", "01 SGB III.Coaching","SZ_Office365_Sync_User","MA-LG", "SZ_Verbot Webserver", "01 SGB III","SZ_DKB_Coachs","SZ_DKB_Trainer" )}
             4 {$groups = @("00 Basis", "MA-LG", "SZ_Office365_Sync_User","01 SGB III","Trainer-11777267489","SZ_Verbot Webserver","SZ_DKB_Trainer")}
             5 {$groups = @("00 Basis", "01 SGB III","SZ_Office365_Sync_User","MA-LG","07 Interne Technik","SZ_Verbot Webserver", "03 Verwaltung.03-05 Eingangsrechnungen" )}
             6 {$groups = @("00 Basis", "01 SGB III","SZ_Office365_Sync_User","MA-LG","SZ_Verbot Webserver", "03 Verwaltung","SZ_DKB_Verwaltung" )}
             7 {$groups = @("00 Basis", "01 SGB III","SZ_Office365_Sync_User","MA-LG", "03 Verwaltung.03-24 Datenbank", "04 Marketing-Vertieb", "05 Personal" )}
             8 {$groups = @("00 Basis", "MA-LG", "SZ_Office365_Sync_User", "SZ_Verbot Webserver", "10 Remote IT Services")}
             9 {$groups = @("00 Basis", "01 SGB III","SZ_Office365_Sync_User","MA-LG","SZ_Verbot Webserver", "03 Verwaltung", "06 Finanzen-Buchhaltung.Buchhaltung", "02 Firmenkunden" )}
            10 {$groups = @("00 Basis", "MA-LG", "SZ_Office365_Sync_User", "SZ_Verbot Webserver", "10 Remote IT Services", "02 Firmenkunden", "04 Marketing-Vertieb")}
     }
 }
 
 ####### Lieferantenmanagement
 
 if($abteilung -eq "5" -or $abteilung -eq "6" -or $abteilung -eq "9" -or $abteilung -eq "10" ){
 
 $insertquery2="
 
 
 BEGIN
     DECLARE @PersonenID int
     DECLARE @MitarbeiterID int
 
  
 
     SELECT @PersonenID = max(PersonenID) FROM [LGCRM].[dbo].Personen WHERE Name='$Nachname' and Vorname='$Vorname'
 
  
 
     SELECT @MitarbeiterID = MitarbeiterID FROM [LGCRM].[dbo].Mitarbeiter WHERE PersonenID=@PersonenID and FirmenID=5586
 
  
 
     SET IDENTITY_INSERT [LGLieferant].[dbo].[Personen] ON
     INSERT INTO [LGLieferant].[dbo].[Personen] ([PersonenID],[Name],[Vorname],[AnredeID])
     VALUES (@PersonenID,'$Nachname','$Vorname','$anrede')
     SET IDENTITY_INSERT [LGLieferant].[dbo].[Personen] OFF
 
  
 
     SET IDENTITY_INSERT [LGLieferant].[dbo].[Mitarbeiter] ON
     INSERT INTO [LGLieferant].[dbo].[Mitarbeiter] ([MitarbeiterID],[PersonenID],[FirmenID],[Trainer],[Verfuegbarkeit],[PreisLeistung],[Qualitaet],[Service],[Trainingsbereich],[Consultant])
     VALUES (@MitarbeiterID,@PersonenID,5586,0,0,0,0,0,0,0)
     SET IDENTITY_INSERT [LGLieferant].[dbo].[Mitarbeiter] OFF
 
  
 
     INSERT INTO [LGLieferant].[dbo].[Einstellung] ([MitarbeiterID],[Anmeldename],[EinstellungenAendern],[LGStandortID],[LGBereichID],[Inaktiv])
     VALUES (@MitarbeiterID,'$Benutzername',0,1,3,0)
 END
 "
 
 Invoke-Sqlcmd -ServerInstance lgka-sql010 -Database LGCRM -DisableVariables -Query $insertquery2
 
 }
      
      
 ### Anweisungen
 
 $ou = 'OU=Benutzer,OU=LutzundGrub,DC=lg,DC=local'
 New-ADUser -HomeDrive $driveletter -HomeDirectory $fullPath -ChangePasswordAtLogon $false -PasswordNeverExpires $true -Name $dis -DisplayName $dis -Path $ou -SamAccountName $Benutzername -GivenName $Vorname -Surname $Nachname  –AccountPassword (ConvertTo-Securestring “P@ssword” –asplaintext –Force) -Enabled $true -UserPrincipalName ($Benutzername + "@lutzundgrub.de") 
 $homeshare = New-Item -Path $fullPath -ItemType Directory -Force
 $acl = Get-Acl $homeshare
 $user = Get-ADUser -Identity $Benutzername
 $accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule ($user.SID, $fileSystemRights, $inhertanceFlags, $propagationflags, $accesscontrolType)
 $acl.AddAccessRule($accessrule)
 Set-Acl -Path $homeshare -AclObject $acl
 
 Sleep 5
 
 ### Gruppen hinzufügen
 
 foreach($group in $groups){
 Add-adgroupmember -Identity $Group $Benutzername
 }
 
 Write-Host "Der Benutzer ist Mitglied in Gruppe: 
 $groups
 "
 
 $weitere = read-host -Prompt "Sollen weitere Gruppen hinzugefuegt werden J/N"
 
 
 while ($weitere -eq "j"){
   
   while ($weitere -eq "J" -or $weitere -eq "j") {
       $g = read-host -Prompt "Gruppennamen eingeben"
       $ErrorActionpreference = "silentlycontinue"
       try {
       Add-adgroupmember -Identity $g $Benutzername
        } catch {
         write-host "Gruppe existiert nicht"
         }
      $weitere = read-host -Prompt "weitere Gruppen hinzugefuegen J/N"
     }
 }
 
 
 
 ###Exchange postfach anlegen
 $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://lgka-ex004/PowerShell/
 Import-PSSession $Session
 Get-User -RecipientTypeDetails User | where name -eq $Benutzername | Enable-Mailbox -Alias $Benutzername
 Remove-PSSession $Session
 ## Hier versuchen die Migration zu automatisieren
 
 ###Office365 LG Ankündigungen, Lutz und Grub, warten auf Sync
 
 Write-Host "warten auf Office 365 Sync in min (Kann bis zu 35min Dauern)"
 
 $ErrorActionPreference = "SilentlyContinue"
 while ($null -eq $a) {
       Sleep 60
       $a = Get-MsolUser -UserPrincipalName "$Benutzername@lutzundgrub.de"
       Write-Host $Zahl
       [int]$Zahl = $Zahl + 1
       }
 
 
 
 ### LG Ankündigungen
 
 sleep 120
 $exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Authentication "Basic" -AllowRedirection
 Import-PSSession $exchangeSession
 Sleep 10
 $ErrorActionPreference = "SilentlyContinue"
 Add-DistributionGroupMember -Identity "LG-Ankündigung" -Member $upn
 Remove-PSSession $exchangeSession
 ## Funktioniert nicht so wie es sollte
 
 ### Lizenzen verwalten
 $LO = New-MsolLicenseOptions -AccountSkuId "lutzundgrub:ENTERPRISEPACK"
 Set-MsolUser -UserPrincipalName $upn -UsageLocation DE
 Set-MsolUserLicense -UserPrincipalName $Benutzername@lutzundgrub.de -AddLicenses "lutzundgrub:SPE_E3" -LicenseOptions $LO
 ## Überprüfen, ob Lizenz AccountSkuID noch richtig ist
 
 
 #### Benutzer ablaufen
<#  if ($null -ne $ablaufdatum) {
 Set-ADAccountExpiration -Identity $Benutzername -DateTime "$ablaufdatum"
 } #>
 
 
 ### Benutzer aktiv
 if ($aktiv -eq "N" -or $aktiv -eq "n" ) {
 Set-ADUser -Identity $Benutzername -Enabled 0
 }

 Get-AdUser -filter "name -eq '$dis'" -Properties AccountExpirationDate
 
 $b = Get-AdUser  -filter "name -eq '$dis'" -Properties MemberOf | Select-Object -ExpandProperty MemberOf
 
 Write-Host "Email: $Benutzername@lutzundgrub.de
 Benutzer ist Mitglied in den Gruppen

 $b

BENUTZER ERSTELLEN ERFOLGREICH!"
## Mit try catch realisieren?
 
 $credential = $null
 "Zum Abschluss Mail Migration nach O365 + ggf. Login für Teilnehmerdatenbank + Sharepoint Gruppe LG-Ankündigung"
 ## Nach Automatisierungslösungen suchen
  