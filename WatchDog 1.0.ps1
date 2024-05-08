function Export-Event {
    param (
        $EventEntry,
        $logfile,
        $CSV
    )
    
    switch ($EventEntry.ID) {
        4624 { 
            $Output = ($EventEntry.TimeCreated).ToString()+";"+$EventEntry.Id+";"+$EventEntry.MachineName+";"+$EventEntry.Properties[5].Value 
        }
        4656 {
            $Output = ($EventEntry.TimeCreated).ToString()+";"+$EventEntry.Id+";"+$EventEntry.Properties[6].Value+";"+$EventEntry.Properties[0].Value
        }
        Default { 
            ((Get-Date).ToString())+" Could not match Event ID - generating generic Entry" | Out-File $Logs -Encoding utf8
            $Output = (($EventEntry.TimeCreated).ToString()+""+$EventEntry.Id+";;")
        }
    }

    if ($Output -notin $Content) {        
        $Output | Out-File $CSV -Encoding utf8
        (Get-Date).ToString()+" Written events to $completePath" | Out-File $Logs -Encoding utf8
        return
    }else{
    return
    }
}

    $CSVPath = 'C:\Program Files\WatchDogLogs\'
    $CSVName = "watchdog.csv"
    $completepath =$CSVPath+$CSVName
    $exceptioncount = 0
    

while ($true) {
        
        try {

        if(!(Test-Path $CSVPath"Logs.txt")){
            $Logs = New-Item -Path $CSVPath -Name "Logs.txt" -ItemType File
            ((Get-Date).ToString())+" Created Logfile" | Out-File $Logs -Encoding utf8
        }else {
            $Logs = Get-Item $CSVPath"Logs.txt"
        }
        
        if (!(Test-Path $completepath)) {
            ((Get-Date).ToString())+" watchdog.csv not found - creating new file" | Out-File $Logs -Encoding utf8
            $CSV = New-Item -Path $CSVPath -Name "watchdog.csv" -ItemType File 
            "Time;ID;AffectedMachine;Username" | Out-File $CSV -Encoding utf8
        }
        
        $runtime = Get-Date
        $TimeDiff = $lastRun - $runtime
        if ($TimeDiff.Minutes -lt -10){ 
            $logons = Get-WinEvent -FilterHashtable @{LogName='Security';ID=4624} -ErrorAction SilentlyContinue | where TimeCreated -gt $lastRun 
            #only works wit auditing on
            #first enable auditing: https://community.spiceworks.com/t/detect-who-tried-to-modify-a-file-or-a-folder-on-your-windows-file-server/1012998
            #only works wit auditing on
            $fileaccess = Get-WinEvent -FilterHashtable @{LogName='Security';ID=4656} | where TimeCreated -gt $lastRun
            $lastRun = Get-Date #$runtime
            (Get-Date).ToString()+" Pulled events" | Out-File $Logs -Encoding utf8
            
        }
    
        foreach($logon in $logons){
            
            Export-Event -EventEntry $logon -logfile $Logs -CSV $completepath
            
            <# $Output = ($logon.TimeCreated).ToString()+";"+$logon.Id+";"+$logon.MachineName+";"+$logon.Properties[5].Value
            $Output | Out-File $completepath -Encoding utf8 #>
        }
    
        foreach($access in $fileaccess){
            Export-Event -EventEntry $access -logfile $Logs -CSV $completepath
            <#$Output = ($access.TimeCreated).ToString()+";"+$access.Id+";"+$access.Properties[6].Value+";"+$access.Properties[0].Value
            if($Output -notin (Get-Content -Path $completepath)){
                $Output | Out-File $completePath -Encoding utf8
                (Get-Date).ToString()+" Written events to $completePath" | Out-File $Logs -Encoding utf8
            } #>
        }
    
        if (((Get-Item $completepath | select length).Value -ge 40MB) -or ((Get-Item $Logs | select Length).Value -ge 40MB)) {
            $CreationTime = $CSV.CreationTime
            $dirDate = Get-Date $CreationTime -Format "yyyy_MM_dd-HH_mm"
            $targetPath = "C:\temp\watchdog-"+($dirDate.ToString())
    
            New-Item -Path $targetPath -ItemType Directory
            
            Move-Item $completepath -Destination $targetPath
            Move-Item $Logs -Destination $targetPath
        }
        <#$CSV = Get-Item -Path $completePath
    if ($csv.Length -gt 40000000) {
        #temp solution
        Move-Item -Path $CSV.FullName -Destination "D:\Internes\Markus"
        #>
        } catch {
            $exceptioncount++
            if ($exceptioncount -lt 3){
                (Get-Date).toString+" Execution failed - trying again (Count:$exceptioncount)" | Out-File $Logs -Encoding utf8
            } else {
                (Get-Date).toString+" Execution failed - Threshold met - Stopping self" | Out-File $Logs -Encoding utf8
                Stop-Process | where Name -CContains "WatchDog"
            }
        }
    }

    
    
    
    
    