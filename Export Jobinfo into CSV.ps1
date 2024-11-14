$Jobs = Get-VBRBackup
$PCName = $env:COMPUTERNAME
$timeframeStart = Get-Date -Date "31/12/2023"
$timeframeEnd = Get-Date -Date "31/07/2024"
$session = Get-VBRBackupSession
$count = 0
$CSVPath = $env:HOMEDRIVE+"\temp\"
$CSVName = "Backups.csv"

$lastRun = Get-Item -Path "C:\temp\Backups.csv"

if ($lastRun -ne $null) {
    #$timeframeStart = $lastRun.CreationTimeUtc.Date
    Remove-Item $lastRun   
}
"JobName;Status;TransferredSize;RunTime;StartTime" >> $CSVPath$CSVName

#do{
 #   $currentJob = $Jobs[$count]
    switch ($Jobs[1].BackupPlatform.Platform){
        "SelectedFiles" {
            
            foreach($currentJobSess in $session){
            #echo $currentJob.ID
            #echo $currentJobSess.JobId
                if( ($currentJobSess.JobId -eq $currentJob.ID) -and ($currentJobSess.CreationTime -ge $timeframeStart)){
                    Write-Host $currentJobSess.Id
                    $TaskSess = Get-VBRTaskSession -Session $currentJobSess 
                    $TransferSize = $TaskSess.JobSess.Progress.TransferredSize
                    $TransferSizeconvert = [math]::Round($TransferSize/1GB,2)
                    $backupTime = ($TaskSess.JobSess.CreationTime - $TaskSess.JobSess.EndTime).TotalMinutes * -1
                    $TaskSess.JobName.ToString()+";"+$TaskSess.JobSess.Result.ToString()+";"+$TransferSizeconvert+";"+$backupTime.ToString()+";"+$TaskSess.JobSess.CreationTime.ToString() >> $CSVPath$CSVName
                }
            }

        }
        "EHyperV" {
            Write-Host "Type correct"
            foreach($currentJobSess in ($session | sort Name)){
                if( <#($currentJobSess.SessionInfo.PolicyTag -or $currentJob.JobId -in $currentJobSess.SessionInfo.JobId) -and#> ($currentJobSess.CreationTimeUTC -ge $timeframeStart)){
                    Write-Host $currentJobSess.SessionInfo.JobName
                    $TransferSize = $currentJobSess.SessionInfo.Progress.TransferedSize
                    $TransferSizeconvert = [math]::Round($TransferSize/1GB,2)
                    $backupTime = ($currentJobSess.SessionInfo.CreationTime - $currentJobSess.SessionInfo.EndTime).TotalMinutes * -1
                    $currentJobSess.SessionInfo.JobName.ToString()+";"+$currentJobSess.SessionInfo.Result.ToString()+";"+$TransferSizeconvert+";"+$backupTime.ToString()+";"+$currentJobSess.SessionInfo.CreationTime.ToString() >> $CSVPath$CSVName
                    
                }
            }

        }
    }


  #  $count++
#}while($count -le ($Jobs.Count - 1))