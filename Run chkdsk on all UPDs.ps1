$allDisks = Get-ChildItem -Path "\\File-srv\userprofiledisks" 

foreach ($Disk in $allDisks) {
    Write-Host "Processing "$Disk.Name
    $IDrive = New-PSDrive -Name I: -PSProvider FileSystem -Root $Disk.FullName
    chkdsk.exe I: /f | Out-Null
    Remove-PSDrive $IDrive

    if ("I" -in (Get-PSDrive | select Name)) {
        return "Drive still connected!"
    }else {
        Continue
    }
}
