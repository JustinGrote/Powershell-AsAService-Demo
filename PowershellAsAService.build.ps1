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

task Test {
    Invoke-Pester
}

task TerraformWorkingDir {
    New-Item -Path $TerraformWorkingDir -Type Directory -Erroraction SilentlyContinue
}

function Invoke-Terraform ($terraformDir) {
    write-host -fore green "$($Task.Name)`: Running Terraform for: $TerraformDir"
    $terraformDirName = (get-item $terraformDir).basename
    $terraformStatePath = "$terraformWorkingDir/$terraformDirName"
    New-Item -Path $terraformStatePath -Type Directory -Erroraction SilentlyContinue
    push-location $terraformStatePath
    terraform init "$terraformdir"
    terraform plan -out "$terraformDirName.tfplan" "$Terraformdir"
    terraform apply --auto-approve "$terraformDirName.tfplan" 
    pop-location
}

task TerraformAzureAutomation TerraformWorkingDir,{
    Invoke-Terraform "$buildroot/terraform/azureAutomation"
}

task TerraformAzureFunction TerraformWorkingDir,{
    Invoke-Terraform "$buildroot/terraform/azureFunction"
}

task PublishAWSLambda {
    Publish-AWSPowerShellLambda -Name "PowershellAsAService-Example" -ScriptPath $BuildRoot\Examples\AWSLambdaExample.ps1 -Region 'us-west-2' -DisableInteractive
}

task . Dependencies,Test,PublishAWSLambda