Context "Azure Prerequisites" -tag AzureAutomation {
    It "In Powershell Core" {
        $IsCoreCLR | Should -Be $true
    }
    It "Az.Accounts Powershell Module Installed" {
        Get-Module Az.Accounts -ListAvailable | Should -Not -BeNullOrEmpty
    }
    It "Azure CLI Installed" {
        command az | Should -Not -BeNullOrEmpty
    }
    It "Azure CLI Logged into Azure" {
        az account show | Should -Not -BeNullOrEmpty
    }
    It "Terraform is installed" {
        Get-Command terraform | should -Not -BeNullOrEmpty
    }
}