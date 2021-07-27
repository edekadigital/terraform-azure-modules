resource "datadog_monitor" "event-hub-errors" {
  count = var.datadog_create_monitors ? 1 : 0

  name               = "DD Log Forwarder Event Hub Errors"
  type               = "query alert"
  message            = "{{#is_alert}}Event Hub for Datadog Log Forwarder throws server or / and user errors .{{/is_alert}}{{#is_recovery}}Event Hub for Datadog Log Forwarder don't throw server / or user errors now.{{/is_recovery}} ${var.datadog_monitors_notification_channel}"
  escalation_message = ""

  query = "sum(last_1h):sum:azure.eventhub_namespaces.user_errors.{name:${azurerm_eventhub_namespace.datadog.name}}.as_count() + sum:azure.eventhub_namespaces.server_errors.{name:${azurerm_eventhub_namespace.datadog.name}}.as_count() > 50"

  monitor_thresholds {
    critical          = 50
    critical_recovery = 0
  }

  priority            = var.datadog_monitors_priority
  require_full_window = true
  notify_no_data      = false
  renotify_interval   = 0
  evaluation_delay    = 900

  timeout_h    = 12
  include_tags = true

  tags = concat(local.datadog_tags, local.datadog_monitors_tags, ["${var.datadog_tag_name_kind}:event-hub"])
}

resource "datadog_monitor" "event-hub-healthcheck" {
  count = var.datadog_create_monitors ? 1 : 0

  name               = "DD Log Forwarder Event Hub Healthcheck"
  type               = "query alert"
  message            = "{{#is_alert}}Event Hub for Datadog Log Forwarder not accessible.{{/is_alert}}{{#is_recovery}}Event Hub for Datadog Log Forwarder accessible now.{{/is_recovery}} ${var.datadog_monitors_notification_channel}"
  escalation_message = "{{#is_alert}}Event Hub for Datadog Log Forwarder still not accessible.{{/is_alert}}{{#is_recovery}}Event Hub for Datadog Log Forwarder accessible now.{{/is_recovery}} ${var.datadog_monitors_notification_channel}"

  query = "max(last_1h):sum:azure.eventhub_namespaces.status{name:${azurerm_eventhub_namespace.datadog.name}} < 1"

  monitor_thresholds {
    critical = 1
  }

  priority            = var.datadog_monitors_priority
  require_full_window = true
  notify_no_data      = true
  no_data_timeframe   = 120
  renotify_interval   = 60
  evaluation_delay    = 900

  timeout_h    = 0
  include_tags = true

  tags = concat(local.datadog_tags, local.datadog_monitors_tags, ["${var.datadog_tag_name_kind}:event-hub"])
}

resource "datadog_monitor" "event-hub-quotas" {
  count = var.datadog_create_monitors ? 1 : 0

  name               = "DD Log Forwarder Event Hub Quotas"
  type               = "query alert"
  message            = "{{#is_alert}}Event Hub for Datadog Log Forwarder quotas are exceeded.{{/is_alert}}{{#is_recovery}}Event Hub for Datadog Log Forwarder quotas are OK.{{/is_recovery}} ${var.datadog_monitors_notification_channel}"
  escalation_message = "{{#is_alert}}Event Hub for Datadog Log Forwarder quotas are still exceeded.{{/is_alert}}{{#is_recovery}}Event Hub for Datadog Log Forwarder quotas are OK.{{/is_recovery}} ${var.datadog_monitors_notification_channel}"

  query = "sum(last_1h):sum:azure.eventhub_namespaces.quota_exceeded_errors.{name:${azurerm_eventhub_namespace.datadog.name}}.as_count() > 10"

  monitor_thresholds {
    critical          = 10
    critical_recovery = 0
  }

  priority            = var.datadog_monitors_priority
  require_full_window = true
  notify_no_data      = true
  no_data_timeframe   = 120
  renotify_interval   = 60
  evaluation_delay    = 900

  timeout_h    = 0
  include_tags = true

  tags = concat(local.datadog_tags, local.datadog_monitors_tags, ["${var.datadog_tag_name_kind}:event-hub"])
}

