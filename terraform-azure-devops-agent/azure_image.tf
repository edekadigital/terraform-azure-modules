data "azurerm_image" "devops_agent_packer" {
  name_regex          = "devops-agent.*"
  resource_group_name = "crm-shared-rg"
  sort_descending     = true
}
