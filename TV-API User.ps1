$doPOST = $null
$attributes = $null
$bodyPOST = $null
$bodyGET = $null

<#
TODO:
1. Hinzufügen zu einer Gruppe funktioniert wohl nur mit einer User-ID, die nicht per API zu bekommen ist
2. Gruppenfreigaben einstellen
3. Funktion "Serviceanfragen erhalten" soll deaktiviert sein wenn frisch erstellt
#>

class requestBody {

    [string]$email
    [string]$id
    [string]$name
    [string]$pass
    [string]$language
    [string]$permission

    requestBodyGET($email, $id, $name){
        $this.email = $email
        $this.id = $id
        $this.name = $name
    }
    requestBodyPOST($pass, $language, $permission){
        # Es ist eigentlich vorgesehen, dass erst eine Get-Abfrage gemacht wird, um einen duplizierten User auszuschließen, trotzdem zur Sicherheit:
        if ($null -in ($this.email, $this.name)) {
            Write-Host "Eine oder mehrere benötigten Attribute ist leer!"
            $attString = Read-Host "Bitte email und name angeben (,-separiert)"
            $attList = $attString.Split(",")

            $this.email = $attList[0]
            $this.name = $attList[1]
        }
        $this.pass = $pass
        $this.language = $language
        $this.permission = $permission
    }

}

$attributes = [requestBody]::new()
$token = "26929250-FwylR2p3w6EIJnvb8Qoo"
$usersURI = "https://webapi.teamviewer.com/api/v1/users"
$groupsURI = "https://webapi.teamviewer.com/api/v1/groups"
$usergroupsURI = "https://webapi.teamviewer.com/api/v1/usergroups"
$ProxyURI = "http://proxy-srv.in-klr.com:8081"
$userroleId = "60bd7bb6-191a-41da-8f5a-b28731a9e505"
$passwort = "in-mae5803)" # Hier ändern

$attributes.requestBodyGET("mae@in-software.com", $null, "Markus Ernst") # Hier ändern
$headers = @{ 
    Authorization = "Bearer $token"
}
$bodyGET = @{
    email = ($attributes.email)
}
$bodyPOST = @{}

$responseGET = Invoke-RestMethod -Uri $usersURI -Headers $headers -Method Get -Proxy $ProxyURI -Body $bodyGET
if ($responseGET.users.Count -eq 0) {
    while ($null -eq $doPOST) {
        $doPOST = Read-Host "Benutzer nicht gefunden - Soll ein neuer erstellt werden?(j/n)"
    }
    
    if ($doPOST -eq "j") {
        $attributes.requestBodyPOST($passwort, "de", $userroleId)
        $bodyPOST.Add("password",$attributes.pass)
        $bodyPOST.Add("language",$attributes.language)
        $bodyPOST.Add("userRoleId",$attributes.permission)
        $bodyPOST.Add("name",$attributes.name)
        $bodyPOST.Add("email",$attributes.email)
        $responsePOST = Invoke-RestMethod -Uri $usersURI -Headers $headers -Method Post -Proxy $ProxyURI -Body $bodyPOST
        Write-Host $responsePOST
    }
}else {
    Write-Host "Benutzer existiert bereits, beende Skript..."
}
