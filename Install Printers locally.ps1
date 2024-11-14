# Set overall default values
$printers = @{
    OG1 = "10.20.31.235"
    Personal = "10.20.31.234"
    EG = "10.20.31.233"
    OG2 = "10.20.31.236"
}

$DriverName = "HP Laserjet 500 color MFP M570 PCL6 Class Driver"
$Driver = Get-PrinterDriver | where Name -like $DriverName
$AddMode = $false

foreach ($printer in $printers.Keys) {

    # Check if ports are already installed, then if they are not, install them
    $PortCheck = (($printers[$printer].ToString())+"_")
    $Ports = Get-PrinterPort | where Name -match $PortCheck

    switch ($printer) {
        "OG1" {$PrinterBaseName = "KLR-OG1_"}
        "OG2" {$PrinterBaseName = "KLR-OG2_"}
        "EG" {$PrinterBaseName = "KLR-EG_"}
        "Personal" {$PrinterBaseName = "KLR-Personal_"}
        Default {
            return "
                Something went wrong with the Hashtable
                Exiting...
            "
        }
    }

    if (($null -eq $Ports) -or ($Ports.Count -ne 3)) {
        $AddMode = $true
        $PortNr = 1
        do {
            $PortName = (($printers[$printer].ToString())+"_$PortNr")
            if ($PortName -notin $ports.Name) {
                Add-PrinterPort -Name $PortName -PrinterHostAddress $printers[$printer] -ErrorAction SilentlyContinue
                Write-Host "Added Port $PortName
                "
            }
            $PortNr++
           } while (!($PortNr -ge 4)) 
           
    } else {
        $AddMode = $true
    }


    if ($AddMode){
        $PortName = (($printers[$printer].ToString())+"_$PortNr")
        $PortNr = 1
        do{
            # Set full printer name based on port
            $PortName = (($printers[$printer].ToString())+"_$PortNr")
            switch ($PortNr) {
                1 { $PrinterType = "Blanko" }
                2 { $PrinterType = "Blanko Duplex" }
                3 { $PrinterType = "Brief" }
                Default {return "
                Something went wrong with the port number
                Exiting...
                "}
            }
            $PrinterName = $PrinterBaseName+$PrinterType

            # Finally, add Printer to PC
            Add-Printer -PortName $PortName -DriverName $Driver.Name -Name $PrinterName
            if ($PrinterName -ccontains "Duplex") {
                Set-PrintConfiguration -DuplexingMode TwoSidedLongEdge -PrinterName $PrinterName 
            }
            Write-Host "Added Printer $PrinterName
            "
            $PortNr++
        }while (!(($PortNr -ge 4)))
        }
    }

