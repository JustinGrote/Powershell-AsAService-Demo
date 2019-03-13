$SCRIPT:TerraformWorkingDir = "$BuildRoot\BuildOutput\terraform"
task Dependencies {
    if (-not (Get-Command -Name 'PSDepend\Invoke-PSDepend' -ErrorAction SilentlyContinue)) {
        #Force required by Azure Devops Pipelines, confirm false not good enough
        Write-Build Green 'PSDepend not detected - Installing from Powershell Gallery'
        Install-module -Name 'PSDepend' -Scope CurrentUser -Repository PSGallery -ErrorAction Stop -Force
    }

    #Install dependencies defined in Requirements.psd1
    Write-Build Green 'Build Initialization - Running PSDepend to Install Dependencies'
    Invoke-PSDepend -Install -Import -Path PowershellAsAService.requirements.psd1 -Confirm:$false
}

task TestAWS {
    $PesterResult = Invoke-Pester -PassThru -Script "$BuildRoot\Tests\AWSPrereqs.tests.ps1"
    if ($PesterResult.FailedCount -gt 0) {
        write-error "One or more Pester tests failed"
    }
}

task TestAzure {
    $PesterResult = Invoke-Pester -PassThru -Script "$BuildRoot\Tests\AzurePrereqs.tests.ps1"
    if ($PesterResult.FailedCount -gt 0) {
        write-error "One or more Pester tests failed"
    }
}


task TerraformWorkingDir {
    New-Item -Path $TerraformWorkingDir -Type Directory -Erroraction SilentlyContinue
}

function Invoke-Terraform ($terraformDir, $varfile) {
    write-host -fore green "$($Task.Name)`: Running Terraform for: $TerraformDir"
    $terraformDirName = (get-item $terraformDir).basename
    $terraformStatePath = "$terraformWorkingDir/$terraformDirName"
    New-Item -Path $terraformStatePath -Type Directory -Erroraction SilentlyContinue
    push-location $terraformStatePath
    & terraform init "$terraformdir"
    
    & terraform plan -out "$terraformDirName.tfplan" "$Terraformdir"
    & terraform apply --auto-approve "$terraformDirName.tfplan" 
    pop-location
}

task TerraformAzureAutomation TerraformWorkingDir,TestAzure,{
    Invoke-Terraform "$buildroot/terraform/azureAutomation"
}

task TerraformAzureFunction TerraformWorkingDir,TestAzure,{
    Invoke-Terraform "$buildroot/terraform/azureFunction"
}

task TerraformAzureFunctionRefresh {
    push-location $buildroot\buildoutput\terraform\azureFunction\
    terraform taint azurerm_function_app.this
    pop-location
},TerraformAzureFunction

task TerraformAWSLambda TerraformWorkingDir,TestAWS,{
    $lambdaZipPath = "$buildroot/BuildOutput/AWSLambdaExample.zip"
    $lambdaPackageInfo = New-AWSPowershellLambdaPackage -ScriptPath $buildroot/Examples/AWSLambdaExample.ps1 -OutputPackage $lambdaZipPath
    
    #Set inputs for AWSLambda Terraform
    $ENV:TF_VAR_aws_lambda_package_path = $lambdaPackageInfo.PathToPackage
    $ENV:TF_VAR_aws_lambda_handler = $lambdaPackageInfo.LambdaHandler

    #Run AWS Lambda Terraform
    Invoke-Terraform "$buildroot/terraform/awsLambda"
}

task PublishAWSLambda Test,{
    Publish-AWSPowerShellLambda -Name "PowershellAsAServiceExample" -ScriptPath $BuildRoot\Examples\AWSLambdaExample.ps1 -Region 'us-west-2' -DisableInteractive
}

task Destroy {
    write-host -fore Red "HERE THERE BE DRAGONS. THIS WILL DESTROY EVERYTHING CREATED BY TERRAFORM!  You should use terraform destroy individually in each folder and confirm unless you know what you are doing."
    $destroyConfirm = read-host "Type BURNITDOWN and enter to continue, anything else aborts"
    if ($destroyConfirm -eq 'BURNITDOWN') {
        Get-Childitem -ErrorAction silentlycontinue -Directory "$BuildRoot\BuildOutput\terraform" | foreach {
            write-host -fore cyan "Destroying $($PSItem.Name)"
            Push-Location $PSItem.fullname
            terraform destroy --auto-approve
            Pop-Location
        }
    }
}

task Test TestAzure,TestAWS
task Terraform TerraformAzureFunction,TerraformAzureAutomation,TerraformAWSLambda

task . Dependencies,Test,Terraform