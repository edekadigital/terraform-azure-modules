module "az_backbone_resources" {
  source = "./sub-modules/forwarder-azure-resources"

  project_name_as_resource_prefix = var.project_name_as_resource_prefix
  resource_location               = var.resource_location
  subscription_id                 = var.subscription_id
  eventhub_message_retention      = var.eventhub_message_retention
  eventhub_partition_count        = var.eventhub_partition_count
  datadog_api_key                 = var.datadog_api_key
  datadog_site                    = var.datadog_site
  datadog_tags                    = var.datadog_tags
  datadog_service_map             = var.datadog_service_map
  az_resources_tags               = var.az_resources_tags
}

module "monitoring" {
  source = "./sub-modules/forwarder-monitoring"

  datadog_api_key                       = var.datadog_api_key
  datadog_app_key                       = var.datadog_app_key
  datadog_site                          = var.datadog_site
  datadog_tags                          = var.datadog_tags
  create_datadog_dashboard_and_monitors = var.create_datadog_dashboard_and_monitors
  datadog_monitors_notification_channel = var.datadog_monitors_notification_channel
}
