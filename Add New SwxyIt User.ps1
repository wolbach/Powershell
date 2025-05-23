Import-Module IpPbx
Connect-IpPbx -ServerName SWYX-SRV

#TODO FALLS NOTWENDIG
#Rufnummer (ggfs. Faxnummer) per E-Mail senden

<#
CHANGELOGS:
17.01.2024 - Anpassung des Skinnamens für Abteilung DRE VU
#>

#Übergabe variablen von jenkins
#$kürzel = $env:Token
#$kürzel = $kürzel.ToUpper()
#$vorname = $env:Vorname
#$nachname = $env:Nachname
#$abteilung = $env:Abteilung


#Neuer Benutzer: Name = <Kürzel>, Beschreibung = <Abteilung>/<Kürzel> <Vollständiger Name>
$kürzel = "T_SU"
$kürzel = $kürzel.ToUpper()
$vorname = "Test"
$nachname = "SU"
$abteilung = "SU"
$email = $kürzel + "@in-software.com"
#nur nötig wenn Benutzer bei SU:
#$mobilNr = "+49"

#Plausibilitätsprüfungen
if($abteilung -eq "FH"){
    echo "Skript gestoppt da Mitarbeiter ein Fachhändler ist und SwyxIt nicht notwendig ist"
    exit 10
}


if($abteilung -eq "VA"){
    $beschreibung = "KLR VA/" + $kürzel + " " + $vorname + " " + $nachname
}
if($abteilung -eq "MK"){
    $beschreibung = "KLR MK/" + $kürzel + " " + $vorname + " " + $nachname
}
if($abteilung -eq "KUB"){
    $beschreibung = "KLR CS/" + $kürzel + " " + $vorname + " " + $nachname
}
if($abteilung -eq "KUS"){
    $beschreibung = "KLR CS/" + $kürzel + " " + $vorname + " " + $nachname
}
if($abteilung -eq "DRE.VU"){
    $beschreibung = "DRE VU/" + $kürzel + " " + $vorname + " " + $nachname
}
if($abteilung -eq "SB"){
    $beschreibung = "KLR SB/" + $kürzel + " " + $vorname + " " + $nachname
}
if($abteilung -eq "SU"){
    $beschreibung = "KLR SU/" + $kürzel + " " + $vorname + " " + $nachname
    if (!$mobilNR) {
        $mobilNR = Read-Host "Handynummer (Leerlassen wenn nicht vorhanden)" 
    }
}



#hinterlegt alle notwendigen Abteilungsabhängigen Daten
#Standort hinterlegen: KLR = 1 / POZ = 2 / DRE = 3
#Gruppe auswählen
#Nur bei VA/CS/MA: Benutzer der passenden Gruppe zuordnen: Hotline (logged off), Kundenberatung (Gruppe) (logged off),Verwaltung (Gruppe) (logged off), Marketing

#Chef hinterlegen (für zuhören)

#Bezeichnung für Abteilungsleitung festlegen

#Benutzer in SwyxIt anlegen
#Benutzer der dazugehörigen Gruppe hinzufügen

#nächste interne/öffentliche rufnummer finden - Prozess wird abbgebrochen falls Nummerierung überschritten wird
#Freie interne Rufnummer festlegen
#(VA=115-149, MA=160-199,HOT=210-249, KUB/VdZ=260-299, DRE=310-349, SB FAX = 350-379, SU FAX = 380-399)
#Siehe: G:\KLR\Ablage PM\00098 Büro Karlsbad\Reutäckerstraße 15, Ittersbach\Rufnummern

#Nach R mit DE: NICHT MEHR NOTWENDIG!
#NUR BEI SU/SB/PK: Anzahl freie FaxNummern prüfen (Lizenzierte Faxbenutzer vs Konfigurierte Faxbenutzer)
#Nächste freie interne/externe Faxnummer finden

