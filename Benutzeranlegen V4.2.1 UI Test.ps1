$lizan = 1
$actions = @()

$actions += New-Object PSObject -Property @{
    name = "Connect MsolServices"
    function = {
    try {
        Connect-MsolService
        Connect-MicrosoftTeams
    }
    catch {
        { $textBlock2.AddText(" - Verbindung fehlgeschlagen") }
    }
}
}

[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = @"
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        
        Title="Benutzeranlegen V4.2.1" Height="450" Width="800">
    <Grid>
        <TextBlock Name="textBlock" HorizontalAlignment="Left" Height="23" Margin="10,10,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="770" Text=""/>
        <Button Name="button" Content="Run" HorizontalAlignment="Left" Height="24" Margin="693,379,0,0" VerticalAlignment="Top" Width="71"/>
        <Button Name="button1" Content="Cancel" HorizontalAlignment="Left" Height="24" Margin="606,379,0,0" VerticalAlignment="Top" Width="68"/>
        <TextBlock Name="textBlock2" HorizontalAlignment="Left" Height="23" Margin="10,38,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="390" Text=""/>

    </Grid>
</Window>
"@
#Read XAML
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader"; exit}
# Store Form Objects In PowerShell
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}

$textBlock.AddText( "Bitte prüfen, ob genug Basic / Standard / Teams Lizenzen frei sind! Es werden mindestens $lizan Lizenzen benötigt!" )
$textBlock2.AddText( "training.lug-ag.de MS365 Admin eingeben (Separates Fenster)" )

$button1.Add_Click({
    $Form.Close()
})


$actions_ht = @{}

foreach ($a in $actions){
    $actions_ht.Add($a.name, $a)

    $button.Add_Click({
        $a
    })
}

$Form.ShowDialog() | out-null
# Skript



# Funktionen
