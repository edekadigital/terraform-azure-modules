data "azurerm_eventhub_namespace_authorization_rule" "datadog" {
  name = "RootManageSharedAccessKey"
  namespace_name = azurerm_eventhub_namespace.datadog.name
  resource_group_name = var.resource_group_name

  depends_on = [
    azurerm_eventhub_namespace.datadog]
}

resource "azurerm_eventhub_namespace" "datadog" {
  name = "${var.project_name_as_resource_prefix}-datadog-evhn"
  location = var.resource_location
  resource_group_name = var.resource_group_name
  sku = "Basic"
  capacity = 1
}

resource "azurerm_eventhub" "datadog" {
  name = "${var.project_name_as_resource_prefix}-datadog-evh"
  namespace_name = azurerm_eventhub_namespace.datadog.name
  resource_group_name = var.resource_group_name
  message_retention = var.eventhub_message_retention
  partition_count = var.eventhub_partition_count
}
