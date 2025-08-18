$recipientList = "RNE, CKT, GOP, SKN, VPA"

$recipientList = $recipientList.Split(",").Trim()
$subjectList = "SGU"

Connect-IpPbx


$CollectionEntry = New-Object "SWCOnfigDataClientLib.Proxies.Users.UserIntrusionNumberEntry"
$subjectNumbers = @()

foreach ($subject in $subjectList) {
                $su = Get-IpPbxUser -UserName $subject
                $suNumbers = $su.InternalNumberEntryCollection[0].InternalNumberID
                $subjectNumbers += $suNumbers
            }

foreach ($recipient in $recipientList) {
        $recipientUser = Get-IpPbxUser -UserName $recipient
        $currSubjects = $recipientUser.UserIntrusionNumberEntryCollection
        
        
        for ($i = 0; $i -lt $subjectNumbers.Count; $i++) {
            if ($subjectNumbers[$i] -notin $currSubjects) {
                
                $subjectInternalNumber = Get-IpPbxInternalNumber -InternalNumberId $subjectNumbers[$i] | select Number
                $recipientInternalNumber = $recipientUser.InternalNumberEntryCollection[0].Number

                $CollectionEntry.UserID = $recipientUser.UserID
                $CollectionEntry.InternalNumberID = $subjectNumbers[$i]
                $recipientUser.UserIntrusionNumberEntryCollection.Add($CollectionEntry)
                Update-IpPbxUser -UserEntry $recipientUser
                Write-Host "added "$subjectInternalNumber" to "$recipientInternalNumber
            }else {
                continue
            }
        }
        }