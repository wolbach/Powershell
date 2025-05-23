$Folders = Get-ChildItem -Path "G:\" -Depth 0 | where Attributes -like "*Directory*"
$allGroups = Get-ADGroup -Filter * | where Name -eq "Marketing & Kommunikation"
$CSVPath = "C:\temp\Guppenauswertung.csv"
$Delimiter = "`t" # String escape für einen Tab

# Check if targetfile already exists
if ((Get-Item -Path $CSVPath -ErrorAction Continue)) {
    Remove-Item $CSVPath 
    New-Item $CSVPath
    "Ordner"+$Delimiter+"Gruppe" >> $CSVPath
}else {
    New-Item $CSVPath
    "Ordner"+$Delimiter+"Gruppe" >> $CSVPath
}

Write-Host "`n"$allGroups.Name " hat Zugriff auf:"
foreach ($Folder in $Folders) {
    $acl = Get-Acl $folder.FullName

        foreach($aacl in $acl.Access){

        $IdentityReference = $aacl.IdentityReference
        $IdentityReference = $IdentityReference.ToString()
        $Content = Get-Content -LiteralPath $CSVPath -Encoding utf8

        if(($IdentityReference.Replace("IN-KLR\","")) -in $allGroups.Name){
            #$Output = $folder.Name+",,"+$IdentityReference 
            $splitPath = ($folder.FullName.Split('\'))
            $depth = $splitPath.Count
            $allFieldCount = 6

            
                    $Output = $splitPath[4]+$Delimiter+$IdentityReference
           

            if(($Output -notin $Content) -and ($folder.Name -ne "G:")){
                $Output >> $CSVPath
                Write-Host $folder.Name 
            }
            
         
        }
    }
}#}


