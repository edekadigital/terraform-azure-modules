variable "datadog_monitors_notification_channel" {
  description = "Channel name for datadog monitors notifications, f.E. MS Team Channel name. Ignore, if no dashboard and monitors wanted."
  type        = string
}

variable "datadog_tags" {
  description = "Tags to attach to all log messages and datadog monitors"
  type        = map(string)
}

variable "datadog_monitors_function_executions_time" {
  description = "Time span definition for function execution monitor"
  type        = string
}

variable "datadog_monitors_function_executions_threshold" {
  description = "Threshold for minimal function executions"
  type        = number
}

locals {
  datadog_tags = [for k, v in var.datadog_tags : "${k}:${v}"]
}
