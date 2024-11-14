$allDevices = Get-PnpDevice
$ID = "{9D4F0FF5-FED9-4F61-9F38-2777AC5B5E66}"
$Table = @{}

foreach ($Device in $allDevices){
    $Properties = Get-PnpDeviceProperty -InstanceId $Device.InstanceId
    
    foreach($Property in $Properties){
        if($Property.type -match "Guid"){
            $table.Add($Device, $Property.Data)
    }
    }

    }

$Table | Format-Table -AutoSize