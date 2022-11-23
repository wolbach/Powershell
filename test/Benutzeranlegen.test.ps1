Describe -Name "Benutzeranlegen"{
    <# Mock New-VMMRole

    It "Test New-VMMRole"{
        New-VMMRole | Should -Be 1
    } #>

    #Mock Generate-Password

    Context "Functions"{


    Mock Generate-Password
    It "Test Passwort Generator"{
        Generate-Password | Should -BeOfType System.Security.SecureString
    }
}
}
