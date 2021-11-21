
# resource "azurerm_resource_group" "main" {
#   name     = "rg-${var.prefix}-resources"
#   location = "West Europe"
# }

# resource "azurerm_key_vault_secret" "devops-pat" {
#   name         = "${var.azure_devops_pat_secret_prefix}${local.keyvault_devops_pat_secret_name}"
#   key_vault_id = data.azurerm_key_vault.shared-kv.id
#   value        = var.devops_pat
# }

# resource "azurerm_virtual_network" "main" {
#   name                = "${var.prefix}-network"
#   address_space       = ["10.0.0.0/16"]
#   location            = azurerm_resource_group.main.location
#   resource_group_name = azurerm_resource_group.main.name
# }

# resource "azurerm_subnet" "internal" {
#   name                 = "internal"
#   resource_group_name  = azurerm_resource_group.main.name
#   virtual_network_name = azurerm_virtual_network.main.name
#   address_prefixes     = ["10.0.2.0/24"]
# }

# resource "azurerm_subnet" "bastion" {
#   name                 = "bastion"
#   resource_group_name  = azurerm_resource_group.main.name
#   virtual_network_name = azurerm_virtual_network.main.name
#   address_prefixes     = ["10.0.0.0/28"]
# }

# resource "azurerm_network_security_group" "bastion" {
#   name                = "${var.prefix}-bastion-nsg"
#   resource_group_name = azurerm_resource_group.main.name
#   location            = azurerm_resource_group.main.location
# }

# resource "azurerm_subnet_network_security_group_association" "bastion" {
#   network_security_group_id = azurerm_network_security_group.bastion.id
#   subnet_id                 = azurerm_subnet.bastion.id
# }

# resource "azurerm_public_ip" "main" {
#   name                = "${var.prefix}-public-ip"
#   location            = azurerm_resource_group.main.location
#   resource_group_name = azurerm_resource_group.main.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

# resource "azurerm_nat_gateway" "main" {
#   name                = "${var.prefix}-natgateway"
#   location            = azurerm_resource_group.main.location
#   resource_group_name = azurerm_resource_group.main.name
# }

# resource "azurerm_nat_gateway_public_ip_association" "main" {
#   nat_gateway_id       = azurerm_nat_gateway.main.id
#   public_ip_address_id = azurerm_public_ip.main.id
# }

# resource "azurerm_subnet_nat_gateway_association" "example" {
#   subnet_id      = azurerm_subnet.internal.id
#   nat_gateway_id = azurerm_nat_gateway.main.id
# }

resource "azurerm_network_interface" "devops_agent" {
  count               = var.azure_instance_count
  name                = format("%s-%03d-nic", var.project_name_as_resource_prefix, count.index)
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ip_config"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "devops_agent" {
  count                 = var.azure_instance_count
  name                  = format("azure-instance-%03d", count.index + 1)
  resource_group_name   = var.existing_resource_group == "" ? data.resource_group_name.devops-agent.name : azurerm_resource_group.devops_agent.name # local.resource_group_name
  location              = var.existing_resource_group == "" ? data.resource_group_name.devops-agent.location : azurerm_resource_group.devops_agent.location # local.resource_group_location
  size                  = var.azure_vm_instance_size
  admin_username        = "ubuntu"
  source_image_id       = var.azure_agent_image_id  # data.azurerm_image.devops_agent_packer.id
  network_interface_ids = [azurerm_network_interface.devops_agent[count.index].id]

  custom_data = base64encode(templatefile("${path.module}/cloud-init.tpl", {
    ENV_VARS = {
      "VAULT_NAME"        = data.azurerm_key_vault.devops_pat_key_vault.name
      "SECRET_NAME"       = var.azure_devops_pat_secret_name
      "AGENT_NAME_PREFIX" = "${var.agent_name_prefix}-azure"
      "DEVOPS_ORG_URL"    = var.devops_org_url
      "DEVOPS_AGENT_POOL" = var.devops_agent_pool
  } }))

  dynamic "admin_ssh_key" {
    for_each = toset(var.ssh_public_keys)
    content {
      username   = "ubuntu"
      public_key = admin_ssh_key.value
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 50
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "devops_agent" {
  count        = length(azurerm_linux_virtual_machine.devops_agent)
  key_vault_id = data.azurerm_key_vault.devops_pat_key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_virtual_machine.devops_agent[count.index].identity.0.principal_id
  secret_permissions = [
    "Get"
  ]
}