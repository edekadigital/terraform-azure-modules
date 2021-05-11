resource "azurerm_resource_group" "sftp" {
  name     = "${var.prefix}-resource-grp"
  location = var.location
}

resource "azurerm_storage_account" "sftp" {
  name                     = "sa${replace(var.prefix, "/[^a-z0-9]/", "")}"
  resource_group_name      = azurerm_resource_group.sftp.name
  location                 = azurerm_resource_group.sftp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "sftp" {
  name                 = "aci-${var.prefix}-share"
  storage_account_name = azurerm_storage_account.sftp.name
  quota                = var.sftp_quota
}