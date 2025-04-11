if(-not(Get-Module IpPbx)){
    Import-Module IpPbx
}

Connect-IpPbx -ServerName "SWYX-SRV"

$repeat = $true
$UserName = "MSP"

while ($repeat) {
    
    $repeat = $false

    $Groups = Read-Host "
    In welche Abteilung wechselt der Nutzer?
    1) KUS
    2) KUB
    3) MK
    4) SU
    5) VA
    "
    switch ($Groups) {
        1 { 
            $Group = @{
                Name = "Hotline (logged off)";
                Durchwahl = "5200";
                Skin = "3iMedia Call Queue 2020 (right, bottom slim).cab"
            }
        }
        2 {
            $Group = @{
                Name = "Kundenberatung (Gruppe) (logged off)";
                Durchwahl = "5222";
                Skin = "Kundenberatung.cab"
            }
        }
        3 {
            $Group = @{
                Name = "Marketing";
                Durchwahl = "150";
                Skin = "skin SWyxIt! 2015 [3x].cab (Vorlage)"
            }
        }
        4 {
            $Group = @{
                Name = "SU-AD";
                Durchwahl = "";
                Skin = "skin SWyxIt! 2015 [3x].cab (Vorlage)"
            }
        }
        5 {
            $Group = @{
                Name = "Verwaltung (Gruppe) (logged off)";
                Durchwahl = "5100";
                Skin = "Verwaltung.cab"
            }
        }
        test {
            $Group = @{
                Name = "Test";
                Durchwahl = "521";
                Skin = "skin SWyxIt! 2015 [3x].cab (Vorlage)"
        }
        }
        Default { $repeat = $true }
}
}

$targetGroup = Get-IpPbxGroup -GroupName $Group.Name
$targetUser = Get-IpPbxUser -UserName $UserName 
$altNummerObjekt = New-Object "SWConfigDataClientLib.Proxies.Users.SubstitutedNumberEntry"
$userdata = Get-IpPbxUserData -UserName $UserName
$internalNumber = Get-IpPbxInternalNumber -InternalNumber $Group.Durchwahl

# Hinzufügen zur Gruppe und Abteilungsdurchwahl
Add-IpPbxGroupMember -GroupName $Group.Name -UserName $UserName

$altNummerObjekt.InternalNumberID = $internalNumber.Number
$targetUser.SubstitutedNumberEntryCollection.Add($altNummerObjekt)    
$targetUser | Update-IppbxUser 

# Anpassung der obersten Leitung für die neue Abteilung
$linekeylist = Get-IpPbxUserLineKeyList -UserName $targetUser.Name

$linekeylist[0].Title = $Group.Name
$linekeylist[0].ExtensionOutGoing = $internalNumber.Number
$linekeylist[0].DefaultLine = 1

Set-IpPbxUserLineKeyList -UserName $targetUser.UserName -LineKeyList $linekeylist

# Setzen des Skins
$userdata.m_szSkinName = $Group.Skin
Set-IpPbxUserData -UserName $targetUser.Name -UserData $userdata