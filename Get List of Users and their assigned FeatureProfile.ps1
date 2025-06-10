$FeatureProfPremium = Get-IpPbxFeatureProfile -FeatureProfileName "New Premium (75)"
$FeatureProfBasic = Get-IpPbxFeatureProfile -FeatureProfileName "New Basic"
$allUsers = Get-IpPbxUser
$assignment = @{
    Name = ''
    FeatureProfile = ''
}

foreach ($user in $allUsers) {
    # Filter for actual, non-generic users
    if ($user.Name.Length -eq 2 -or $user.Name.Length -eq 3) {
       
    
    $username = $user.Name
    $FID = $user.FeatureProfileID
    switch ($FID) {
        4 { 
            #Write-Host "$username - Premium"
            $assignment.Add($username,"Premium" )
        }
        6 { 
            #Write-Host "$username - Basic"
            $assignment.Add($username,"Basic" )
        }
        Default {
            Write-Host "$username - Unassigned"
            $assignment.Add($username,"Unassigned" )
        }
    }
}
}