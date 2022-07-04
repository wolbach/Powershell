<#
Skript für zusammenführung von allen Lizenzverwaltungsskripten
#>


if (-not(Get-Module ActiveDirectory))
{ Import-Module ActiveDirectory }

Connect-MsolService

$Gruppe = $null
$Members = $null
$Uebersicht = $null

$Gruppe = Read-Host "Bitte Kursnamen angeben"
$Members = Get-ADGroupMember $Gruppe -Server "training.lug-ag.de"

foreach ($Member in $Members){
$Membi = Get-MsolUser -UserPrincipalName ($Member.samaccountname + "@training.lug-ag.de")
#$Uebersicht = Get-MsolUserLicense -UserPrincipalName $Membi

Write-Host $Membi.DisplayName   ($Membi.licenses).AccountSkuId 
}

$do = Read-Host "
Was soll getan werden?
1 = Standard auf Basic-Lizenz
2 = ...
"
if ($do -eq 1) {
    Standard-to-Basic -Gruppe $Gruppe -Members $Members
}

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

    $UPN = $Member.samaccountname + "@training.lug-ag.de"

    $ErrorActionPreference = "SilentlyContinue"
    while ($a -eq $null) {
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