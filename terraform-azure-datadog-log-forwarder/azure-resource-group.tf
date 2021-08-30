resource "azurerm_resource_group" "datadog" {
  count = var.existing_ressource_group == "" ? 1 : 0

  name     = "${var.project_name_as_resource_prefix}-datadog-rg"
  location = var.resource_location
  tags     = var.azure_tags
}
