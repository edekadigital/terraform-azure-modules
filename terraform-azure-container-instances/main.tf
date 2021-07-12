terraform {
}

provider "azurerm" {
  features {

  }
}

data "azurerm_virtual_network" "VirtualNetwork" {
  name = var.VIRTUAL_NETWORK_NAME
  resource_group_name = azurerm_resource_group.aci_rg.name
}
