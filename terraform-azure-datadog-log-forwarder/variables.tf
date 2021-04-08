variable "resource_location" {
  type    = string
  default = "West Europe"
}

variable "project_name_as_resource_prefix" {
  type = string
}

variable "eventhub_message_retention" {
  type    = string
  default = "1" // 1 day
}

variable "eventhub_partition_count" {
  type    = string
  default = "4" // like Azure default for Event Hub partition count
}

variable "datadog_api_key" {
  type = string
}

variable "dd_tags" {
  type = string
}

variable "dd_service" {
  type = string
}

variable "subscription_id" {
  type = string
}
