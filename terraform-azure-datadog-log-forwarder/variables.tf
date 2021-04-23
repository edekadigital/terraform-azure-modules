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

variable "datadog_dashboard_default_env" {
  description = "Default env value shown in the dashboard"
  type        = string
  default     = "*"
}

variable "datadog_monitors_function_executions_time" {
  description = "Time span definition for function execution monitor"
  type        = string
  default     = "last_1h"
}

variable "datadog_monitors_function_executions_threshold" {
  description = "Threshold for minimal function executions"
  type        = number
  default     = 50
}

variable "datadog_monitors_priority" {
  description = "Priority of monitors in datadog"
  type        = number
  default     = 2
}

variable "datadog_tag_name_kind" {
  description = "Tag name for the `kind` tag."
  type        = string
  default     = "kind"
}

variable "azure_tags" {
  description = "Tags to attach to all created Azure Resources for Log Forwarder"
  type        = map(string)
  default     = {}
}

variable "datadog_resources_tags" {
  description = "Tags to attach to all created Azure Resources for Log Forwarder"
  type        = map(string)
  default     = {}
}

variable "datadog_create_dashboard" {
  description = "Create a datadog dashboard for log forwarder backbone Azure resources"
  type        = bool
  default     = false
}

variable "datadog_create_monitors" {
  description = "Create datadog monitors for log forwarder backbone Azure resources"
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

locals {
  datadog_tags = [for k, v in var.datadog_tags : "${k}:${v}"]
}
