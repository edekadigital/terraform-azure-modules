data "azurerm_image" "devops_agent_packer" {
  name_regex          = "devops-agent.*"
  resource_group_name = var.azure_image_rg_name
  sort_descending     = true
}
