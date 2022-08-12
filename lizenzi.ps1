<#
Skript für zusammenführung von allen Lizenzverwaltungsskripten

v1.0 Einfügen der Funktion zum ändern der Lizenz von Standard auf Basic oder Wegnahme
#>

if (-not(Get-Module ActiveDirectory))
{ Import-Module ActiveDirectory }

Connect-MsolService 

$Gruppe = $null
$Members = $null

$count = 0

$Gruppe = Read-Host "Bitte Kursnamen angeben"
$Members = Get-ADGroupMember $Gruppe -Server "training.lug-ag.de"

$lizis = $Members | measure
$lizan = $lizis.Count
$UPN = $null

foreach ($Member in $Members){
$UPN = $Member.samaccountname + ("@training.lug-ag.de")
$Membi = Get-MsolUser -UserPrincipalName $UPN

Write-Host $Membi.DisplayName:
   ($Membi.licenses).AccountSkuID
}

Read-Host "

Was soll getan werden?

1 = Standard auf Basic-Lizenz
2 = Lizenzen wegnehmen
3 = Basic auf Standard (nicht fertig)
(Nichts angeben: Abbrechen)
"

if ($do -eq 1) {
    Standard-to-Basic -Gruppe $Gruppe -Members $Members -UPN $UPN
} elseif ($do -eq 2) {
    Wegnehmen
}elseif ($do -eq 3){
    Basic-to-Standard
}else {
    Write-Host "Ungültige Eingabe"
}

# Funktionen
function Standard-to-Basic {
    param (
        $Members,
        $Gruppe,
        $UPN
    )
    $a = $null
    $zahl = $null
    $LizenzAbfrage = $null

    $lizis = $Members | measure
$lizan = $lizis.Count


while($LizenzAbfrage -ne "y"){
    Write-Host "Bitte prüfen, ob genug Basic / Standard / Teams Lizenzen frei sind!"
    $LizenzAbfrage = Read-Host -Prompt "Wurden die Lizenzen gekauft bzw. sind genügend verfügbar? 
    Es werden mindestens $lizan Lizenzen benötigt! [y/n]"
}

Foreach($Member in $Members){

    echo "warten auf Office 365 Sync in min (Kann bis zu 35min Dauern)"

    $ErrorActionPreference = "SilentlyContinue"
    while ($null -eq $a) {
        Sleep 60
        $a = Get-MsolUser -UserPrincipalName $Member.UserPrincipalName
        [int]$Zahl = $Zahl + 1
      }


#$LO = New-MsolLicenseOptions -AccountSkuId "reseller-account:O365_BUSINESS_ESSENTIALS"
#Set-MsolUser -UserPrincipalName $UPN -UsageLocation DE
#Set-MsolUserLicense -UserPrincipalName $UPN -AddLicenses "reseller-account:O365_BUSINESS_ESSENTIALS" -LicenseOptions $LO


    ### Lizenzen verwalten
    Set-MsolUser -UserPrincipalName $Member.UserPrincipalName -UsageLocation DE
    Set-MsolUserLicense -UserPrincipalName $Member.UserPrincipalName -RemoveLicenses "reseller-account:O365_BUSINESS_PREMIUM"
    Sleep -Seconds 3
    Set-MsolUserLicense -UserPrincipalName $Member.UserPrincipalName -AddLicenses "reseller-account:O365_BUSINESS_ESSENTIALS"
}
}

function Wegnehmen {

$a = $null
$zahl = $null

echo "warten auf Office 365 Sync in min (Kann bis zu 35min Dauern)"
Foreach($Member in $Members){


#$UPN = $Member.samaccountname + "@training.lug-ag.de"

$ErrorActionPreference = "SilentlyContinue"
while ($null -eq $a) {
      $a = Get-MsolUser -UserPrincipalName $UPN
      [int]$Zahl = $Zahl + 1
      Sleep 60
      }


#$LO = New-MsolLicenseOptions -AccountSkuId "reseller-account:O365_BUSINESS_ESSENTIALS"
#Set-MsolUser -UserPrincipalName $UPN -UsageLocation DE
#Set-MsolUserLicense -UserPrincipalName $UPN -AddLicenses "reseller-account:O365_BUSINESS_ESSENTIALS" -LicenseOptions $LO


### Lizenzen verwalten
Set-MsolUser -UserPrincipalName $UPN -UsageLocation DE
Set-MsolUserLicense -UserPrincipalName $UPN -RemoveLicenses "reseller-account:O365_BUSINESS_ESSENTIALS"
Sleep -Seconds 3
Set-MsolUserLicense -UserPrincipalName $UPN -RemoveLicenses "reseller-account:O365_BUSINESS_PREMIUM"
Sleep -Seconds 3
#Set-MsolUserLicense -UserPrincipalName $UPN -AddLicenses "reseller-account:TEAMS_COMMERCIAL_TRIAL"

Write-Host "Benutzer $UPN bearbeitet"


    echo "warten auf Office 365 Sync in min (Kann bis zu 35min Dauern)"
    Foreach($Member in $Members){
    
    
    #$UPN = $Member.samaccountname + "@training.lug-ag.de"
    
    $ErrorActionPreference = "SilentlyContinue"
    while ($null -eq $a) {
          $a = Get-MsolUser -UserPrincipalName $UPN
          [int]$Zahl = $Zahl + 1
          Sleep 60
          }
    
    
    #$LO = New-MsolLicenseOptions -AccountSkuId "reseller-account:O365_BUSINESS_ESSENTIALS"
    #Set-MsolUser -UserPrincipalName $UPN -UsageLocation DE
    #Set-MsolUserLicense -UserPrincipalName $UPN -AddLicenses "reseller-account:O365_BUSINESS_ESSENTIALS" -LicenseOptions $LO
    
    
    ### Lizenzen verwalten
    Set-MsolUser -UserPrincipalName $UPN -UsageLocation DE
    Set-MsolUserLicense -UserPrincipalName $UPN -RemoveLicenses "reseller-account:O365_BUSINESS_ESSENTIALS"
    Sleep -Seconds 3
    Set-MsolUserLicense -UserPrincipalName $UPN -RemoveLicenses "reseller-account:O365_BUSINESS_PREMIUM"
    Sleep -Seconds 3
    #Set-MsolUserLicense -UserPrincipalName $UPN -AddLicenses "reseller-account:TEAMS_COMMERCIAL_TRIAL"
    
    Write-Host "Benutzer "$Member.DisplayName "bearbeitet"    

}
}
}

<#function  {
    param (
        OptionalParameters
    )
    
}#>