$dAdminCred = Get-Credential -UserName "in-klr\Administrator" -Message "Enter Admin Password"
$SHSession = New-PSSession -ComputerName "termserv5.in-klr.com" -Credential $dAdminCred
$SHInvokeBlock = {Get-NetFirewallRule *}
$SHInvokeCmd = Invoke-Command -Session $SHSession -ScriptBlock $SHInvokeBlock 
$allRules = $SHInvokeCmd
$filteredSIDs = @()

foreach ($Rule in $allRules) {
    Write-Host $Rule
    if ($Rule.Owner -notin $filteredSIDs) {
        $filteredSIDs += $Rule.Owner
    }
}

$DCSession = New-PSSession -ComputerName "dc-01.in-klr.com" -Credential $dAdminCred


$DCInvokeBlock = {  
    Get-ADUser -Filter * | select SID, SamAccountName
}
$DCInvokeCmd = Invoke-Command -Session $DCSession -ScriptBlock $DCInvokeBlock 

$affectedAcc = @()

foreach ($User in $DCInvokeCmd) {
    Write-Host $User
    if ($User.SID -in $filteredSIDs) {
        $affectedAcc += $User.SamAccountName
    }
}

foreach ($Rule in $SHInvokeCmd) {
    while (($SHInvokeCmd | where Owner -eq $currSID).Count -gt 1) {
        <# $SHInvokeBlockDel = {Remove-NetFirewallRule $Rule.Name}
        $SHInvokeDelCmd = Invoke-Command -Session $SHSession -ScriptBlock $SHInvokeBlockDel #>
    }
}