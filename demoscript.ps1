#Requires -PSEdition Core



#Powershell As A Service Demo
write-host -fore Green '
===============================================================================
    ____             __    ___    ___   _____      ____                     
   / __ \____  _____/ /_  /   |  /   | / ___/     / __ \___  ____ ___  ____ 
  / /_/ / __ \/ ___/ __ \/ /| | / /| | \__ \     / / / / _ \/ __ `__ \/ __ \
 / ____/ /_/ (__  ) / / / ___ |/ ___ |___/ /    / /_/ /  __/ / / / / / /_/ /
/_/    \____/____/_/ /_/_/  |_/_/  |_/____/    /_____/\___/_/ /_/ /_/\____/

===============================================================================
'

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

promptstep "Deploy Example and HPWarranty in Azure Functions with Terraform" `
{.\build.ps1 TerraformAWSLambda}

promptstep "Deploy Example Script in Azure Automation with Terraform" `
{.\build.ps1 TerraformAzureAutomation}

promptstep "Deploy Example and HPWarranty in Azure Functions with Terraform" `
{.\build.ps1 TerraformAzureFunction}

promptstep "Tear down all the terraform resources" `
{.\build.ps1 Destroy}