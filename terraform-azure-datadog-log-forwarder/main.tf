provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

resource "azurerm_resource_group" "datadog" {
  name = "${var.project_name_as_resource_prefix}-datadog-rg"
  location = var.resource_location
}
