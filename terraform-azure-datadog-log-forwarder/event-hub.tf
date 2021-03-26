data "azurerm_eventhub_namespace_authorization_rule" "datadog" {
  name                = "RootManageSharedAccessKey"
  namespace_name      = azurerm_eventhub_namespace.datadog.name
  resource_group_name = azurerm_resource_group.datadog.name

  depends_on = [
  azurerm_eventhub_namespace.datadog]
}

resource "azurerm_eventhub_namespace" "datadog" {
  name                = "${var.project_name_as_resource_prefix}-datadog-evhn"
  location            = var.resource_location
  resource_group_name = azurerm_resource_group.datadog.name
  sku                 = "Basic"
  capacity            = 1
}

resource "azurerm_eventhub" "datadog" {
  name                = "datadog"
  namespace_name      = azurerm_eventhub_namespace.datadog.name
  resource_group_name = azurerm_resource_group.datadog.name
  message_retention   = var.eventhub_message_retention
  partition_count     = var.eventhub_partition_count
}
