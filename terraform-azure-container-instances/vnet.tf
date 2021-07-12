resource "azurerm_subnet" "aci-subnet" {
  name = var.ACI_SUBNET
  resource_group_name = data.azurerm_virtual_network.VirtualNetwork.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.VirtualNetwork.name
  address_prefixes = [
    var.ACI_SUBNET_ADDRESS_PREFIX
  ]

  delegation {
    name = var.ACI_SUBNET_DELEGATION_NAME

    service_delegation {
      name = "Microsoft.ContainerInstance/containerGroups"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

resource "azurerm_network_profile" "aci-network-profile" {
  name = var.ACI_NETWORK_PROFILE
  location = var.LOCATION
  resource_group_name = azurerm_resource_group.aci_rg.name

  container_network_interface {
    name = var.ACI_NETWORK_PROFILE_CONTAINER_NETWORK_INTERFACE_NAME

    ip_configuration {
      name = var.ACI_NETWORK_PROFILE_IP_CONFIGURATION_NAME
      subnet_id = azurerm_subnet.aci-subnet.id
    }
  }
}
