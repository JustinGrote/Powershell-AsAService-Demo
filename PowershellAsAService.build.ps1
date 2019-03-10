
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

task Terraform {
    push-location $BuildRoot\terraform\azureAutomation
    terraform init
    terraform apply --auto-approve
    pop-location
}

task . Test