resource "datadog_monitor" "event-hub-throttling" {
  count = var.datadog_create_monitors ? 1 : 0

  name               = "DD Log Forwarder Event Hub Throttling"
  type               = "query alert"
  message            = "{{#is_alert}}Event Hub for Datadog Log Forwarder was throttled.{{/is_alert}}{{#is_recovery}}Event Hub for Datadog Log Forwarder throttling recovered.{{/is_recovery}} ${var.datadog_monitors_notification_channel}"
  escalation_message = "{{#is_alert}}Event Hub for Datadog Log Forwarder still throttled.{{/is_alert}}{{#is_recovery}}Event Hub for Datadog Log Forwarder throttling recovered.{{/is_recovery}} ${var.datadog_monitors_notification_channel}"

  query = "sum(last_1h):sum:azure.eventhub_namespaces.throttled_requests.{name:${azurerm_eventhub_namespace.datadog.name}}.as_count() > 5"

  monitor_thresholds {
    critical          = 5
    critical_recovery = 0
  }

  priority            = var.datadog_monitors_priority
  require_full_window = true
  notify_no_data      = false
  renotify_interval   = 60
  evaluation_delay    = 900

  timeout_h    = 12
  include_tags = true

  tags = concat(local.datadog_tags, local.datadog_monitors_tags, ["${var.datadog_tag_name_kind}:event-hub"])
}

resource "datadog_monitor" "storage-account-healthcheck" {
  count = var.datadog_create_monitors ? 1 : 0

  name               = "DD Log Forwarder Storage Account Healthcheck"
  type               = "query alert"
  message            = "{{#is_alert}}Storage Account for Datadog Log Forwarder not accessible.{{/is_alert}}{{#is_recovery}}Storage Account for Datadog Log Forwarder accessible now.{{/is_recovery}} ${var.datadog_monitors_notification_channel}"
  escalation_message = "{{#is_alert}}Storage Account for Datadog Log Forwarder still not accessible.{{/is_alert}}{{#is_recovery}}Storage Account for Datadog Log Forwarder accessible now.{{/is_recovery}} ${var.datadog_monitors_notification_channel}"

  query = "max(last_1h):sum:azure.storage_storageaccounts_blobservices.availability{name:${azurerm_storage_account.datadog.name}} < 1"

  monitor_thresholds {
    critical = 1
  }

  priority            = var.datadog_monitors_priority
  require_full_window = true
  notify_no_data      = true
  no_data_timeframe   = 120
  renotify_interval   = 60
  evaluation_delay    = 900

  timeout_h    = 0
  include_tags = true

  tags = concat(local.datadog_tags, local.datadog_monitors_tags, ["${var.datadog_tag_name_kind}:storage"])
}

resource "datadog_monitor" "func-errors" {
  count = var.datadog_create_monitors ? 1 : 0

  name               = "DD Log Forwarder Function Errors"
  type               = "query alert"
  message            = "{{#is_alert}}Function for Datadog Log Forwarder throws client- or / and serverside errors .{{/is_alert}}{{#is_recovery}}Function for Datadog Log Forwarder don't throw client- or / and serverside errors now.{{/is_recovery}} ${var.datadog_monitors_notification_channel}"
  escalation_message = ""

  query = "sum(last_1h):sum:azure.functions.http4xx{name:${azurerm_function_app.datadog.name}} + sum:azure.functions.http5xx{name:${azurerm_function_app.datadog.name}}.as_count() > 50"

  monitor_thresholds {
    critical          = 50
    critical_recovery = 0
  }

  priority            = var.datadog_monitors_priority
  require_full_window = true
  notify_no_data      = false
  renotify_interval   = 0
  evaluation_delay    = 900

  timeout_h    = 12
  include_tags = true

  tags = concat(local.datadog_tags, local.datadog_monitors_tags, ["${var.datadog_tag_name_kind}:function"])
}

resource "datadog_monitor" "func-executions" {
  count = var.datadog_create_monitors ? 1 : 0

  name               = "DD Log Forwarder Function Executions"
  type               = "query alert"
  message            = "{{#is_alert}}Function for Datadog Log Forwarder has suspicious few executions .{{/is_alert}}{{#is_recovery}}Function for Datadog Log Forwarder execution rate OK.{{/is_recovery}} ${var.datadog_monitors_notification_channel}"
  escalation_message = "{{#is_alert}}Function for Datadog Log Forwarder still has suspicious few executions .{{/is_alert}}{{#is_recovery}}Function for Datadog Log Forwarder execution rate OK.{{/is_recovery}} ${var.datadog_monitors_notification_channel}"

  query = "sum(${var.datadog_monitors_function_executions_time}):sum:azure.functions.function_execution_count{name:${azurerm_function_app.datadog.name}}.as_count() < ${var.datadog_monitors_function_executions_threshold}"

  monitor_thresholds {
    critical          = var.datadog_monitors_function_executions_threshold
    critical_recovery = var.datadog_monitors_function_executions_threshold + 1
  }

  priority            = var.datadog_monitors_priority
  require_full_window = true
  notify_no_data      = true
  no_data_timeframe   = 120
  renotify_interval   = 60
  evaluation_delay    = 900

  timeout_h    = 0
  include_tags = true

  tags = concat(local.datadog_tags, local.datadog_monitors_tags, ["${var.datadog_tag_name_kind}:function"])
}
