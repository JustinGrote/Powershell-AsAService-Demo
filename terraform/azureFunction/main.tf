provider azurerm {
  version = "~> 1.23"
}
provider archive {
  version = "~> 1.1"
}

variable "functionName" {
  default = "poshaasdemotf"
}

variable "region" {
  default = "westus2"
}

resource "azurerm_resource_group" "this" {
  name     = "${var.functionName}"
  location = "${var.region}"
}

resource "azurerm_storage_account" "this" {
  name                     = "${var.functionName}"
  resource_group_name      = "${azurerm_resource_group.this.name}"
  location                 = "${azurerm_resource_group.this.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "this" {
  name                = "${var.functionName}"
  location            = "${azurerm_resource_group.this.location}"
  resource_group_name = "${azurerm_resource_group.this.name}"
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "this" {
  name                      = "${var.functionName}"
  location                  = "${azurerm_resource_group.this.location}"
  resource_group_name       = "${azurerm_resource_group.this.name}"
  app_service_plan_id       = "${azurerm_app_service_plan.this.id}"
  storage_connection_string = "${azurerm_storage_account.this.primary_connection_string}"
  provisioner local-exec {
    #interpreter = ["pwsh","-noprofile","-noninteractive"]
    command = "az functionapp deployment source config-zip -n ${azurerm_function_app.this.name} -g ${azurerm_function_app.this.resource_group_name} --src ${data.archive_file.this.output_path}"
  }
}

data "archive_file" "this" {
  type        = "zip"
  source_dir = "${path.module}/../../Examples/AzureFunctionExample"
  output_path = "${path.module}/../../BuildOutput/AzureFunctionExample.zip"
}

