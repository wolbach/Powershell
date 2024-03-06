$allDevices = Get-PnpDevice
$ID = "{0A556D98-CFEE-4D84-82A7-00377F939198}"
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