function Validate-VBRBackup {
param (
    [PArameter(Position=0,mandatory=$true)]
    [string]$JobName,
    [PArameter(Position=1,mandatory=$false)]
    [int32]$RunMode,
    [PArameter(Position=0,mandatory=$false)]
    [string]$SearchDirectory
    )
    
    <#
        .DESCRIPTION
        Will Run the Backup Validator included in a Veeam Backup & Replication Installation for troubleshooting purposes

        .PARAMETER JobName
            Must be a String; defines the name of the job to be evaluated
        .PARAMETER RunMode 
            Must be an Integer; defines if the RunMode is File or Job based
                    1 = Default; Job-Based
                    2 = File-Based
        .PARAMETER SearchDirectory 
            Only necessary if the RunMode is set to File-Based
    #>

    switch ($RunMode) {
        2 { & $ValidatorPath$ValidatorEXE /backup:$JobName }
        Default {}
    }

    $ValidatorPath = 'C:\Program Files\Veeam\Backup and Replication\Backup\'
    $ValidatorEXE = "Veeam.Backup.Validator.exe"

    if(-not(Test-Path -LiteralPath $ValidatorPath)){
        return "Ist Veeam installiert? der Pfad $ValidatorPath konnte nicht gefunden werden"
    }

    
}