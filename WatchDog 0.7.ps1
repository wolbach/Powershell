while ((Get-Service EventLog).Status -eq "Running") {


$CSVPath = 'C:\Program Files\WatchDogLogs\'
$CSVName = "watchdog.csv"
$completepath =$CSVPath+$CSVName

    
    if(!(Test-Path $CSVPath"Logs.txt")){
        $Logs = New-Item -Path $CSVPath -Name "Logs.txt" -ItemType File
        ((Get-Date).ToString())+" Created Logfile" >> $Logs
    }else {
        $Logs = Get-Item $CSVPath"Logs.txt"
    }
    
    if (!(Test-Path $completepath)) {
        ((Get-Date).ToString())+" watchdog.csv not found - creating new file" >> $Logs
        $CSV = New-Item -Path $CSVPath -Name "watchdog.csv" -ItemType File 
        "Time;ID;AffectedMachine;Username" | Out-File $CSV -Encoding utf8
    }
    
    
    $runtime = Get-Date
    $TimeDiff = $lastRun - $runtime
    if ($TimeDiff.Minutes -lt -10){ 
        $logons = Get-WinEvent -FilterHashtable @{LogName='Security';ID=4624} | where TimeCreated -gt $lastRun
        #only works wit auditing on
        #first enable auditing: https://community.spiceworks.com/t/detect-who-tried-to-modify-a-file-or-a-folder-on-your-windows-file-server/1012998
        #$fileaccess = Get-WinEvent -FilterHashtable @{LogName='Security';ID=4656} | where TimeCreated -gt $lastRun
        $lastRun = $runtime
        (Get-Date).ToString()+" Pulled events" >> $Logs
    }

    foreach($logon in $logons){
        $Output = ($logon.TimeCreated).ToString()+";"+$logon.Id+";"+$logon.MachineName+";"+$logon.Properties[5].Value
        $Output | Out-File $completepath -Encoding utf8
    }

    if ($null -ne $fileaccess) {
        foreach($access in $fileaccess){
            $Output = ($access.TimeCreated).ToString()+";"+$access.Id+";"+$access.Properties[5].Value+";"+$logon.Properties[0].Value
            $Output | Out-File $completepath -Encoding utf8
        }
    }

    (Get-Date).ToString()+" Written events to $completePath" >> $Logs

    if (((Get-File $completepath | select length) -ge 40MB) -or ((Get-Item $Logs | select Length) -ge 40MB)) {
        $CreationTime = $CSV.CreationTime
        $dirDate = Get-Date $CreationTime -Format "yyyy_MM_dd-HH_mm"
        $targetPath = "C:\temp\watchdog-"+($dirDate.ToString())

        New-Item -Path $targetPath -ItemType Directory
        
        Move-Item $completepath -Destination $targetPath
        Move-Item $Logs -Destination $targetPath
    }

}


