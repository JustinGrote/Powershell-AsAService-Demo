#Powershell As A Service Demo
$ErrorActionPreference = 'Stop'

$i=1
function promptstep ([string]$prompt, $cmd) {
    $lines = [Environment]::NewLine + "===========================================================================================" + [Environment]::NewLine
    write-host -fore Green "$lines Step $i`: $prompt $lines"
    $null = read-host "Press enter to run command $cmd"
    write-host -fore Cyan "RUNNING COMMAND: $cmd"
    & $cmd
    $i++
}

promptstep "Make sure our environment is good" `
{.\build.ps1 Test}

promptstep "Install Prerequisites" `
{.\build.ps1 Dependencies}

promptstep "Deploy Example Script in Azure Automation with Terraform"
{.\build.ps1 TerraformAzureAutomation}

promptstep "Tear down all the terraform resources" `
{.\build.ps1 Destroy}