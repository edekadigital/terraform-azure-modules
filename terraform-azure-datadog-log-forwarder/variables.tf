variable "project_name_as_resource_prefix" {
  description = "Prefix for all the resource names"
  type        = string
}

variable "datadog_api_key" {
  description = "API key for datadog"
  type        = string
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
  description = "Tags to attach to all log messages"
  type        = map(string)
  default     = {}
}

variable "datadog_service_map" {
  description = "A map translating azure service names into datadog `service` tags"
  type        = map(string)
  default     = {}
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
