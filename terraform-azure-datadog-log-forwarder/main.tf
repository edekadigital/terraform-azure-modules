module "az_backbone_resources" {
  source = "./sub-modules/forwarder-azure-resources"

  project_name_as_resource_prefix = var.project_name_as_resource_prefix
  resource_location               = var.resource_location
  eventhub_message_retention      = var.eventhub_message_retention
  eventhub_partition_count        = var.eventhub_partition_count
  azure_tags                      = var.azure_tags
  datadog_api_key                 = var.datadog_api_key
  datadog_site                    = var.datadog_site
  datadog_tags                    = var.datadog_tags
  datadog_service_map             = var.datadog_service_map
}

module "dashboard" {
  source = "./sub-modules/forwarder-dashboard"
  count  = var.datadog_create_dashboard ? 1 : 0

  datadog_dashboard_default_env = var.datadog_dashboard_default_env
}

module "monitors" {
  source = "./sub-modules/forwarder-monitors"
  count  = var.datadog_create_monitors ? 1 : 0

  datadog_tags                                   = var.datadog_tags
  datadog_monitors_notification_channel          = var.datadog_monitors_notification_channel
  datadog_monitors_function_executions_threshold = var.datadog_monitors_function_executions_threshold
  datadog_monitors_function_executions_time      = var.datadog_monitors_function_executions_time
}
