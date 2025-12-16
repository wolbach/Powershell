class SQLServer {
    [string]$ServerName
    [string]$DatabaseName

    SQLServer([string]$serverName, [string]$databaseName) {
        $this.ServerName = $serverName
        $this.DatabaseName = $databaseName
    }

    class SQLStatement {
        [string]$ExecutionString

        [void] setExecutionString([string]$SQL){
            $this.ExecutionString = $SQL
        }
    }
}

function New-SqlCall {
    param (

    )

}
