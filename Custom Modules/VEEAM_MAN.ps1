# Custom class definitions
class VeeamConnection {
    [string]$Hostname
    [pscredential]$Credentials
    [int]$Port

    Connect([string]$Server, [pscredential]$Credentials, [int]$Port){
        #Map Parameters to Attributes
        if ($Port -eq $null -or $Port -eq "") {
            $this.Port = 9392
        }else {
            $this.Port = $Port
        }
        $this.Hostname = $Server
        $this.Credentials = $Credentials

    }
}

# Functions of the module
$VeeamObj = $null
function New-VeeamConnection {
    param (
        [string]$Servername,
        [pscredential]$Credentials,
        [int]$Port
    )
    $VeeamObj = [VeeamConnection]::new()
    $VeeamObj.Connect($Servername,$Credentials,$Port)
    
}
function Get-VeeamCurrentConnection {
    return $VeeamObj
    
}