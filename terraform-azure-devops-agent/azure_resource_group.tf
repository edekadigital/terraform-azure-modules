resource "azurerm_resource_group" "devops_agent" {
  count = var.azure_existing_resource_group == "" && var.azure_instance_count > 0 ? 1 : 0

  name     = "rg-${var.project_name_as_resource_prefix}-devops-agent"
  location = var.resource_location
  tags     = var.azure_tags
}