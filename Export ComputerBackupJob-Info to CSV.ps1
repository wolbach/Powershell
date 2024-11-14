$jobs = Get-VBRComputerBackupJob

$PCName = $env:COMPUTERNAME
$timeframeStart = Get-Date -Date "31/12/2023"
$timeframeEnd = Get-Date -Date "31/05/2024"
$taskSessions = @()
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
    #$currentJob = $Jobs[$count]
    
    #if ($currentJob.IsBackupCopy){
        #"SelectedFiles" {
            
            
            foreach ($job in $jobs) {
            $sessions = Get-VBRComputerBackupJobSession | where {$_.JobId -eq $job.Id}
            
            foreach ($session in $sessions) {
                   $tasks = Get-VBRTaskSession -Session $session
                   $taskSessions += $tasks
            }
            $taskSessions += Get-VBRBackupSession
            foreach($TaskSess in $taskSessions){
                

            
            #echo $currentJob.ID
            #echo $currentJobSess.JobId
                
                    Write-Host $currentJobSess.Id
                    
                    $TransferSize = $TaskSess.Info.Progress.TransferedSize
                    $TransferSizeconvert = [math]::Round($TransferSize/1GB,2)
                    
                    if( $TaskSess.GetType().Name -eq "CBackupCopySession"){
                    echo $true
                        $backupTime = $TaskSess.WorkDetails.WorkDuration.TotalMinutes
                        $TaskSess.JobName.ToString()+";"+$TaskSess.Result.ToString()+";"+$TransferSizeconvert+";"+$backupTime.ToString()+";"+$TaskSess.SessionInfo.CreationTime.ToString() >> $CSVPath$CSVName
                    }else{
                        $backupTime = ($TaskSess.JobSess.CreationTime - $TaskSess.JobSess.EndTime).TotalMinutes * -1
                        $TaskSess.JobName.ToString()+";"+$TaskSess.JobSess.Result.ToString()+";"+$TransferSizeconvert+";"+$backupTime.ToString()+";"+$TaskSess.JobSess.CreationTime.ToString() >> $CSVPath$CSVName
                    }
            }
            }
       
        <#$true 
            Write-Host $currentJob
            foreach($currentJobSess in $session){
                
                if( ( $currentJob.Name -in $currentJobSess.JobName) -and ($currentJobSess.CreationTimeUTC -ge $timeframeStart)){
                    Write-Host $currentJobSess.SessionInfo.JobName
                    $TransferSize = $currentJobSess.SessionInfo.Progress.TransferedSize
                    $TransferSizeconvert = [math]::Round($TransferSize/1GB,2)
                    $backupTime = ($currentJobSess.SessionInfo.CreationTime - $currentJobSess.SessionInfo.EndTime).TotalMinutes * -1
                    $currentJobSess.SessionInfo.JobName.ToString()+";"+$currentJobSess.SessionInfo.Result.ToString()+";"+$TransferSizeconvert+";"+$backupTime.ToString()+";"+$currentJobSess.SessionInfo.CreationTime.ToString() >> $CSVPath$CSVName
                }
            }
            }#>
            #}$currentJobSess.SessionInfo.JobId -eq $currentJob.ID
<#
        }
    }


    $count++
}while($count -lt $Jobs.Count)#>
