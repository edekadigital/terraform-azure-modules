variable "project_name_as_resource_prefix" {
  description = "Prefix for all the resource names"
  type        = string
}

variable "datadog_api_key" {
  description = "API key for datadog"
  type        = string
}

variable "datadog_app_key" {
  description = "App key for datadog. Used for datadog dashboard and monitors creation. Ignore, if no dashboard and monitors wanted."
  type        = string
  default     = ""
}

variable "subscription_id" {
  description = "Azure subscription id where all resources are gonna be deployed"
  type        = string
}

variable "datadog_site" {
  description = "datadog site like (US/EU)"
  type        = string
  default     = "datadoghq.eu"
}

variable "datadog_tags" {
  description = "Tags to attach to all log messages and datadog monitors"
  type        = map(string)
  default     = {}
}

variable "datadog_service_map" {
  description = "A map translating azure service names into datadog `service` tags"
  type        = map(string)
  default     = {}
}

variable "az_resources_tags" {
  description = "Tags to attach to all created Azure Resources for Log Forwarder"
  type        = map(string)
  default     = {}
}

variable "datadog_resources_tags" {
  description = "Tags to attach to all created Azure Resources for Log Forwarder"
  type        = map(string)
  default     = {}
}

variable "create_datadog_dashboard_and_monitors" {
  description = "Conditional for creation of datadog dashboard and monitors for log forwarder backbone Azure resources"
  type        = bool
  default     = false
}

variable "datadog_monitors_notification_channel" {
  description = "Channel name for datadog monitors notifications, f.E. MS Team Channel name. Ignore, if no dashboard and monitors wanted."
  type        = string
  default     = ""
}

variable "resource_location" {
  description = "Azure location to deploy all the things"
  type        = string
  default     = "West Europe"
}

variable "eventhub_message_retention" {
  description = "Retention of events within event hub in days"
  type        = number
  default     = 1
}

variable "eventhub_partition_count" {
  description = "Number of partitions within event hub"
  type        = number
  default     = 4
}
