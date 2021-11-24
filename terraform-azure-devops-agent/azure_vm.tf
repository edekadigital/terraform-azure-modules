
resource "azurerm_network_interface" "devops_agent" {
  count               = var.azure_instance_count
  name                = format("%s-%03d-nic", var.project_name_as_resource_prefix, count.index)
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location

  ip_configuration {
    name                          = "ip_config"
    subnet_id                     = var.azure_devops_agent_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.azure_tags
}

resource "azurerm_linux_virtual_machine" "devops_agent" {
  count                 = local.azure_instance_count
  name                  = format("azure-instance-%03d", count.index + 1)
  resource_group_name   = local.resource_group_name
  location              = local.resource_group_location
  size                  = var.azure_vm_instance_size
  admin_username        = "ubuntu"
  source_image_id       = var.azure_agent_image_id
  network_interface_ids = [azurerm_network_interface.devops_agent[count.index].id]

  custom_data = base64encode(templatefile("${path.module}/cloud-init.tpl", {
    ENV_VARS = {
      "VAULT_NAME"        = data.azurerm_key_vault.devops_pat_key_vault[0].name
      "SECRET_NAME"       = var.azure_devops_pat_secret_name
      "AGENT_NAME_PREFIX" = "${var.agent_name_prefix}-azure"
      "DEVOPS_ORG_URL"    = var.devops_org_url
      "DEVOPS_AGENT_POOL" = var.devops_agent_pool
  } }))

  dynamic "admin_ssh_key" {
    for_each = toset(var.azure_ssh_public_keys)
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

  tags = var.azure_tags
}

resource "azurerm_key_vault_access_policy" "devops_agent" {
  count        = length(azurerm_linux_virtual_machine.devops_agent)
  key_vault_id = data.azurerm_key_vault.devops_pat_key_vault[0].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_virtual_machine.devops_agent[count.index].identity.0.principal_id
  secret_permissions = [
    "Get"
  ]
}
