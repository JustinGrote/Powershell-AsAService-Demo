output "HelloWorldURI" {
    value = "https://${azurerm_function_app.this.default_hostname}/api/HelloWorld"
}

output "HPWarrantyURI" {
    value = "https://${azurerm_function_app.this.default_hostname}/api/HPWarranty"
}