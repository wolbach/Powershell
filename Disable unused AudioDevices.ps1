Start-Transcript -LiteralPath $env:HOMEDRIVE\DisableAudioDevices.txt
$prohibitedDevices = @("Dell","NVIDIA","Realtek")

$AudioDevices = Get-PnpDevice -Class MEDIA

foreach ($device in $AudioDevices) {
    $deviceSkip = $false
    for ($i = 0; $i -lt $prohibitedDevices.Count; $i++) {
        if ($device -match $prohibitedDevices[$i] -and $device -match "Audio") {
            $deviceSkip = $true
        }
    }

    switch ($deviceSkip) {
        $true { 
                if ($device.Status -eq "OK") {
                    Disable-PnpDevice -InstanceId $device.InstanceId -Confirm:$false
                    Write-Host "Disabled "$device.FriendlyName
                }else {
                    Write-Host $device.FriendlyName" Skipped!"
                }
            }
        $false {Write-Host $device.FriendlyName" Skipped!"}
        Default {Write-Host -ForegroundColor Red "err"}
    }
}
Stop-Transcript