
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
}