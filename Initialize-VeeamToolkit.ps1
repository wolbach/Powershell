$productName = 'Veeam Backup and Replication PowerShell Toolkit'
$host.ui.RawUI.WindowTitle = $productName

#=== Add a temporary value from User to session ($Env:PSModulePath) ======
#https://docs.microsoft.com/powershell/scripting/developer/module/modifying-the-psmodulepath-installation-path?view=powershell-7
$path = [Environment]::GetEnvironmentVariable('PSModulePath', 'Machine')
$env:PSModulePath +="$([System.IO.Path]::PathSeparator)$path"
#=========================================================================

$veeamPSModule = Get-Module -ListAvailable | ?{$_.Name -match "Veeam.Backup.Powershell"}
Import-Module $veeamPSModule.Path -DisableNameChecking

cd $env:userprofile

Write-Host "Welcome to the $productName!"
Write-Host
Write-Host 'To list available commands, type ' -NoNewLine
Write-Host 'Get-VBRCommand' -foregroundcolor yellow
Write-Host 'To open online documentation on all available commands, type ' -NoNewLine
Write-Host 'Get-VBRToolkitDocumentation' -foregroundcolor yellow
Write-Host
Write-Host $veeamPSModule.Copyright
Write-Host
Write-Host
