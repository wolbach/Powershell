$trainersid = Get-Team | where DisplayName -eq "Trainers" | select GroupID
$Trainers = Get-MsolGroupMember -GroupObjectId $trainersid.GroupID.ToString() | select EmailAddress

$input = "FI Testerkurs1" #Read-Host "Gruppenname"
$Group = Get-Team | where DisplayName -eq $input | select GroupID
$groupies = Get-MsolGroupMember -GroupObjectId $Group.GroupID.ToString() | select EmailAddress

$comp = Compare-Object -ReferenceObject $groupies -DifferenceObject $Trainers -IncludeEqual

$count = 0
foreach ($com in $comp) {
    if ($com.SideIndicator -eq "==") {
        $count ++
    }   
}
$count2 = 0
foreach ($Traini in $Trainers) {
    $count2 ++
}
if ($count -ne $count2) {
    Write-Host -ForegroundColor Red "Ungleiche Anzahl von Trainern"
    exit
}

foreach ($com in $comp) {
    if ($com.SideIndicator -eq "<=") {
        <# $loeschnutzi = $com.InputObject
        $loeschnutzi -replace "@{EmailAddress=","" #>
        Write-Host "ye"
        #Remove-MsolUser -UserPrincipalName $com.InputObject.EmailAddress
    }else {
        Write-Host "nope"
    }
}
Get-MsolGroup | where DisplayName -eq $input
#Remove-MsolGroup -ObjectId 
 