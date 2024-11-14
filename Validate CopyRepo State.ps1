function Start-SelfHeal {
    param (
        [array]$Directories,
        [json]$Machines
    )
    
    foreach ($Machine in $Machines) {
        if () {
            <# Action to perform if the condition is true #>
        }
    }
    $rs = New-PSSession $Machines

}

$machines = Get-Content '\\FILE-SRV\DATA\AdminKLR\IT20\Powershell Skripte\Veeam\backup-conf.json' -Raw | ConvertFrom-Json
$credentials = New-Object pscredential -ArgumentList "in-klr\administrator",(ConvertTo-SecureString "SLS500-928s" -Force -AsPlainText)
$fs = New-PSSession -ComputerName "FILE-SRV.in-klr.com" -Credential $credentials
$Direcs = {
    Get-ChildItem "F:\Backups" | select Name, FullName
}
$RepoDirectories = Invoke-Command -Session $fs -ScriptBlock $Direcs
[array]$results = $null

foreach ($Directory in $RepoDirectories) {
    # Remove the last 5 chars from the Directory Name so that duplicates can better be identified since they are most likely labeled "x 1" or "x 1_1"
    $rmcount = $Directory.Name.Length - 5
    $searchname = $Directory.Name.Remove($rmcount)

    <# $comp = Compare-Object -ReferenceObject $RepoDirectories.Name -DifferenceObject $searchname -IncludeEqual
    if (($comp.SideIndicator -eq "==").Count -ge 2) {
       Write-Host "The following backup has uncorrected chains:" $Directory
    } #>

    foreach ($Repo in $RepoDirectories) {
        if ($Repo.Name.Contains($searchname)) {
            $results += $Repo
        }
    }

    if (<# $results.Count -ge 2 -or #> $Directory.Name -match "FILE-SRV") {
        Write-Host $Directory.Name
        Start-SelfHeal -Directories $results
        return
    }
}
