$Folders = Get-ChildItem -Path "G:\"
$User = "IN-KLR\DE" # Muss nach Bedarf abgeändert werden
$UserAcc = Get-ADUser ($User.Replace("IN-KLR\","")) 
$selectGroups = @()

# TODO: auch in Unterordnern nach Berechtigung suchen; Aktuell werden diese garnicht angezeigt

Start-Transcript -LiteralPath "C:\temp\G Auswertung.txt" -Force

foreach($Group in $allGroups){
    $Members = Get-ADGroupMember -Identity $Group | select name
    if ($UserAcc.Name -in $Members.Name){
        $selectGroups += $Group.Name
    }
}

Write-Host "
Auswertung für: $User

Direkter Nutzerzugriff wird ausgewertet...
"

foreach($folder in $Folders){

    $fullPath = $Folders.DirectoryName[0] +":\"+ $folder.Name

        $acl = Get-Acl $fullPath

        foreach($aacl in $acl.Access){

        if($aacl.IdentityReference -eq $User){
            Write-Host $folder.Name
            break
        }
    }
}

Write-Host "
Zugriffe über Nutzergruppen werden ausgewertet...
"

foreach($folder in $Folders){

    $fullPath = $Folders.DirectoryName[0] +":\"+ $folder.Name

        $acl = Get-Acl $fullPath

        foreach($aacl in $acl.Access){

        $IdentitytReference = $aacl.IdentityReference
        $IdentitytReference = $IdentitytReference.ToString()

        if(($IdentitytReference.Replace("IN-KLR\","")) -in $selectGroups){
            Write-Host $folder.Name " durch "  $IdentitytReference
            break
        }
    }
}

Stop-Transcript

