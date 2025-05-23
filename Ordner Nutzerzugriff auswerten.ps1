$targetDepth = 0 #default value
#Uncomment if its desired to have custom folder depth:
#$targetDepth = Read-Host "Welche Verzeichnistiefe soll genutzt werden?"
$Folders = Get-ChildItem -Path "G:\" -Depth $targetDepth | where Attributes -like "*Directory*"

$CSVTemplate = 'C:\temp\Template Auswertung.csv'
$User = "IN-KLR\FHA" # Muss nach Bedarf abge�ndert werden
$kuerzel = $User.Replace("IN-KLR\","")
$UserAcc = Get-ADUser $kuerzel
$selectGroups = @()
$allGroups = Get-ADGroup -Filter *
$CSVPath = "C:\temp\$kuerzel Auswertung.csv"
$Delimiter = "`t"
$ErrorActionPreference = "SilentlyContinue"

#Start-Transcript -LiteralPath "C:\temp\G Auswertung.txt" -Force
Copy-Item -LiteralPath $CSVTemplate -Destination $CSVPath -Force
$CSV = Get-Item -LiteralPath $CSVPath


foreach($Group in $allGroups){
    $Members = Get-ADGroupMember -Identity $Group | select name
    if ($UserAcc.Name -in $Members.Name){
        $selectGroups += $Group.Name
    }
}

Write-Host "
Auswertung fuer: $User

Direkter Nutzerzugriff wird ausgewertet...
"

foreach($folder in $Folders){

        $acl = Get-Acl $folder.FullName

        foreach($aacl in $acl.Access){

        $IdentityReference = $aacl.IdentityReference
        $IdentityReference = $IdentityReference.ToString()
        $Content = Get-Content -LiteralPath $CSVPath -Encoding utf8

        if($kuerzel -eq ($IdentityReference.Replace("IN-KLR\",""))){
            $splitPath = ($folder.FullName.Split('\'))
            $depth = $splitPath.Count
            $allFieldCount = 6

            for ($i = 0; $i -lt $depth; $i++) {

                $pathDepth = 3-$i
                $pathDiff = $allFieldCount-3-$pathDepth
                if($i -eq 3){
                   $pathDiff = $pathDiff-1
                }
                $Output = $splitPath[$i]+($Delimiter*$i)+"X"+($Delimiter*$pathDiff)+($Delimiter*$pathDepth)+"X"
                <#switch ($i) {
                    0 { $Output = ""}
                    1 { $Output = $splitPath[$i]+($Delimiter*$i)+"X"+($Delimiter*3)+"X"}
                    2 { 
                    
                    }
                    Default {}
                }  #> 
            }

            if(($Output -notin $Content) -and ($folder -ne "G:")){
                $Output >> $CSV
                Write-Host $folder.Name " durch "  $IdentityReference
                
            }
    }}
    }

Write-Host "
Zugriffe über Nutzergruppen werden ausgewertet...
"

foreach($folder in $Folders){

        $acl = Get-Acl $folder.FullName

        foreach($aacl in $acl.Access){

        $IdentityReference = $aacl.IdentityReference
        $IdentityReference = $IdentityReference.ToString()
        $Content = Get-Content -LiteralPath $CSVPath -Encoding utf8

        if(($IdentityReference.Replace("IN-KLR\","")) -in $selectGroups){
            #$Output = $folder.Name+",,"+$IdentityReference 
            $splitPath = ($folder.FullName.Split('\'))
            $depth = $splitPath.Count
            $allFieldCount = 6

            for ($i = 0; $i -lt $depth; $i++) {

                $pathDepth = $depth-$i
                $pathDiff = $allFieldCount-3-$pathDepth
                if($i -eq 3){
                   $pathDiff = $pathDiff-1
                }else{
                    $pathDiff++
                }

                if($splitPath[$i]-eq "G:"){
                    #$Output = $splitPath[1]+($Delimiter*$i)+"X"+($Delimiter*$pathDiff)<#+($Delimiter*$pathDepth)#>+"X" 
                    continue
                }else{
                    $Output = $splitPath[$i]+($Delimiter*$i)+"X"+($Delimiter*$pathDiff)+($Delimiter*$pathDepth)+"X"+$Delimiter+$IdentityReference
                }
                <#switch ($i) {
                    0 { $Output = ""}
                    1 { $Output = $splitPath[$i]+($Delimiter*$i)+"X"+($Delimiter*3)+"X"}
                    2 { 
                    
                    }
                    Default {}
                }  #> 


            if(($Output -notin $Content) -and ($folder.Name -ne "G:")){
                $Output >> $CSV
                Write-Host $folder.Name " durch "  $IdentityReference
            }
            
         
        }
    }
}}

Write-Host "`n `n Eine Tabellen�bersicht kann hier: $CSVPath gefunden werden"

<# foreach ($entry in $test) {
    $IdRef = $entry.Access.IdentityReference
    if ("IN-KLR\MAH" -in $IdRef){
        Write-Host $entry.Path
    }
}
 #>


