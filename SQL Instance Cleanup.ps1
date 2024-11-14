$kürzel = "Test2"

$UpdateServ = Get-Service | where Name -eq ('IN-FORM Plattform Update$SQL4TEST_'+$kürzel)
$PlattformServ = Get-Service | where Name -eq ('IN-FORM Plattform$SQL4TEST_'+$kürzel)
$DBPath = Get-Item -Path ('D:\SQL_DBs\MSSQL15.SQL4TEST_'+$kürzel) -ErrorAction SilentlyContinue
$INFORMPath = Get-Item -Path ('D:\SQL4TEST\INFORM_SQL4TEST\'+$kürzel+'_INFORM') -ErrorAction SilentlyContinue
$dAdminCred = Get-Credential -UserName "in-klr\administrator" -Message "Enter Admin-PW"

Start-Transcript -Path "C:\temp\$kürzel Cleanup.txt"
#Delete DB Folder if it exists
if(Test-Path -LiteralPath $DBPath){
    Remove-Item $DBPath -Recurse #-Credential $dAdminCred
}

# Temporary check if local system is configured in service
$AllServiceStartNames = Get-CimInstance -ClassName CIM_Service | select Name, StartName
$selectedService = $AllServiceStartNames | where Name -eq $PlattformServ.Name

if($selectedService.StartName -ne "LocalSystem"){
    do {
        $confirmation = Read-Host "Please set $selectedService Startup Account to LocalSystem. Then enter Y"
    } while ($confirmation -ne "Y")
}

# Stop Services when running and deactivate them
while($UpdateServ.Status -eq "Running"){
    Write-Host "Stoppe Update-Dienst..."
    Stop-Service -Name $UpdateServ.Name -NoWait
    sleep 10
    $UpdateServ.Refresh()
}
Write-Host "Deaktiviere Autostart des Update-Dienstes..."
Set-Service -Name $UpdateServ.Name  -StartupType Disabled -ComputerName "SQL4TEST" 

while($PlattformServ.Status -eq "Running"){
    Write-Host "Stoppe Plattform-Dienst..."
    Stop-Service -Name $PlattformServ.Name -NoWait
    sleep 10
    $PlattformServ.Refresh()
}
Write-Host "Deaktiviere Autostart des Plattformdienstes..."
Set-Service -Name $PlattformServ.Name -StartupType Disabled -ComputerName "SQL4TEST" 

#Delete INFORM Path if it exists
Write-Host "Lösche "+$kürzel+"_INFORM"
if($INFORMPath){
    Remove-Item $INFORMPath -Recurse -Force
}

#Get and delete all FW Rules
Get-NetFirewallRule -All | where DisplayName -eq "Freigabe für IN-FORM SQL4TEST_$kürzel" | Remove-NetFirewallRule
Write-Host "SQL Server Firewall Rule deleted"
Get-NetFirewallRule -All | where DisplayName -eq "Freigabe für WIP.exe SQL4TEST_$kürzel" | Remove-NetFirewallRule
Write-Host "WIP Firewall Rule deleted"

Stop-Transcript
