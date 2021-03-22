variable "resource_location" {
  type    = string
  default = "West Europe"
}

variable "resource_group_name" {
  type = string
}

variable "project_name_as_resource_prefix" {
  type = string
}

variable "eventhub_message_retention" {
  type = string
  default = "1" // 1 day
}

variable "eventhub_partition_count" {
  type = string
  default = "4" // like Azure Default
}

variable "forwarder-func-storage_account_name" {
  type = string
}

variable "forwarder-func-storage_account_access_key" {
  type = string
}

variable "forwarder-func-storage_connection_string" {
  type = string
}

variable "datadog_api_key" {
  type = string
}

variable "dd_tags_rules" {
  type = string
}
