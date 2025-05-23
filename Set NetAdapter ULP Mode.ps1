$ULPProperty = Get-NetadapterAdvancedProperty -AllProperties | where DisplayName -like "*ULP*"

if ($ULPProperty.RegistryValue -ne 0) {
    Set-NetAdapterAdvancedProperty -RegistryKeyword $ULPProperty.RegistryKeyword -RegistryValue 0
    return "Successfully set value to 0"
}else {
    return "Not valid. Value is already 0"
}
    