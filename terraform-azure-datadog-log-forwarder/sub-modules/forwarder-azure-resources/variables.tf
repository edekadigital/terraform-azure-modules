variable "datadog_api_key" {
  description = "API key for datadog"
  type        = string
}

variable "datadog_tags" {
  description = "Tags to attach to all log messages and datadog monitors"
  type        = map(string)
}

variable "datadog_site" {
  description = "datadog site like (US/EU)"
  type        = string
}

variable "datadog_service_map" {
  description = "A map translating azure service names into datadog `service` tags"
  type        = map(string)
}

variable "azure_tags" {
  description = "Tags to attach to all created Azure Resources for Log Forwarder"
  type        = map(string)
}
