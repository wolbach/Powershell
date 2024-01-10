function Replace-ExcelDots {
    param (
        [Parameter(Mandatory=$true)]
        [string]$File,
        [Parameter(Mandatory=$false)]
        [boolean]$TableMode=$false
    )

    if($TableMode){
        $TableName = Read-Host "Please enter name of table"
        $Workbook = Import-XLSX -Path $File -Sheet $TableName
    }else{
        $Workbook = Import-Excel -Path $File
    }
}

do{

    try {
        $filename = Read-Host "Please input name of the file"

        if (".xlsx" -notin $filename) {
            $filename = $filename+".xlsx"
        }

        $Drives = Get-PSDrive | where Root -Like *":\"
    
        foreach($Drive in $Drives){
            $DriveFolders = Get-ChildItem -Path $Drive.Root

                do{
                    <#
                    $Path is bad naming scheme
                    figure out way to not overwrite $filepath because of next drive in foreach
                    
                    #>
                if (!(($Path.Name -eq "Program Files") -or ($Path.Name -eq "Program Files (x86)") -or ($Path.Name -eq "Windows"))) {
                    $filepath = Get-ChildItem -Path $Drive.Root -Exclude *.docx,*mp3,*.jpg,*.png,*.pptx,*.accdb,*.ps1,*.txt,*.dll -Recurse -Depth 5 -Name $filename
                    $filepath = $Drive.Root+$filepath
                }
                }while ($filepath -notcontains $filename)
        }
    
    }
    catch {
        $filepath = $null
        Write-Host "Something went wrong = please check filename"
    }

}while(($null -eq $filepath) -or ($filepath -notcontains $filename))

if(Import-Module PSExcel){
    continue
}else{
    return "Loading Module 'PSExcel' failed: Is it installed?"
}

$utilitySelect = Read-Host "
Please choose one of these modes:
1) change out '.' with a comma
"

switch ($utilitySelect) {
    1 { $runMode = [scriptblock]{Replace-ExcelDots -File $filepath} }
    Default {}
}

Invoke-Command -ScriptBlock $runMode