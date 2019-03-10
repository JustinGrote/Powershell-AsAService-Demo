resource "azurerm_resource_group" "example" {
  name     = "powershellasaservice-demo-azautomation"
  location = "westus2"
}

resource "azurerm_automation_account" "example" {
  name                = "powershellasaservice-demo-azautomation"
  location            = "${azurerm_resource_group.example.location}"
  resource_group_name = "${azurerm_resource_group.example.name}"

  sku {
    name = "Basic"
  }
}

data "local_file" "example" {
  filename = "${path.module}/../../AzureAutomationExample.ps1"
}

resource "azurerm_automation_runbook" "example" {
  name                = "AzureAutomationExample.ps1"
  location            = "${azurerm_resource_group.example.location}"
  resource_group_name = "${azurerm_resource_group.example.name}"
  account_name        = "${azurerm_automation_account.example.name}"
  log_verbose         = "true"
  log_progress        = "true"
  description         = "Powershell As A Service Demo"
  runbook_type        = "PowerShell"

  #Eccentricity: This is always required even when pushing local content
  publish_content_link {
    uri = "https://localscript"
  }

  content = "${data.local_file.example.content}"
}