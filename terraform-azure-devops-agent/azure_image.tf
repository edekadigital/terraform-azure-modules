data "azurerm_image" "devops_agent_packer" {
  name                = "devops-agent"
  resource_group_name = "crm-shared-rg"
}