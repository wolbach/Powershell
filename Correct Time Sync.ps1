$pw = ConvertTo-SecureString -AsPlainText -Force "SLS500-928s"
$cred = [pscredential]::new("in-klr\administrator",$pw)

$dctime = Invoke-Command -ComputerName "dc-01.in-klr.com" -Credential $cred -ScriptBlock {Get-Date}
$localtime = Get-Date

if (($localtime.Hour.ToString()+":"+$localtime.Minute.ToString()) -ne ($dctime.Hour.ToString()+":"+$dctime.Minute.ToString())) {
    Write-Host "Something went wrong"
    echo $dctime, $localtime
}else {
    return "Time-Sync seems to be working. Stopping execution..."
}

$TimeSettings = w32tm.exe /query /configuration
$w32tmParam = @()

try {
    if ($TimeSettings.GetValue(35) -ccontains "dc-01.in-klr.com") {
        Write-Host "DC-01 is configured!"
    } else {
        Write-Host "DC-01 is not Sync-Target! Added Parameter to correct this"
        $w32tmParam += '/manualpeerlist:"dc-01.in-klr.com"'
    }
    
}
catch {
    Write-Host 'Could not find the Value in the $TimeSettings-Variable'
    $w32tmParam += '/manualpeerlist:"dc-01.in-klr.com"'
}

switch ($w32tmParam) {
    $null {
        Write-Host "Parameters are empty - Attempting sync without reconfig..."
        w32tm.exe /resync
    }
    Default{
        Write-Host "Running Reconfig and Resync for DC-01"
        w32tm.exe /config $w32tmParam[0] /syncfromflags:manual /update | out-null
        sleep 2
        w32tm.exe /resync
    }
}