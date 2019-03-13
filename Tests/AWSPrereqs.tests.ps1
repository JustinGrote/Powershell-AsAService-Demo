Context "AWS Lambda Prerequisites" -tag AwsLambda {
    It "In Powershell Core" {
        $IsCoreCLR | Should -Be $true
    }
    It "Terraform is installed" {
        Get-Command terraform | Should -Not -BeNullOrEmpty
    }
    It "AWS_ACCESS_KEY_ID has been set" {
        $env:AWS_ACCESS_KEY_ID | Should -Not -BeNullOrEmpty
    }
    It "AWS_SECRET_ACCESS_KEY has been set" {
        $env:AWS_SECRET_ACCESS_KEY | Should -Not -BeNullOrEmpty
    }
    It "AWS Lambda Powershell Module is installed" {
        Get-Module AWSLambdaPSCore -Listavailable | Should -Not -BeNullOrEmpty
    }
}