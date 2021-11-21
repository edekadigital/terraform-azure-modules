data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "devops_agent" {
  count = var.existing_resource_group == "" || var.azure_instance_count == 0 ? 0 : 1
  name  = var.existing_resource_group
}

data "azurerm_key_vault" "devops_pat_key_vault" {
  count               = var.azure_instance_count == 0 ? 0 : 1
  name                = var.key_vault_name
  resource_group_name = var.key_vault_rg_name
}

# data "azurerm_key_vault_secret" "example" {
#   name              = var.azure_devops_pat_secret_name
#   key_vkey_vault_id = "dd"
# }

