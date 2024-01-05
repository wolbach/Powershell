$TargetVMs = @("TEST-VM")

$GPU = Get-PnpDevice -PresentOnly -Class "Display" | where FriendlyName -Match "Nvidia"
$locationPath = ($GPU | Get-PnpDeviceProperty DEVPKEY_Device_LocationPaths).data[0]

Disable-PnpDevice $GPU.InstanceId

# -Force usage depends on if a special driver is available from the manufacturer:
Dismount-VMHostAssignableDevice -LocationPath $GPU.InstanceID -Force

foreach ($VM in $TargetVMs){
    $TargetVM = Get-VM -Name $VM

    # The following settings can have a positive impact on GPU performance:

    Set-VM -GuestControlledCacheTypes $true -VMName $TargetVM
    # Configure 32 bit MMIO space
    Set-VM -LowMemoryMappedIoSpace 3Gb -VMName $TargetVM
    # Configure Greater than 32 bit MMIO space
    Set-VM -HighMemoryMappedIoSpace 33280Mb -VMName $TargetVM

    #Actually assigning the GPU to the VM
    Set-VM -VM $TargetVM -AutomaticStopAction TurnOff

    Add-VMAssignableDevice -LocationPath $locationPath -VM $TargetVM

}