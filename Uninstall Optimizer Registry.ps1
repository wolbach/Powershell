$regString64 = "HKLM:\SOFTWARE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{286A9ADE-A581-43E8-AA85-6F5D58C7DC88}"
$regString32 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{1344E072-D68B-48FF-BD2A-C1CCCC511A50}"

try {
    $app64 = Get-ChildItem -Path $regString64 -ErrorAction SilentlyContinue | Get-ItemProperty | where {$_.DisplayName -match "dell"} 
    
    if ($app64.DisplayName -eq "Dell Optimizer") {
        $app64.UninstallString
    }
}
catch {
    $app32 = Get-ChildItem -Path $regString32 -ErrorAction SilentlyContinue | Get-ItemProperty | where {$_.DisplayName -match "dell"}
    if ($app32.DisplayName -eq "Dell Optimizer") {
        $app32.UninstallString
    }elseif ($app32.DisplayName -eq "") {
        <# Action when this condition is true #>
    }
} 
finally {
    Write-Host -ForegroundColor Red "Couldn't find any Version of Optimizer in Registry"
}


