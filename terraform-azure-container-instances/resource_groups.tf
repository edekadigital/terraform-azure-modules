resource "azurerm_resource_group" "aci_rg" {
  name     = var.RG_NAME
  location = var.LOCATION
  tags     = var.TAGS
}
