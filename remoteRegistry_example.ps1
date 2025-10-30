$hive = [Microsoft.Win32.RegistryHive]::LocalMachine
$regpath32 = "Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\"
$regpath64 = "Software\Microsoft\Windows\CurrentVersion\Uninstall\"
$regView32 = [Microsoft.Win32.RegistryView]::Registry32
$regView64 = [Microsoft.Win32.RegistryView]::Registry64

$server = "F0199999"

$remRegistry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($hive, $server)
$remRegistry.View = $regView64

$remRootKey = $remRegistry.OpenSubKey($regpath64)
$remSubKeys = $remRootKey.GetSubKeyNames()

foreach ($key in $remSubKeys) {
    $softwarePath = "$regpath64$key"
    $softwareReg = $remRegistry.OpenSubKey($softwarePath)
    if ($softwareReg.GetValue("DisplayName")) {
        $softwareInfo = [System.Object]::new()
    $softwareInfo | Add-Member -Type NoteProperty -Name "Name" -Value $softwareReg.GetValue("DisplayName")
    $softwareInfo | Add-Member -Type NoteProperty -Name "Version" -Value $softwareReg.GetValue("DisplayVersion")
    Write-Host "$($softwareInfo.Name) | $($softwareInfo.Version)"
    }
    
}
