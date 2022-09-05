$lizis = $null
$lizan = $null
$Standort = $null
$Group = $null
$grouppruef = $null
$VMMuser = $null
$trainer = $null
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
$Form = $null

Add-Type -AssemblyName PresentationFramework
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = @"
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        
        Title="Benutzeranlegen V4.2.1" Height="450" Width="800">
    <Grid>
        <TextBlock Name="textBlock" HorizontalAlignment="Left" Height="23" Margin="10,10,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="770" Text=""/>
        <Button Name="button" Content="Run" HorizontalAlignment="Left" Height="24" Margin="693,379,0,0" VerticalAlignment="Top" Width="71"/>
        <Button Name="button1" Content="Cancel" HorizontalAlignment="Left" Height="24" Margin="606,379,0,0" VerticalAlignment="Top" Width="68"/>
        <TextBlock Name="textBlock2" HorizontalAlignment="Left" Height="23" Margin="10,38,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="390" Text=""/>
    <ComboBox Name="comboBox" HorizontalAlignment="Left" Height="23" Margin="453,122,0,0" VerticalAlignment="Top" Width="308">
        <ComboBoxItem Content="Fachinformatiker"/>
        <ComboBoxItem Content="Ondeso"/>
        <ComboBoxItem Content="Office"/>
    </ComboBox>
    <TextBlock Name="Kursart" HorizontalAlignment="Left" Height="23" Margin="24,122,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="390" Text=""/>
    <TextBlock Name="TextBlock1" HorizontalAlignment="Left" Height="25" TextWrapping="Wrap" VerticalAlignment="Top" Width="181" Margin="24,150,0,0"><Run Language="de-de" Text=""/></TextBlock>
    <ComboBox Name="Standorte" HorizontalAlignment="Left" Height="23" Margin="453,150,0,0" VerticalAlignment="Top" Width="308">
        <ComboBoxItem Content="Karlsruhe"/>
        <ComboBoxItem Content="Heilbronn"/>
        <ComboBoxItem Content="Leinfelden"/>
        <ComboBoxItem Content="Nürnberg"/>
    </ComboBox>
    
    <RadioButton Name="radioButton" Content="Nein" HorizontalAlignment="Left" Height="15" VerticalAlignment="Top" Width="84" Margin="677,180,0,0" />
    <RadioButton Name="radioButton1" Content="Ja" HorizontalAlignment="Left" Height="15" VerticalAlignment="Top" Width="85" Margin="576,180,0,0"/>
    <TextBlock Name="radios" Text="Traineraccount? (Bei mehreren Accounts sind alle betroffen)" HorizontalAlignment="Left" Height="28" VerticalAlignment="Top" Width="332" Margin="24,180,0,0"/>
    <TextBox Name="textBox" HorizontalAlignment="Left" Height="19" Margin="24,0,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="272"/>
    </Grid>
</Window>
"@
#Read XAML
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader"; exit}
# Store Form Objects In PowerShell
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}

$textBlock.AddText( "Bitte prüfen, ob genug Basic / Standard / Teams Lizenzen frei sind! Es werden mindestens $lizan Lizenzen benötigt!" )
$TextBlock1.AddText( "Standort auswählen" )
$Kursart.AddText( "Welche Art von Kurs?" )


$button.Add_Click({
    Reset-Variables
    $textBlock2.AddText( "training.lug-ag.de MS365 Admin eingeben (Separates Fenster)" )
    Connect-MsolService
    Connect-MicrosoftTeams
    
    Select-Kursart
    $Kursart.AddText(" $ONDESOuser,$VMMuser,$O365tn")

    switch ($Standorte.SelectedIndex) {
        0 { $Standort = "ka" }
        1 { $Standort = "hn" }
        2 { $Standort = "s" }
        3 { $Standort = "nbg" }
        Default { $TextBlock1.AddText( " Ungültige Eingabe" )}
    }
    $TextBlock1.AddText(" $Standort")

    if ($radioButton.IsChecked -eq $true) {
        $trainer = "n"
    }
    if ($radioButton1.IsChecked -eq $true) {
        $trainer = "y"
    }
    if ($radioButton.IsChecked -eq $false -and $radioButton1.IsChecked -eq $false) {
        $radios.AddText( " Bitte eine der Optionen wählen" )
    }
    $radios.AddText(" $trainer")
})

$button1.Add_Click({
    $Form.Close()
})

$Form.ShowDialog() | out-null

# Funktionen
function Reset-Variables {
$lizis = $null
$lizan = $null
$Standort = $null
$Group = $null
$grouppruef = $null
$VMMuser = $null
$trainer = $null
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


}
function Select-Kursart {
    
    switch ($comboBox.SelectedIndex) {
        0 { $VMMUser = "y" }
        1 { $ONDESOuser = "y" }
        2 { $O365tn = "y" }
        Default { $Kursart.AddText( " Ungültige Eingabe" ) }
    } 
            if($ONDESOuser -eq "y"){
            $VMMuser = $null
            } elseif ($ONDESOuser -ne "y") {
                $script:ONDESOuser = "n"
            }
            if ($VMMUser -ne "y") {
                $script:VMMUser = "n"
            }
            if ($0365tn -ne "y") {
                $script:O365tn = "n"
            }
            
    
}

function Get-Users {

    $Users = Import-Csv C:\skripts\user.csv -Delimiter ";" -Encoding UTF8
    $lizis = $Users | Measure-Object
    $lizan = $lizis.Count

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
}

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