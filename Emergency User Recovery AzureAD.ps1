function CreateUser($Nutzername, $group){

    
    $Konto = $Nutzername
    $TRKonto = "Academy\" + $Konto
    $uid = $Konto + "@academy.local"
    $Name = $Nutzername
    $pwgen= "P@ssword1"
    $pw = ConvertTo-SecureString -AsPlainText $pwgen -Force

    $Nutzername

   # try{
        New-ADUser -Server "academy.local" -Name $Nutzername -DisplayName $Nutzername -description $g -UserPrincipalName ($Konto + "@academy.local") -SamAccountName $Nutzername -Path $OUUser –AccountPassword $pw -PasswordNeverExpires $true -Enabled 1
        Add-adgroupmember -Identity $group -Server "academy.local" -Members $Konto
        Write-Host $Nutzername
        Write-Host $group

        return "Benutzer $Konto wurde angelegt"
   # }catch{
    #return "Benutzer $Konto existiert schon"  }
}


function Gruppengen($group){
    if(-not(Get-ADGroup -Filter {name -eq $Group} -Server "academy.local")){
        new-adgroup -GroupScope Universal -Name $Group -Path $OUGroups -Server "academy.local"
    } else {
        return "ACHTUNG! Gruppe existiert schon"
        
        $fortf = Read-Host "Trotzdem fortfahren? y/n"
        if ($fortf -eq "y") {
            Start-Sleep -Seconds 15
        }else {
            exit
        }
       
    }    sleep 5

}

function VMMrolegen($Benutzername){
    $Konto = $Benutzername
    $TRKonto = "Academy\" + $Konto

    <#if($Standort -eq "nbg"){

        repadmin /syncall academy.local /AdeP

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



    

        $MyVMM = "vmm01.academy.local"
        Get-SCVMMServer -ComputerName $MyVMM
        $cloud = Get-SCCloud -Name Academy

        $scopeToAdd = @()
        $scopeToAdd += Get-SCCloud -ID "7f2d03b7-cd8d-4d79-9859-4daee06e5671"
        $JobGroupID = [Guid]::NewGuid().ToString()
        Add-SCUserRolePermission -Cloud $cloud -JobGroup $JobGroupID
        Set-SCUserRole -JobGroup $JobGroupID -AddMember $TRKonto -AddScope $scopeToAdd -Permission @("CreateFromVHDOrTemplate", "Create", "AllowLocalAdmin", "PauseAndResume", "RemoteConnect", "Remove", "Shutdown", "Start", "Stop") -ShowPROTips $false -VMNetworkMaximumPerUser "11" -VMNetworkMaximum "11"
        Set-SCUserRoleQuota -Cloud $cloud -JobGroup $JobGroupID -CPUCount "10" -MemoryMB "20480" -StorageGB "2200" -UseCustomQuotaCountMaximum -VMCount "8"
        Set-SCUserRoleQuota -Cloud $cloud -JobGroup $JobGroupID -QuotaPerUser -CPUCount "10" -MemoryMB "20480" -StorageGB "2200" -UseCustomQuotaCountMaximum -VMCount "8"
        

        New-SCUserRole -Name $Konto -UserRoleProfile "TenantAdmin" -Description $Group -JobGroup $JobGroupID


    $userRole = Get-SCUserRole -Name $Konto

    $logicalNetwork = Get-SCLogicalNetwork -Name "LogicalNetwork"
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

function SamExtract($List) {
    #$List
    $Global:Breakup.Clear()

    foreach ($String in $List) {
        
        $Global:Breakup += $String.replace("@training.lug-ag.de","")
        
    }
    #$Breakup
}

$OUUser = "OU=User,OU=SGB3,OU=Academy,DC=academy,DC=local"
$OUGroups = "OU=Groups,OU=SGB3,OU=Academy,DC=academy,DC=local"
$Switch1 = 'Netzwerk 1'
$Switch2 = 'Netzwerk 2'
$Switch3 = 'Netzwerk 3'
$Switch4 = 'Netzwerk 4'
$Switch5 = 'Netzwerk 5'
$Users = $null
$Groups = $null
$Nutzername = $null
$Benutzername = $null
$Global:Breakup = @()

Connect-MsolService
$Groups = Get-MsolGroup | Where-Object DisplayName -eq "PPDT 22-3"

foreach ($Global:g in $Groups){
    $Users = @()
    $Users += (Get-MsolGroupMember -GroupObjectId $g.ObjectId).EmailAddress
    #$Users
    Write-Host $Users
    SamExtract -List $Users
    Gruppengen -group $g.DisplayName
    #Write-Host $Global:Breakup.Count
    foreach ($SamAccountName in $Global:Breakup) {
        
        
        Write-Host "Call createUser $SamAccoutName"
        CreateUser -Nutzername $SamAccountName -group $g.DisplayName
    } 
    
}
Write-Host -ForegroundColor Red "Nicht vergessen das 'Trainer aus allen Gruppen entfernen' Skript auszuführen "
