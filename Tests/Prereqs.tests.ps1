Context "Azure Automation Prerequisites" -tag AzureAutomation {
    It "Az Powershell Module Installed" {
        Get-Module Az.Accounts -ListAvailable | Should -Not -BeNullOrEmpty
    }
    It "Terraform is installed" {
        Get-Command terraform | should -Not -BeNullOrEmpty
    }

}