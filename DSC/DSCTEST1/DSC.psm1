[DscResource()]
class Tailspin {

    [DscProperty(Key)] [TailspinScope]
    $ConfigurationScope

    [DscProperty()] [TailspinEnsure]
    $Ensure = [TailspinEnsure]::Present

    [DscProperty(Mandatory)] [bool]
    $UpdateAutomatically

    [DscProperty()] [int] [ValidateRange(1, 90)]
    $UpdateFrequency

    hidden [Tailspin] $CachedCurrentState
    hidden [PSCustomObject] $CachedData

    [Tailspin] Get(){
        $CurrentState = [Tailspin]::new()
        return $CurrentState
    }

    [bool] Test(){
        return $true
    }
    [void] Set(){}
}
enum TailspinScope {
    Machine
    User
}

#If $Ensure is specified as Present, the DSC Resource creates the item if it doesn't exist.
#If $Ensure is Absent, the DSC Resource deletes the item if it exists.
enum TailspinEnsure {
    Absent
    Present
}