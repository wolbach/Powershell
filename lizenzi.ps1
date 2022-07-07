<#
Skript für zusammenführung von allen Lizenzverwaltungsskripten
#>

if (-not(Get-Module ActiveDirectory))
{ Import-Module ActiveDirectory }

Connect-MsolService 

$Gruppe = $null
$Members = $null
$UPN = $null

$Gruppe = Read-Host "Bitte Kursnamen angeben"
$Members = Get-ADGroupMember $Gruppe -Server "training.lug-ag.de"

foreach ($Member in $Members){

$Membi = Get-MsolUser -UserPrincipalName ($Member.samaccountname + "@training.lug-ag.de")

Write-Host $Membi.DisplayName   ($Membi.licenses).AccountSkuId 
$UPN += $Membi.DisplayName
}

$do = Read-Host "

Was soll getan werden?

1 = Standard auf Basic-Lizenz
2 = Lizenzen wegnehmen
(Nichts angeben: Abbrechen)
"

if ($do -eq 1) {
    Standard-to-Basic -Gruppe $Gruppe -Members $Members
} elseif ($do -eq 2) {
    Wegnehmen
}elseif ($do -eq 3) {
    <# Action when this condition is true #>
}elseif ($do -eq 4) {
    <#condition#>
}

# Funktionen
function Standard-to-Basic {
    param (
        $Members,
        $Gruppe
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
        $a = Get-MsolUser -UserPrincipalName $UPN
        [int]$Zahl = $Zahl + 1
      }


#$LO = New-MsolLicenseOptions -AccountSkuId "reseller-account:O365_BUSINESS_ESSENTIALS"
#Set-MsolUser -UserPrincipalName $UPN -UsageLocation DE
#Set-MsolUserLicense -UserPrincipalName $UPN -AddLicenses "reseller-account:O365_BUSINESS_ESSENTIALS" -LicenseOptions $LO


    ### Lizenzen verwalten
    Set-MsolUser -UserPrincipalName $UPN -UsageLocation DE
    Set-MsolUserLicense -UserPrincipalName $UPN -RemoveLicenses "reseller-account:O365_BUSINESS_PREMIUM"
    Sleep -Seconds 3
    Set-MsolUserLicense -UserPrincipalName $UPN -AddLicenses "reseller-account:O365_BUSINESS_ESSENTIALS"
}
}

function Wegnehmen {

$a = $null
$zahl = $null

echo "warten auf Office 365 Sync in min (Kann bis zu 35min Dauern)"
Foreach($Member in $Members){


$UPN = $Member.samaccountname + "@training.lug-ag.de"

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
    
    
    $UPN = $Member.samaccountname + "@training.lug-ag.de"
    
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
    
    Write-Host "Benutzer $Membi bearbeitet"    

}
}
}

<#function  {
    param (
        OptionalParameters
    )
    
}#>