resource "azurerm_container_group" "sftp" {
  name                = "${var.prefix}-continst"
  location            = azurerm_resource_group.sftp.location
  resource_group_name = azurerm_resource_group.sftp.name
  ip_address_type     = "public"
  dns_name_label      = "${var.prefix}-continst"
  os_type             = "linux"
  container {
    name   = "sftp-source"
    image  = "atmoz/sftp:latest"
    cpu    = "1"
    memory = "1.5"
    environment_variables = {
      "SFTP_USERS" = "${var.sftp_user_name}:${var.sftp_password}:1001"
    }

    ports {
      port     = "22"
      protocol = "TCP"
    }

    volume {
      name                 = "sftpvolume"
      mount_path           = "/home/${var.sftp_user_name}/${local.sftp_folder}"
      read_only            = false
      share_name           = azurerm_storage_share.sftp.name
      storage_account_name = azurerm_storage_account.sftp.name
      storage_account_key  = azurerm_storage_account.sftp.primary_access_key
    }
  }
  tags = var.azure_tags
}