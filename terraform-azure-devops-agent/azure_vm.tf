variable "prefix" {
  default = "devops-agent-test"
}

data "azurerm_client_config" "current" {}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "main" {
  name = "${var.prefix}-public-ip"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.main.id
  }
}

resource "azurerm_linux_virtual_machine" "devops-agent" {
  name                = "azure-instance-one"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_DS3_v2"
  admin_username      = "ubuntu"
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  admin_ssh_key {
    username   = "ubuntu"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHkv3WMfJRwU4Aq0PFbIdTuLpGIqHpQdapy1NAAVdEHMbRKADkR5gw+OTmaph6dh2iUMhqDtOnt7bCy3QxJOz3Fw7CODaFFiEjblwD0gu+6D+v0npcVHQe6KmkPn5FltqHqPOcpKqeUlNvqrK2qyYmmuS/ZRp6xsCoGnma16p4GIlG0j5/gylg/q0Ixi1HFgsgT5nGoN8qv4HXKnN7PYioANWlVsh7KDyJ0Ch7AbETkH+sACzURMcTlUYJmw7FlY9J1tmPcQ+uH5qdnOMqn/t1HTUI+DgA0Ny8deXfA6+WMPlg5DBHprWeJLGbnPEQWq+xfmzUNiZzrXh5iVjffhWD nicoengelen@Nicos-MBP"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = data.azurerm_image.devops_agent_packer.id

  identity {
    type = "SystemAssigned"
  }


  
}


data "azurerm_key_vault" "shared-kv" {
  name                = "crm-shared-kv"
  resource_group_name = "crm-shared-rg"
}

resource "azurerm_key_vault_access_policy" "example" {
  key_vault_id = data.azurerm_key_vault.shared-kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_virtual_machine.devops-agent.identity.0.principal_id
  secret_permissions = [
    "Get"
  ]
}