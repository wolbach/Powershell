#$DBFolders = Get-ChildItem -Path "D:\SQL_DBs\" | select Name

$DBFolders = Get-Item -Path "D:\SQL_DBs\MSSQL15.SQL4TEST_DE" | select Name

foreach ($DBFolder in $DBFolders) {
    $DB = $DBFolder.Name.Replace("MSSQL15.", "")
    $SQLServerInstance = "SQL4TEST" + "\$DB"

    $RAMLimit_Max = "1024"
    $RAMLimit_Min = "384"
    $SetMaxRamLimitQuery = 
    "
        sp_configure 'max server memory', $RAMLimit_Max ;  
        RECONFIGURE;
    "
        $SetMinRamLimitQuery = 
    "
        sp_configure 'min server memory', $RAMLimit_Min ;  
        RECONFIGURE;
    "
    $GetMaxRamLimitQuery = 
    "
        SELECT value 
        FROM sys.configurations 
        WHERE name like 'max server memory%';
    "
    #$SQLInstance = "SQL4TEST\"+$service.Name.Replace("MSSQL$","")

    $currValue = Invoke-Sqlcmd -Query $GetMaxRamLimitQuery -ServerInstance $SQLServerInstance

    if ($currValue.value -gt $RAMLimit_Max) {
    $SetNewMinValue = Invoke-Sqlcmd -Query $SetMinRamLimitQuery -ServerInstance $SQLServerInstance
    $SetNewMaxValue = Invoke-Sqlcmd -Query $SetMaxRamLimitQuery -ServerInstance $SQLServerInstance
    }

    # Ab hier noch nicht fertiggestellt
    $StatusCheck = (
        ($currValue.HasErrors),
        ($SetNewMinValue.HasErrors),
        ($SetNewMaxValue.HasErrors)
    )
    if (-not $StatusCheck){
        continue
    } else {
        $MailBody = "
        Error Detected when configuring RAM Limit on SQL4TEST ($DBFolder):
        $SetNewValue
        "
        #Send-MailMessage -From "adminklr@in-software.com" -To "adminklr@in-software.com" -Body $MailBody -Subject "SQL4TEST Instance RAM Limit" -SmtpServer "Exchange-SRV"
    }

    }