$SQLVM = Get-VM -Name "SQLHOST-KLR"
$txtfile = "C:\temp\SQLHOST_MigrationDuration.txt"
if (!(Get-Item C:\temp\)) {
    New-Item -ItemType File -Path $txtfile
}

$watch = [System.Diagnostics.Stopwatch]::new()
$watch.Start()

Export-VM -VM $SQLVM -Path E:\TEST\

$watch.Stop()
[math]::Round($watch.Elapsed.TotalHours,2) >> $txtfile