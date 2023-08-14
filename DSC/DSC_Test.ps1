if (-not (Get-Module PSDesiredStateConfiguration)){
    Install-Module PSDesiredStateConfiguration
}
if (-not (Get-Module DSC)){
    Install-Module "DSCTEST1\DSC.psm1"
}

Invoke-DscResource -Name Tailspin -Module DSC -Method Get -Property @{
    ConfigurationScope  = 'User'
    UpdateAutomatically = $true
}