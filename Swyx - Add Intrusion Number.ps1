$recipientList = "RNE", "CKT", "GOP", "SKN", "VPA"
$subjectList = "SGU"

Connect-IpPbx


$CollectionEntry = New-Object "SWCOnfigDataClientLib.Proxies.Users.UserIntrusionNumberEntry"
$subjectNumbers = @()
foreach ($recipient in $recipientList) {
        $recipientUser = Get-IpPbxUser -UserName $recipient
        $currSubjects = $recipientUser.UserIntrusionNumberEntryCollection
        foreach ($subject in $subjectList) {
                $su = Get-IpPbxUser -UserName $subject
                $suNumbers = $su.InternalNumberEntryCollection[0].InternalNumberID
                $subjectNumbers += $suNumbers
                
            }
        
        for ($i = 0; $i -lt $subjectNumbers; $i++) {
            if ($subjectNumbers[$i] -notin $currSubjects) {
                $CollectionEntry.UserID = $recipientUser.UserID
                $CollectionEntry.InternalNumberID = $subjectNumbers[$i]
                $recipientUser.UserIntrusionNumberEntryCollection.Add($CollectionEntry)
                Write-Host "added "($subjectNumbers[$i])" to "+$recipientUser.Name
            }else {
                continue
            }
        }
        }