function Get-ADSICustomerObjects {
        param (
                [Parameter(Mandatory=$true)]$customerNumber,
                [Parameter(Mandatory=$false)][string]$ObjectType
        )

        <#
        .SYNOPSIS
        returns list of objects by using the DirectoryServices-Class

        .DESCRIPTION
        Returns a list of objects assigned with a specific customer by using ADSISearcher (DirectoryServices) LDAP

        .PARAMETER customerNumber
        Customer-Number, as the oU is named - usually starting with a 1

        .PARAMETER ObjectType
        Specifies the Schema-Object type you want to be returned. If not given it defaults to "Computer"-Types

        .NOTES
        Author: Markus Hotz
        Version: 1.0
        Date: 29.10.2025
    #>

        if (!$ObjectType) {
                # if ObjectType is not set - do the default "Computers"
                $ObjectType = "Computer"
        }

        $ADsearcher = [adsisearcher]::new()
        
        # Set searchscope to look into whole subtree of given path
        $ADsearcher.SearchScope = 2

        $LDAPSearchString = "LDAP://OU=$($customerNumber),OU=Hosting,DC=domain,DC=local"
        $TargetObjectCategory = "CN=$($ObjectType),CN=Schema,CN=Configuration,DC=domain,DC=local" 
        $direntry = [System.DirectoryServices.DirectoryEntry]::new()
        $direntry.Path = $LDAPSearchString
        $ADsearcher.SearchRoot = $direntry
        #Set Filter to only return set Object-Types
        $ADsearcher.Filter = "(&(objectClass=*)(objectCategory=$($TargetObjectCategory)))"  

        # Find all Objects
        $ADComputers = $ADsearcher.FindAll() # defines all matching objects belonging to customer
        return $ADComputers

}
