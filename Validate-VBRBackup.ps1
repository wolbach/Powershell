function Validate-VBRBackup {
param (
    [PArameter(Position=0,mandatory=$true)]
    [string]$JobName,
    [PArameter(Position=1,mandatory=$false)]
    [switch]$file_based,
    [PArameter(Position=0,mandatory=$false)]
    [string]$SearchDirectory
    )
    
    <#
        .DESCRIPTION
        Will Run the Backup Validator included in a Veeam Backup & Replication Installation for troubleshooting purposes

        Parameters:
        JobName = Must be a String; defines the name of the job to be evaluated
        file_based = Must be a boolean; defines if the file_based is File or Job based
                    false = Default; Job-Based
                    true = file_based
        SearchDirectory = Only necessary if the file_based is set to file_based
    #>

    switch ($file_based) {
        $false { 
            $ValidatorPath = 'C:\Program Files\Veeam\Backup and Replication\Backup\'
            $ValidatorEXE = "Veeam.Backup.Validator.exe"

            if(-not(Test-Path -LiteralPath $ValidatorPath)){
                return "Ist Veeam installiert? der Pfad $ValidatorPath konnte nicht gefunden werden"
            }

            & $ValidatorPath$ValidatorEXE /backup:$JobName
         }
         $true {
            if (!(Test-Path $SearchDirectory)) {
                Write-Error -Exception "FilePath Exception" -Category ObjectNotFound -Message "Directory with Path $SearchDirectory could not be found"
                return
            }else {
                $AllItems = Get-ChildItem -LiteralPath $SearchDirectory
                for ($i = 0; $i -lt $AllItems.Count; $i++) {
                    Write-Host "($i) "$AllItems[$i]

                    
                } 
                $ItemSelection = Read-Host "Which file is to be checked?"
                    
                # Put Validation of $ItemSelection here
                return $AllItems[$ItemSelection]
            }
            

         }
        Default {return "Something has went wrong with file_based"}
    }
    
}