switch($abteilung){
VA{
    $locationID = 1
    $gruppe = "Verwaltung (Gruppe) (logged off)"
    $chefListe = "DRI", "FHA" ,"DK"
    
    $user = New-IpPbxUser -UserName $kürzel -Comment $beschreibung -EmailAddress $email -LocationId $locationID
    
    #erstellt den neuen Benutzer in IpPbx und fügt den Benutzer der "Jeder" Gruppe hinzu
    Add-IpPbxUser -UserEntry $user -AddToEveryoneGroup

    #fügt den Benutzer der Abteilungsgruppe hinzu
    Add-IpPbxGroupMember -UserEntry $user -GroupName $gruppe


    #Get Internal Number
    $neueInterneRufnummer = Get-IpPbxNextFreeInternalNumber -BeginSearchFromNumber 115
    if($neueInterneRufnummer -gt "149"){
        echo "Maximale Rufnummer für VA erreicht"
        exit 200
    }
    #Add internal number to user
    New-IpPbxInternalNumber -InternalNumber $neueInterneRufnummer | Add-IpPbxInternalNumberToUser -UserEntry $user
    #Add Public number equal to internal number
    $öffentlicheRufnummer = "+4972484500" + $neueInterneRufnummer
    New-IpPbxPublicNumber -PublicNumber $öffentlicheRufnummer | Add-IpPbxPublicNumber -InternalNumber $neueInterneRufnummer

    #interne Abteilungsrufnummer hinterlegen
    $interneAbteilungsRufnummer = Get-IpPbxInternalNumber -InternalNumber "5100"

    #Adds Domain Login to User
    $domainLogin = "IN-KLR\" + $kürzel
    Add-IpPbxUserWindowsAccount -UserEntry $user -NTAccount $domainLogin

    #Setzt Skin für Benutzer
    $userdata = Get-IpPbxUserData -UserName $kürzel
    $userdata.m_szSkinName = "Verwaltung.cab"
    Set-IpPbxUserData -UserName $kürzel -UserData $userdata

    break
}
MK{
    $locationID = 1
    $gruppe = "Marketing"
    $telLeitung = "Marketing"
    
    $neueInterneRufnummer = Get-IpPbxNextFreeInternalNumber -BeginSearchFromNumber 160
    if($neueInterneRufnummer -gt "199"){
        echo "Maximale Rufnummer für MA erreicht"
        exit 200
    }
    $user = New-IpPbxUser -UserName $kürzel -Comment $beschreibung -EmailAddress $email -LocationId $locationID
    
    #erstellt den neuen Benutzer in IpPbx und fügt den Benutzer der "Jeder" Gruppe hinzu
    Add-IpPbxUser -UserEntry $user -AddToEveryoneGroup

    #fügt den Benutzer der Abteilungsgruppe hinzu
    Add-IpPbxGroupMember -UserEntry $user -GroupName $gruppe

    #Add internal number to user
    New-IpPbxInternalNumber -InternalNumber $neueInterneRufnummer | Add-IpPbxInternalNumberToUser -UserEntry $user
    #Add Public number equal to internal number
    $öffentlicheRufnummer = "+4972484500" + $neueInterneRufnummer
    New-IpPbxPublicNumber -PublicNumber $öffentlicheRufnummer | Add-IpPbxPublicNumber -InternalNumber $neueInterneRufnummer
    
    #interne Abteilungsrufnummer hinterlegen
    $interneAbteilungsRufnummer = Get-IpPbxInternalNumber -InternalNumber "150"

    #Adds Domain Login to User
    $domainLogin = "IN-KLR\" + $kürzel
    Add-IpPbxUserWindowsAccount -UserEntry $user -NTAccount $domainLogin

    break
}
KUS{
    $locationID = 1
    $gruppe = "Hotline (logged off)"
    $gruppe2= "Hotline2 (logged off)"
    $chefListe = "STO", "DP"
    $telLeitung = "Hotline"
    
    $neueInterneRufnummer = Get-IpPbxNextFreeInternalNumber -BeginSearchFromNumber 210
    if($neueInterneRufnummer -gt "249"){
        echo "Maximale Rufnummer für KUS erreicht"
        exit 200
    }
    $user = New-IpPbxUser -UserName $kürzel -Comment $beschreibung -EmailAddress $email -LocationId $locationID
    
    #erstellt den neuen Benutzer in IpPbx und fügt den Benutzer der "Jeder" Gruppe hinzu
    Add-IpPbxUser -UserEntry $user -AddToEveryoneGroup

    #change forwarding on no reply to false
    $fwrules = Get-IpPbxUserForwarding -UserEntry $user -ForwardingType NoReply
    $fwrules.IsEnabled = $false
    Set-IpPbxUserForwarding -UserForwardingEntry $fwrules -UserEntry $user

    #fügt den Benutzer der Abteilungsgruppe hinzu
    Add-IpPbxGroupMember -UserEntry $user -GroupName $gruppe
    Add-IpPbxGroupMember -UserEntry $user -GroupName $gruppe2
    
    #Add internal number to user
    $neueNummer = New-IpPbxInternalNumber -InternalNumber $neueInterneRufnummer
    Add-IpPbxInternalNumberToUser -InternalNumberEntry $neueNummer -UserEntry $user
    #Add Public number equal to internal number
    $öffentlicheRufnummer = "+4972484500" + $neueInterneRufnummer
    $publicnummer = New-IpPbxPublicNumber -PublicNumber $öffentlicheRufnummer
    Add-IpPbxPublicNumber -PublicNumberEntry $publicnummer -InternalNumber $neueInterneRufnummer

    #interne Abteilungsrufnummer hinterlegen
    $interneAbteilungsRufnummer = Get-IpPbxInternalNumber -InternalNumber "5200"

    #Adds Domain Login to User
    $domainLogin = "IN-KLR\" + $kürzel
    Add-IpPbxUserWindowsAccount -UserEntry $user -NTAccount $domainLogin

    #Setzt Skin für Benutzer
    $userdata = Get-IpPbxUserData -UserName $kürzel
    $userdata.m_szSkinName = "3iMedia Call Queue 2020 (right, bottom slim).cab"
    Set-IpPbxUserData -UserName $kürzel -UserData $userdata

    break
}
KUB{
    $locationID = 1
    $gruppe = "Kundenberatung (Gruppe) (logged off)"
    $chefListe = "TP"
    $telLeitung = "Kundenberatung"

    $neueInterneRufnummer = Get-IpPbxNextFreeInternalNumber -BeginSearchFromNumber 256
    if($neueInterneRufnummer -gt "299"){
        echo "Maximale Rufnummer für KUB erreicht"
        exit 200
    }
    $user = New-IpPbxUser -UserName $kürzel -Comment $beschreibung -EmailAddress $email -LocationId $locationID
    
    #erstellt den neuen Benutzer in IpPbx und fügt den Benutzer der "Jeder" Gruppe hinzu
    Add-IpPbxUser -UserEntry $user -AddToEveryoneGroup

    #fügt den Benutzer der Abteilungsgruppe hinzu
    Add-IpPbxGroupMember -UserEntry $user -GroupName $gruppe

    #Add internal number to user
    New-IpPbxInternalNumber -InternalNumber $neueInterneRufnummer | Add-IpPbxInternalNumberToUser -UserEntry $user
    #Add Public number equal to internal number
    $öffentlicheRufnummer = "+4972484500" + $neueInterneRufnummer
    New-IpPbxPublicNumber -PublicNumber $öffentlicheRufnummer | Add-IpPbxPublicNumber -InternalNumber $neueInterneRufnummer
    
    #interne Abteilungsrufnummer hinterlegen
    $interneAbteilungsRufnummer = Get-IpPbxInternalNumber -InternalNumber "5222"

    #Adds Domain Login to User
    #$domainLogin = "IN-KLR\" + $kürzel
    $domainLogin = $kürzel + "@in-klr.com"
    Add-IpPbxUserWindowsAccount -UserEntry $user -NTAccount $domainLogin

    #Setzt Skin für Benutzer
    $userdata = Get-IpPbxUserData -UserName $kürzel
    $userdata.m_szSkinName = "Kundenberatung.cab"
    Set-IpPbxUserData -UserName $kürzel -UserData $userdata

    break
}
DRE.VU{
    #AUFZEICHNUNG AKTIVIEREN

    $locationID = 3
    #Keine öffentliche/interne Rufnummer
    $chefListe = "RFW", "YF", "DRI", "TP"

    $telLeitung = "DRE.VU"

    $neueInterneRufnummer = Get-IpPbxNextFreeInternalNumber -BeginSearchFromNumber 310
    if($neueInterneRufnummer -gt "349"){
        echo "Maximale Rufnummer für DRE VU erreicht"
        exit 200
    }

    $user = New-IpPbxUser -UserName $kürzel -Comment $beschreibung -EmailAddress $email -LocationId $locationID
    
    #erstellt den neuen Benutzer in IpPbx und fügt den Benutzer der "Jeder" Gruppe hinzu
    Add-IpPbxUser -UserEntry $user -AddToEveryoneGroup

    #Add internal number to user
    New-IpPbxInternalNumber -InternalNumber $neueInterneRufnummer | Add-IpPbxInternalNumberToUser -UserEntry $user

    #interne Abteilungsrufnummer als alternative Nummer hinterlegen
    $interneAbteilungsRufnummer = Get-IpPbxInternalNumber -InternalNumber "302"

    #Adds Domain Login to User
    $domainLogin = "IN-KLR\" + $kürzel
    Add-IpPbxUserWindowsAccount -UserEntry $user -NTAccount $domainLogin

    #konfiguriert aufzeichnungen
    $userdata = Get-IpPbxUserData -UserName $kürzel
    # Nach Rückmeldung FHA/TP nicht mehr nötig:
    <# $userdata.m_bRecordingEnabled = 1
    $userdata.m_bRecordAllCalls = 1
    $userdata.m_bStoreCallbackToSeparateFile = 1
    $userdata.m_szRecordedCallsFolder = ("\\NAS-DRE\DRE\" + $kürzel) #>
    
    #Setzt Skin für Benutzer
    $userdata.m_szSkinName = "DRE.VU.CallDuration.cab"
    
    Set-IpPbxUserData -UserName $kürzel -UserData $userdata

    break
}
SB{
    $locationID = 1
    $gruppe = "KLR SB"
#KEINE ABTEILUNGSRUFNUMMER
#KEINE INTERNE RUFNUMMER

    $user = New-IpPbxUser -UserName $kürzel -Comment $beschreibung -EmailAddress $email -LocationId $locationID
    
    #erstellt den neuen Benutzer in IpPbx und fügt den Benutzer der "Jeder" Gruppe hinzu
    Add-IpPbxUser -UserEntry $user -AddToEveryoneGroup

    #fügt den Benutzer der Abteilungsgruppe hinzu
    Add-IpPbxGroupMember -UserEntry $user -GroupName $gruppe
    
#Nur bei SU/SB: Sofortige Rufumleitung auf Handynummer <Handy Nummer> einrichten
    $sofortigeUmleitung = Get-IpPbxUserForwarding -UserName $kürzel -ForwardingType Unconditional
    $sofortigeUmleitung.IsEnabled = $true
    $sofortigeUmleitung.Destination = [UserForwardingDestination]::Number
    $sofortigeUmleitung.Number = $mobilNR
    Set-IpPbxUserForwarding -UserForwardingEntry $sofortigeUmleitung

    #creates new Phonebook Entry
    $telefonbucheintrag = New-IpPbxPhonebookEntry -Name ($Kürzel + " (Handy)") -Number $mobilNr -Description $beschreibung -GlobalPhoneBook
    Add-IpPbxPhoneBookEntry -PhoneBookEntry $telefonbucheintrag 
    
    break
}
SU{
    $locationID = 1
    $gruppe = "SU-AD"
    $chefListe = "MG"
     $telLeitung = "Hotline"

    $neueInterneRufnummer = Get-IpPbxNextFreeInternalNumber -BeginSearchFromNumber 380
    if($neueInterneRufnummer -gt "399"){
        echo "Maximale Rufnummer für SU erreicht"
        exit 200
    }

    $user = New-IpPbxUser -UserName $kürzel -Comment $beschreibung -EmailAddress $email -LocationId $locationID
    
    #erstellt den neuen Benutzer in IpPbx und fügt den Benutzer der "Jeder" Gruppe hinzu
    Add-IpPbxUser -UserEntry $user -AddToEveryoneGroup

    #fügt den Benutzer der Abteilungsgruppe hinzu
    Add-IpPbxGroupMember -UserEntry $user -GroupName $gruppe

    #Add internal number to user
    New-IpPbxInternalNumber -InternalNumber $neueInterneRufnummer | Add-IpPbxInternalNumberToUser -UserEntry $user
    #Add Public number equal to internal number
    $öffentlicheRufnummer = "+4972484500" + $neueInterneRufnummer
    New-IpPbxPublicNumber -PublicNumber $öffentlicheRufnummer | Add-IpPbxPublicNumber -InternalNumber $neueInterneRufnummer

    #Adds Domain Login to User
    $domainLogin = "IN-KLR\" + $kürzel
    Add-IpPbxUserWindowsAccount -UserEntry $user -NTAccount $domainLogin

    $interneAbteilungsRufnummer = Get-IpPbxInternalNumber -InternalNumber "5200"

#Nur bei SU/SB: Sofortige Rufumleitung auf Handynummer <Handy Nummer> einrichten

    $confirmMobileNr = Read-Host "Soll die Mobilnummer des SU jetzt angelegt werden? [j/n]"

    if (($null -ne $mobilNr) -and ($confirmMobileNr -eq "j")) {

        if($mobilNr.Substring(0,3) -ne "+49"){
            echo "Script gestoppt da Telefonnummer inkorrekt eingegeben wurden. Bitte beachten Sie dass die TelefonNr mit +49 anfangen muss"
            echo $mobilNr.Substring(0,3)
            exit 20
        }

        $sofortigeUmleitung = Get-IpPbxUserForwarding -UserName $kürzel -ForwardingType Unconditional
        $sofortigeUmleitung.IsEnabled = $true
        $sofortigeUmleitung.Destination = [UserForwardingDestination]::Number
        $sofortigeUmleitung.Number = $mobilNR
        Set-IpPbxUserForwarding -UserForwardingEntry $sofortigeUmleitung

    #creates new Phonebook Entry
        $telefonbucheintrag = New-IpPbxPhonebookEntry -Name ($Kürzel + " (Handy)") -Number $mobilNr -Description $beschreibung -GlobalPhoneBook
        Add-IpPbxPhoneBookEntry -PhoneBookEntry $telefonbucheintrag 
    } else {
        Write-Host "Eine der Konditionen zur Einrichtung der Mobilnummer wurden nicht erfüllt!" -ForegroundColor Red
    }
    
    
    break
}
PK{
    $locationID = 1
#KEINE ABTEILUNGSRUFNUMMER

    $neueInterneRufnummer = Get-IpPbxNextFreeInternalNumber -BeginSearchFromNumber 160
    if($neueInterneRufnummer -gt "199"){
        echo "Maximale Rufnummer für PK erreicht"
        exit 200
    }

    $user = New-IpPbxUser -UserName $kürzel -Comment $beschreibung -EmailAddress $email -LocationId $locationID
    
    #erstellt den neuen Benutzer in IpPbx und fügt den Benutzer der "Jeder" Gruppe hinzu
    Add-IpPbxUser -UserEntry $user -AddToEveryoneGroup

    #Add internal number to user
    New-IpPbxInternalNumber -InternalNumber $neueInterneRufnummer | Add-IpPbxInternalNumberToUser -UserEntry $user
    #Add Public number equal to internal number
    $öffentlicheRufnummer = "+4972484500" + $neueInterneRufnummer
    New-IpPbxPublicNumber -PublicNumber $öffentlicheRufnummer | Add-IpPbxPublicNumber -InternalNumber $neueInterneRufnummer

    #Adds Domain Login to User
    $domainLogin = "IN-KLR\" + $kürzel
    Add-IpPbxUserWindowsAccount -UserEntry $user -NTAccount $domainLogin
    
    #Setzt Skin für Benutzer
    $userdata = Get-IpPbxUserData -UserName $kürzel
    $userdata.m_szSkinName = "SwyxIt! 2015 [3x HD].cab"
    Set-IpPbxUserData -UserName $kürzel -UserData $userdata

    break
}

}


#Creates and sets RemoteConnector Certificate
$RootPass = (ConvertTo-SecureString -String '3edcft678#####' -AsPlainText -Force) 
Get-IpPbxUser -UserName $kürzel | New-IpPbxClientCertificate -RootPassword $RootPass

#Standard Settings

#Set standard Login with username and passwort to user
Set-IpPbxUserLogin -UserName $kürzel -LoginName $kürzel -Password "1234" -EnableLogin

#Einstellungen für alle Abteilungen außer SB und SU
$allowedList = "VA", "MK", "KUS", "KUB", "DRE.VU", "SU"
if($allowedList -contains $abteilung){
    $userintrusiondata = Get-IpPbxUser -UserName $kürzel
    foreach($chef in $chefListe){
        $chefNr = Get-IpPbxInternalNumber -UserName $chef
        $chefID = $chefNr.InternalNumberID
        echo "Chef list"
        echo $chef
        echo $chefNr

        $CollectionEntry = New-Object "SWCOnfigDataClientLib.Proxies.Users.UserIntrusionNumberEntry"
        $CollectionEntry.UserID = $user.UserID
        $CollectionEntry.InternalNumberID = $chefID[0]

        $userintrusiondata.UserIntrusionNumberEntryCollection.Add($CollectionEntry)
    }
    Update-IpPbxUser -UserEntry $userintrusiondata 
    

    #Schnellwahl Tasten für KUB, HOT, Auftragsbearbeitung, Interessent, AdminKLR hinterlegen
    #KUB=522, HOT=5200, Auftragsbearbeitung(öffentliches Wartefeld)=5100, Interessent=5111 (öffentlich-450), AdminKLR=400
    Set-IpPbxSpeedDialKeyCount -UserName $kürzel -SpeedDialKeyCount 160
    $speeddialkeyKUB = Get-IpPbxSpeedDialKey -UserEntry $user -SpeedDialKeyId 0
    $speeddialkeyKUB.DialNumber = 5222
    $speeddialkeyKUB.Label = "Kundenberatung"
    $speeddialkeyHOT = Get-IpPbxSpeedDialKey -UserEntry $user -SpeedDialKeyId 1
    $speeddialkeyHOT.DialNumber = 5200
    $speeddialkeyHOT.Label = "Hotline"
    $speeddialkeyAB = Get-IpPbxSpeedDialKey -UserEntry $user -SpeedDialKeyId 2
    $speeddialkeyAB.DialNumber = 5100
    $speeddialkeyAB.Label = "Auftragsbearbeitung"
    $speeddialkeyINT = Get-IpPbxSpeedDialKey -UserEntry $user -SpeedDialKeyId 3
    $speeddialkeyINT.DialNumber = 5111
    $speeddialkeyINT.Label = "Interessent"
    $speeddialkeyADM = Get-IpPbxSpeedDialKey -UserEntry $user -SpeedDialKeyId 4
    $speeddialkeyADM.DialNumber = 400
    $speeddialkeyADM.Label = "AdminKLR"

    Update-IpPbxSpeedDialKey -UserName $kürzel -SpeedDialKey $speeddialkeyKUB
    Update-IpPbxSpeedDialKey -UserName $kürzel -SpeedDialKey $speeddialkeyHOT
    Update-IpPbxSpeedDialKey -UserName $kürzel -SpeedDialKey $speeddialkeyAB
    Update-IpPbxSpeedDialKey -UserName $kürzel -SpeedDialKey $speeddialkeyINT
    Update-IpPbxSpeedDialKey -UserName $kürzel -SpeedDialKey $speeddialkeyADM

    #grenzt PK aus dem nächsten Schritt aus da PK keine Abteilungsrufnummer hat, IF kann entfernt werden, sollte PK eine Abteilungsrufnummer erhalten
    if(($abteilung -ne "PK") -or ($abteilung -ne "SU")){
        $alternativeNummerUser = Get-IpPbxUser -UserName $kürzel
        $AbteilungsNrID = $interneAbteilungsRufnummer.InternalNumberID
        $alternativeNummerObj = New-Object "SWConfigDataClientLib.Proxies.Users.SubstitutedNumberEntry"
        $alternativeNummerObj.InternalNumberID = $AbteilungsNrID
        $alternativeNummerUser.SubstitutedNumberEntryCollection.Add($alternativeNummerObj)
        Update-IpPbxUser -UserEntry $alternativeNummerUser
    }
        #Nur bei VA/CS/MA: Leitungstasten konfigurieren, 1/2 = Abteilungsrufnummer, 3 = Durchwahl
        #Nur bei DRE:  Leitungstasten konfigurieren 1/2 = Abteilungsrufnummer

        $lineKeyList = Get-IpPbxUserLineKeyList -UserName $kürzel
        $lineKeyList[0].DefaultLine = 1
        $lineKeyList[0].LineDisabled = 0
        $lineKeyList[0].WrapUpTimeout = 120
        $lineKeyList[0].EnableWrapUpTime = 0
        $lineKeyList[0].HideDialNumber = 0
        $lineKeyList[0].ExtOutByAdmin = 0
        $lineKeyList[0].Title = $telLeitung
        $lineKeyList[0].ExtensionOutGoing = $interneAbteilungsRufnummer.Number

        $lineKeyList[1].DefaultLine = 0
        $lineKeyList[1].LineDisabled = 0
        $lineKeyList[1].WrapUpTimeout = 120
        $lineKeyList[1].EnableWrapUpTime = 0
        $lineKeyList[1].HideDialNumber = 0
        $lineKeyList[1].ExtOutByAdmin = 0
        $lineKeyList[1].Title = $telLeitung
        $lineKeyList[1].ExtensionOutGoing = $interneAbteilungsRufnummer.Number
        
        #Grenzt DRE aus, da DRE nur zwei Leitungstasten hat
        if($abteilung -ne "DRE.VU"){
            $lineKeyList[2].DefaultLine = 0
            $lineKeyList[2].LineDisabled = 0
            $lineKeyList[2].WrapUpTimeout = 120
            $lineKeyList[2].EnableWrapUpTime = 0
            $lineKeyList[2].HideDialNumber = 0
            $lineKeyList[2].ExtOutByAdmin = 0
            $lineKeyList[2].Title = $kürzel
            $lineKeyList[2].ExtensionOutGoing = $neueInterneRufnummer
        }
        Set-IpPbxUserLineKeyList -UserName $kürzel -LineKeyList $lineKeyList -AdjustLineKeyCount
}
else{
    echo "Abteilung ist SB, spezielle Einstellungen werden übersprungen"
}

Disconnect-IpPbx

# ======================== QUELLCODE VORLAGEN ========================
#creates new user object
    #$user = New-IpPbxUser -UserName $kürzel -Comment $beschreibung -EmailAddress $email -LocationId $locationID
    #Add-IpPbxGroupMember -UserEntry $user -GroupName $gruppe

#Add internal number to user
    #New-IpPbxInternalNumber -InternalNumber $neueInterneRufnummer | Add-IpPbxInternalNumberToUser -UserEntry $user

#Add Public number equal to internal number
    #$öffentlicheRufnummer = "+4972484500" + $neueInterneRufnummer
    #New-IpPbxPublicNumber -PublicNumber $öffentlicheRufnummer | Add-IpPbxPublicNumber -UserEntry $user

#Authentifizierung per Windows Konto hinterlegen: <Kürzel>
    #$domainLogin = "IN-KLR\" + $kürzel
    #Add-IpPbxUserWindowsAccount -UserEntry $user -NTAccount $domainLogin
 
#Anmelde-Einstellung Benutzername/Kennwort aktivieren und Kennwort "1234" hinterlegen
    #Set-IpPbxUserLogin -UserEntry $user -Password "1234" -EnableLogin

#Nur bei SU/SB/DRE: Öffentliche Rufnummer entfernen
#Es wird keine hinterlegt

#Nur bei SU/SB/PK: interne/öffentliche FaxNummer hinterlegen
    #New-IpPbxInternalNumber -InternalNumber $neueInterneRufnummer | Add-IpPbxInternalNumberToUser -UserEntry $user
    #Nur bei SU/SB/PK: Faxe müssen bei Peoplefone manuell konfiguriert werden (hier ggfs info mit FaxNr in die E-Mail an Admin

#Nur bei SU/SB: EIntrag im Telefonbuch: Name = <Kürzel> <Mobilnummer>, Beschreibung = <Abteilung>/<Kürzel> <Vollständiger Name>
    #New-IpPbxPhonebookEntry -Name ($Kürzel + " (Handy)") -Number $mobilNr -Description ($abteilung + "/" + $kürzel + " " + $vorname + " " + $nachname)

#Alternative Rufnummern hinterlegen:
#   5100 = Verwaltung/Marketing
#   5200 = Hotline
#   5222 = KUB
#   302 = DRE AB
#   400 = AdminKLR
    #$AbteilungsNrID = $interneAbteilungsRufnummer.InternalNumberID
    #$alternativeNummerObj = New-Object "SWConfigDataClientLib.Proxies.Users.SubstitutedNumberEntry"
    #$alternativeNummerObj.InternalNumberID = $AbteilungsNrID
    #$user.SubstitutedNumberEntryCollection.Add($alternativeNummerObj)

#Rufaufschaltung konfigurieren
#Nur bei CS/DRE: Zuhören einrichten, KUS = MS, KUB = TP, DRE = YF+RFW, VA=DRI, AWE, DK
    #foreach($chef in $cheflist){
        #$chefNr = Get-IpPbxInternalNumber -UserName $chef
        #$chefID = $chefNr.InternalNumberID

        #$CollectionEntry = New-Object "SWCOnfigDataClientLib.Proxies.Users.UserIntrusionNumberEntry"
        #$CollectionEntry.UserID = $user.UserID
        #$CollectionEntry.InternalNumberID = $chefID[0]

        #$user.UserIntrusionNumberEntryCollection.Add($CollectionEntry)
    #}
    #Update-IpPbxUser -UserEntry $user
