resource "azurerm_container_group" "aci" {
  name                = var.ACI_NAME
  location            = azurerm_resource_group.aci_rg.location
  resource_group_name = azurerm_resource_group.aci_rg.name
  ip_address_type     = "private"
  network_profile_id  = azurerm_network_profile.aci-network-profile.id
  os_type             = "Linux"
  restart_policy      = var.RESTART_POLICY

  image_registry_credential {
    username = var.IMAGE_REGISTRY_USERNAME
    password = var.IMAGE_REGISTRY_PASSWORD
    server   = var.IMAGE_REGISTRY_SERVER
  }

  container {
    name   = var.ACI_NAME
    image  = var.IMAGE_TAG
    cpu    = var.CPU
    memory = var.MEMORY
    commands = var.ACI_COMMANDS

    secure_environment_variables = {
    }

    environment_variables = {
    }

    ports {
      port     = 443
      protocol = "TCP"
    }
  }


  tags = var.TAGS
}
