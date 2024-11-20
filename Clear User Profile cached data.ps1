$detectblock = {
    $ups = Get-CimInstance -ClassName Win32_UserProfile
    #$filteredups = $ups | where-Object {$_.LastUseTime -EQ $null -or $_.LastUseTime -lt (Get-Date).AddMonths(-1)}
    
    return $ups
    
    }
    $pw = ConvertTo-SecureString -String "SLS500-928s" -AsPlainText -Force
    $credential = [pscredential]::new("in-klr\administrator",$pw)
    $session = New-PSSession -ComputerName "termserv4.in-klr.com" -Credential $credential
    
    $result = Invoke-Command -Session $session -ScriptBlock $detectblock 

    foreach ($user in $result) {
      try{
        $ADUser = Get-ADUser $user.SID -Properties LastLogonDate, Enabled -ErrorAction SilentlyContinue | select SamAccountName, LastLogonDate, Enabled
    	Write-Host $ADUser
        if (($ADUser.Enabled -eq $false) -or ($User.LastUseTime -lt (Get-Date).AddMonths(-1))) {
            Write-Host "Deleting" $ADuser.SamAccountName
            $testrm = Invoke-Command -Session $session -Credential $credential -ScriptBlock { Remove-CimInstance -InputObject $User }
        	Write-Host $testrm
        }
      }catch{
            Write-Host $User.SID "could not be found in AD"
            Write-Host "Checking for Alternatives..."
            if ($User.SID.Length -lt 10) {
                Write-Host "Profile belongs to local scope - Skipping..."
                continue
            }else {
                Write-Host "Most likely deleted user - Deleting Profile..."
                Invoke-Command -Session $session -ScriptBlock { Remove-CimInstance -InputObject $User }
            }
        }
    }
    
    Remove-PSSession $session