if(-not(Get-Module activedirectory)){
    Import-Module activedirectory
}
try {
    Get-Package itext7
}
catch {
    # Normal install with Dependencies wont work
    Install-Package itext7 -SkipDependencies
    Install-Package itext7.common -SkipDependencies
}

$Standorte=  @{
    "Stein" = @{
        "Straße" = "Gutenbergstraße 13"
        "PLZ" = "75203"
        "Ort" = "Königsbach-Stein"
        "BLand" = "BW"
    }
    "Pforzheim" = @{
        "Straße" = "Am hohen Markstein 5"
        "PLZ" = "75177"
        "Ort" = "Pforzheim"
        "BLand" = "BW"
    }
}

function convert-PDFtoText {
	param(
		[Parameter(Mandatory=$true)][string]$file
	)	
    $Userdata_JSON = $null

    $all_values = @{}

    $file = "C:\Users\hotz\Documents\PowerShell\Umlaufblatt Personalabteilung v0.4.pdf"
	Add-Type -Path "C:\Program Files\PackageManagement\NuGet\Packages\itext7.8.0.0\lib\net461\itext.forms.dll"
    Add-Type -Path "C:\Program Files\PackageManagement\NuGet\Packages\itext7.8.0.0\lib\net461\itext.kernel.dll"

	$pdf = [iText.Kernel.Pdf.PdfReader]::new($file)
    $pdf.SetUnethicalReading($true)
    $pdfdoc = [iText.Kernel.Pdf.PdfDocument]::new($pdf)
    $form = [iText.Forms.PdfAcroForm]::GetAcroForm($pdfdoc, $true)

    $all_values.Add("Vorname", $form.GetField("te_Vorname").GetValue())
    $all_values.Add("Name", $form.GetField("te_Name").GetValue())
    $all_values.Add("Abteilung", $form.GetField("d_Abteilung").GetValue())
    $all_values.Add("Kostenstelle", $form.GetField("te_Kostenstelle").GetValue())
    $all_values.Add("Vorgesetzter", $form.GetField("te_Vorgesetzter").GetValue())
    $all_values.Add("Personalnummer", $form.GetField("te_PersonalNr").GetValue())
    $all_values.Add("RefUser", $form.GetField("te_Referenzuser").GetValue())
    $all_values.Add("Rolle", $form.GetField("te_Funktion").GetValue())

    $pdf.Close()
    $pdfdoc.Close()
    return $all_values
}

function Create-User {
    param (
        $ReferenceUser,
        $Surname,
        $GivenName,
        $Title,
        $ID
    )

    if ($Title.contains("W2")) {
        $Office = $Standorte.Pforzheim
    } else {
        $Office = $Standorte.Stein
    }
    $Surname = $Surname+"d"

    # Initialpasswort zu Secure String konvertieren, da sonst nicht nutzbar
    $pw = "Felsomat123$"
    ConvertTo-SecureString -String $pw -AsPlainText -Force

    # Überschreiben von $ReferenceUser mit dem entsprechenden AD-Nutzer
    $ReferenceUser = Get-ADUser $ReferenceUser -Properties *
    $Path = $ReferenceUser.DistinguishedName -replace '^CN=.+?(?<!\\),'
    $Path.Trim()

    Write-Host $Path

    New-ADUser -DisplayName $Surname -Path $Path -SamAccountName $Surname -StreetAddress $Office.Straße -City $office.Ort -State $Office.BLand -PostalCode $Office.PLZ -Department $Title -Title $ReferenceUser.Title -Manager $ReferenceUser.Manager -Name $Surname -GivenName $Surname -Country "Germany" -UserPrincipalName $Surname+"@felsomat.de" -HomePage "www.felsomat.de" -employeeNumber $ID

    $user = Get-ADUser $Name

    foreach($group in $ReferenceUser.MemberOf){
        Add-ADGroupMember -Identity $group -Members $user
    }
    
}

function Change-User {
    param (
        $AccName,
        $ID,
        $ReferenceUser
    )

    $user = Get-Aduser $AccName -Properties employeeNumber, Title, MemberOf
    $refuser = Get-ADUSer $ReferenceUser -Properties Title, MemberOf

    if ($ID -ne $user.employeeNumber) {
        Set-ADuser $user -employeeNumber $ID
    }
    if ($refuser.Title -ne $user.Title) {
        Set-ADUSer $user -Title $refuser.Title
    }

    foreach ($group in $user.MemberOf) {
        Remove-ADGroupMember $group -Members $user
    }
    foreach ($group in $ReferenceUser.MemberOf) {
        Add-ADGroupMember $group -Members $user
    }
    
}

function Delete-User {
    param (
        $Name,
        $Personsalnr,
        $Austrittsdatum
    )
    
    $user = Get-ADUser $Name

    Set-ADUser $user -AccountExpirationDate $Austrittsdatum -

}

$CSVPath = "C:\users\hotz\Documents\"
$CSV = Import-Csv -Delimiter ";" -LiteralPath $CSVPath"Personal.csv"

$type = Read-Host "(Ä)nderung oder (E)intritt?"

switch ($type) {
    "ä" {  
        Change-User -AccName $CSV.Nachname -ID $CSV.Personalnummer -ReferenceUser $csv.RefNutzer 
    }
    "e" { 
        Create-User -ReferenceUser $CSV.RefNutzer -Surname $CSV.Nachname -Title $CSV.Position -ID $CSV.Personalnummer -GivenName $CSV.Vorname 
    }
    "a" {  
        $Austritt = Read-Host "Datum eingeben (Format DD/MM/YYYY): "  
        Delete-User -Name $CSV.Nachname -Personsalnr $CSV.Personalnummer -Austrittsdatum $Austritt
    }
    Default {}
}
