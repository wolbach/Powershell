Import-Module failoverclusters

## Versionen
## 0.0.1 Grundlegende Funktionen schreiben
## 0.0.5 Dateifindung funktional gemacht
## 0.0.6 Umsetzen der Funktion "Get-ResultFile"

## TODO
## Abfragen von Cluster- bzw. Nodenamen, 
## Umschreiben von Get-ClusterValidationResult um ganze Einträge sehen zu können
## Export von Get-ClusterValidation in eine CSV
## Weg finden, um InnerText/InnerXml aus $Test in ein Textdokument einzufügen und diese mit einer Funktion zu formatieren

#Variablen
$List = Get-ChildItem -Path 'C:\Users\marku\OneDrive\PS Gedöhnse' -Filter Validierungsbericht*.xml
#C:\Users\adminmh\AppData\Local\Temp\3\ 
$cluster = Get-Cluster lgka-clu001 -Domain lg.local 
$fname
$clustertest = Read-Host "Neuen Test beginnen? y/n"


if ($clustertest -eq "y"){
    $clustertest = Test-Cluster -Cluster $cluster -Node lgka-hv006
    $xmldoc = Import-Clixml $clustertest.Name
    $fname = $clustertest.Name 
} elseif ($clustertest -ne "y") {
    Get-ResultFile
}



# Funktionen

# Suche nach bereits vorhandenem XML-Bericht
function Get-ResultFile {
    do {
        $yn = "n"
        $Eintraege = @()
        foreach ($Listi in $List) {
            $Eintraege += $Listi.Name
        }
        $entscheidung = Read-Host "Welchen der Einträge öffnen? (Start bei 0)"
        $yn = Read-Host "Ist "$Eintraege[$entscheidung]" richtig? y/n"
    } while ($yn -ne "y")
    if ($yn = "y") {
        $fname = $Eintraege[$entscheidung]
        return $fname
    }
}

#Filtern in der XML-Datei
function Get-ClusterValidationResult
{
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Failed','Warnung','Erfolgreich','Not Applicable', 'Cancelled')]
        [String]
        $Status
    )

    $validationFile = (Get-ChildItem 'C:\Users\marku\OneDrive\PS Gedöhnse' -Filter $fname | Select-Object -First 1).FullName
    #C:\Users\adminmh\AppData\Local\Temp\3\ 
    if ([string]::IsNullOrEmpty("$validationFile")) {
        throw "Keine Datei gefunden"
    }
    $Path = "/Table/Message"
    $results = Select-Xml -Path $validationFile -XPath $Path | ForEach-Object {$_.Node.InnerXml}
    #Where-Object { $_.Node.Value."#cdata-section" -eq $Status }
    return $results.Count
}

$Warning = Get-ClusterValidationResult -Status 'Warning'
$Err = Get-ClusterValidationResult -Status 'Failed'
 
Write-Host $Warning

[xml]$Test = Get-Content -Path 'C:\Users\marku\OneDrive\PS Gedöhnse\Validierungsbericht 2022.02.21 At 12.02.21.xml'
Export-Csv -InputObject $Test.InnerXml.Replace(">",";") -Path 'C:\Users\marku\OneDrive\PS Gedöhnse\Test.csv'

$Test.InnerXml.Replace("<",";") | Out-File "C:\Users\marku\OneDrive\PS Gedöhnse\Testi.csv" -Encoding xml
$Test.InnerXml | Out-File "C:\Users\marku\OneDrive\PS Gedöhnse\Testi.csv" -Encoding utf8

