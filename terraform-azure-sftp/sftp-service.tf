resource "azurerm_container_group" "sftp" {
  name                = "${var.prefix}-continst"
  location            = azurerm_resource_group.sftp.location
  resource_group_name = azurerm_resource_group.sftp.name
  ip_address_type     = "Public"
  dns_name_label      = "${var.prefix}-continst"
  os_type             = "Linux"
  container {
    name   = "sftp-source"
    image  = "selamanse/sftp:latest"
    cpu    = "1"
    memory = "1.5"
    environment_variables = {
      "SFTP_USERS" = "${var.sftp_user_name}:${var.sftp_password}:1001"
    }

    ports {
      port     = "22"
      protocol = "TCP"
    }

    # https://github.com/atmoz/sftp#providing-your-own-ssh-host-key-recommended
    volume {
      name       = "ssh-config-files"
      mount_path = "/ssh-config-files"
      secret = {
        sshd_config = base64encode(templatefile(
          "${path.module}/templates/sshd_config.tmpl",
          {
            host_keys = ["ssh_host_ed25519_key", "ssh_host_rsa_key"]
          }
        )),
        ssh_host_ed25519_key = var.ssh_host_ed25519_key,
        ssh_host_rsa_key     = var.ssh_host_rsa_key
      }
    }

    volume {
      name       = "bootscripts"
      mount_path = "/etc/sftp.d"
      secret = {
        "bootstrap.sh" = base64encode(templatefile(
          "${path.module}/templates/bootstrap.sh.tmpl",
          {}
        ))
      }
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
