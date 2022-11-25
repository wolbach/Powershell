BeforeAll {
    #Insert all functions which are to be tested:
    function New-VMMRole {
        param (
            $User,
            $art
        )
        $TRKonto = "ACADEMY\"+$script:sam
        
        Get-SCVMMServer "vmm01"
    
        if ($art -eq "f") {
        
        $scopeToAdd = @()
            $scopeToAdd += Get-SCCloud -ID "7f2d03b7-cd8d-4d79-9859-4daee06e5671"
            $JobGroupID = [Guid]::NewGuid().ToString()
            Add-SCUserRolePermission -Cloud $cloud -JobGroup $JobGroupID
            Set-SCUserRole -JobGroup $JobGroupID -AddMember $TRKonto -AddScope $scopeToAdd -Permission @("CreateFromVHDOrTemplate", "Create", "AllowLocalAdmin", "PauseAndResume", "RemoteConnect", "Remove", "Shutdown", "Start", "Stop") -ShowPROTips $false -VMNetworkMaximumPerUser "11" -VMNetworkMaximum "11"
            Set-SCUserRoleQuota -Cloud $cloud -JobGroup $JobGroupID -CPUCount "8" -MemoryMB "16384" -StorageGB "2200" -UseCustomQuotaCountMaximum -VMCount "6"
            Set-SCUserRoleQuota -Cloud $cloud -JobGroup $JobGroupID -QuotaPerUser -CPUCount "8" -MemoryMB "16384" -StorageGB "2200" -UseCustomQuotaCountMaximum -VMCount "8"
    
            New-SCUserRole -Name $script:sam -UserRoleProfile "TenantAdmin" -JobGroup $JobGroupID
            sleep 5
            $userRole =  Get-SCUserRole -VMMServer $vmm -Name $User.SamAccountName
    
            $vmNetwork = New-SCVMNetwork -AutoCreateSubnet -Name $Switch1 -LogicalNetwork $logicalNetwork -Description $User.SamAccountName
            Set-SCVMNetwork -VMNetwork $vmNetwork -RunAsynchronously -Owner $TRKonto -UserRole $userRole
        
            $vmNetwork = New-SCVMNetwork -AutoCreateSubnet -Name $Switch2 -LogicalNetwork $logicalNetwork -Description $User.SamAccountName
            Set-SCVMNetwork -VMNetwork $vmNetwork -RunAsynchronously -Owner $TRKonto -UserRole $userRole
        
            $vmNetwork = New-SCVMNetwork -AutoCreateSubnet -Name $Switch3 -LogicalNetwork $logicalNetwork -Description $User.SamAccountName
            Set-SCVMNetwork -VMNetwork $vmNetwork -RunAsynchronously -Owner $TRKonto -UserRole $userRole
        
            $vmNetwork = New-SCVMNetwork -AutoCreateSubnet -Name $Switch4 -LogicalNetwork $logicalNetwork -Description $User.SamAccountName
            Set-SCVMNetwork -VMNetwork $vmNetwork -RunAsynchronously -Owner $TRKonto -UserRole $userRole
        
            $vmNetwork = New-SCVMNetwork -AutoCreateSubnet -Name $Switch5 -LogicalNetwork $logicalNetwork -Description $User.SamAccountName
            Set-SCVMNetwork -VMNetwork $vmNetwork -RunAsynchronously -Owner $TRKonto -UserRole $userRole
    
            $vmInternet = Get-SCVMNetwork -Name "Internet"
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
            
            $script:pwgen = -join ( (35..38) + (49..57) + (65..90) + (97..107) + (109..122) | Get-Random -Count 10 | Foreach-Object {[char]$_}) 
    
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

        $usicheck = Get-ADUser -Identity $script:sam
        return $usicheck
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
                $return = "Msol-Authentifizierung fehlgeschlagen"
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
    
        $comp = Compare-Object -ReferenceObject $AccSku -DifferenceObject $msolicense -IncludeEqual
        
        if ($comp.SideIndicator -eq "==") {
    
            $mslicense = Get-MsolAccountSku | where AccountSkuID -eq $msolicense
            $TNcount = $Users.Count
            $maxLicen = $mslicense.ActiveUnits
            $usedLicen = $mslicense.ConsumedUnits
    
            if (($usedLicen + $TNcount) -gt $maxLicen) {
                Write-Host -ForegroundColor Red "Nicht genügend Lizenzen verfügbar"
                Read-Host "Mit Enter fortfahren, wenn Lizenzen gekauft wurden"
            }elseif (($usedLicen + $TNcount) -lt $maxLicen) {
                Write-Host "Genügend Lizenzen vorhanden"
            }
        }else {
            Write-Error -Message "Angegebene Lizenz ist ungültig!"
            exit
        }
    
        
    }
}

Describe -Name "Benutzeranlegen"{

    Context "Functions"{

        
    
    It "Test Passwort Generator"{
        Mock Generate-Password
        Generate-Password | Should -ExpectedValue System.Security.SecureString
        $script:pwgen | Should -BeOfType String
    }

    
    It "Test New-VMMRole"{
        Mock New-VMMRole
        New-VMMRole | Should -Not -Be "unexpected string has been received"
    }

    
    It "Validierung der Benutzerdaten"{
        Mock Test-Credentials
        Test-Credentials | Should -ExpectedValue "OK"   
        $Domain.Name | Should -Not -BeNullOrEmpty
    }

    It "Benutzererstellung" {
        Mock Create-User
        Create-User | Should -BeOfType Microsoft.ActiveDirectory.Management.ADAccount
        $script:sam | Should -Not -BeNullOrEmpty
        $script:UPN | Should -Not -BeNullOrEmpty
        $script:msolupn | Should -Not -BeNullOrEmpty

    }
}
}