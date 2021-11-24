data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "devops_agent" {
  count = var.azure_existing_resource_group == "" || var.azure_instance_count == 0 ? 0 : 1
  name  = var.azure_existing_resource_group
}

data "azurerm_key_vault" "devops_pat_key_vault" {
  count               = var.azure_instance_count == 0 ? 0 : 1
  name                = var.azure_devops_pat_keyvault_name
  resource_group_name = var.azure_devops_pat_keyvault_resource_group
}
