resource "datadog_dashboard" "log_forwarder_az_resources_dashboard" {
  title        = "Log Forwarder Dashboard"
  description  = "Datadog dashboard providing main metrics for all backbone, Log Forwarder underlying Azure Resources"
  layout_type  = "ordered"
  is_read_only = true

  template_variable {
    name    = "env"
    default = var.datadog_dashboard_default_env
    prefix  = "env"
  }

  widget {
    group_definition {
      layout_type = "ordered"
      title       = "Event Hub"

      widget {
        timeseries_definition {
          title = "Healthcheck and Throttling"
          request {
            q = "sum:azure.eventhub_namespaces.throttled_requests.{$env,name:*-datadog-evhn}.as_count()"
            metadata {
              expression = "sum:azure.eventhub_namespaces.throttled_requests.{$env,name:*-datadog-evhn}.as_count()"
              alias_name = "throttling"
            }
          }
          request {
            q = "max:azure.eventhub_namespaces.status{$env,name:*-datadog-evhn}.as_count()"
            metadata {
              expression = "max:azure.eventhub_namespaces.status{$env,name:*-datadog-evhn}.as_count()"
              alias_name = "availability"
            }
          }
        }
      }

      widget {
        timeseries_definition {
          title = "Ingress and Egress"
          request {
            q = "sum:azure.eventhub_namespaces.incoming_messages{$env,name:*-datadog-evhn}.as_count()"
            metadata {
              expression = "sum:azure.eventhub_namespaces.incoming_messages{$env,name:*-datadog-evhn}.as_count()"
              alias_name = "ingress"
            }
          }
          request {
            q = "sum:azure.eventhub_namespaces.outgoing_messages{$env,name:*-datadog-evhn}.as_count()"
            metadata {
              expression = "sum:azure.eventhub_namespaces.outgoing_messages{$env,name:*-datadog-evhn}.as_count()"
              alias_name = "egress"
            }
          }
        }
      }

      widget {
        timeseries_definition {
          title = "Quota Exceeded Errors, Server Errors and User Errors"
          request {
            q = "sum:azure.eventhub_namespaces.quota_exceeded_errors.{$env,name:*-datadog-evhn}.as_count()"
            metadata {
              expression = "sum:azure.eventhub_namespaces.quota_exceeded_errors.{$env,name:*-datadog-evhn}.as_count()"
              alias_name = "quota exceeded errors"
            }
          }
          request {
            q = "sum:azure.eventhub_namespaces.server_errors.{$env,name:*-datadog-evhn}.as_count()"
            metadata {
              expression = "sum:azure.eventhub_namespaces.server_errors.{$env,name:*-datadog-evhn}.as_count()"
              alias_name = "server errors"
            }
          }
          request {
            q = "sum:azure.eventhub_namespaces.user_errors.{$env,name:*-datadog-evhn}.as_count()"
            metadata {
              expression = "sum:azure.eventhub_namespaces.user_errors.{$env,name:*-datadog-evhn}.as_count()"
              alias_name = "user errors"
            }
          }
        }
      }
    }
  }

  widget {
    group_definition {
      layout_type = "ordered"
      title       = "Function"

      widget {
        timeseries_definition {
          title = "4xx and 5xx errors"
          request {
            q = "sum:azure.functions.http4xx{$env,name:*-datadog-func}.as_count()"
            metadata {
              expression = "sum:azure.functions.http4xx{$env,name:*-datadog-func}.as_count()"
              alias_name = "4xx errors"
            }
          }
          request {
            q = "sum:azure.functions.http5xx{$env,name:*-datadog-func}.as_count()"
            metadata {
              expression = "sum:azure.functions.http5xx{$env,name:*-datadog-func}.as_count()"
              alias_name = "5xx errors"
            }
          }
        }
      }

      widget {
        timeseries_definition {
          title = "Average Response Time"
          request {
            q = "sum:azure.functions.average_response_time{$env,name:*-datadog-func}"
          }
        }
      }

      widget {
        timeseries_definition {
          title = "Executions"
          request {
            q = "sum:azure.functions.function_execution_count{$env,name:*-datadog-func} by {name}.as_count()"
          }
        }
      }

      widget {
        timeseries_definition {
          title = "Cumulative Execution Units"
          request {
            q = "sum:azure.functions.function_execution_units{$env,name:*-datadog-func}.as_count()/1024000"
          }
        }
      }
    }
  }

  widget {
    group_definition {
      layout_type = "ordered"
      title       = "Blob Storage"

      widget {
        timeseries_definition {
          title = "Healthcheck and E2E-Latency"
          request {
            q = "max:azure.storage_storageaccounts_blobservices.availability{$env,name:*ddst}"
            metadata {
              expression = "max:azure.storage_storageaccounts_blobservices.availability{$env,name:*ddst}"
              alias_name = "availability"
            }
          }
          request {
            q = "max:azure.storage_storageaccounts_blobservices.success_e2_e_latency{$env,name:*ddst}"
            metadata {
              expression = "max:azure.storage_storageaccounts_blobservices.success_e2_e_latency{$env,name:*ddst}"
              alias_name = "latency"
            }
          }
        }
      }

      widget {
        timeseries_definition {
          title = "Throughput"
          request {
            q = "sum:azure.storage_storageaccounts_blobservices.ingress{$env,name:*ddst}"
            metadata {
              expression = "sum:azure.storage_storageaccounts_blobservices.ingress{$env,name:*ddst}"
              alias_name = "ingress"
            }
          }
          request {
            q = "sum:azure.storage_storageaccounts_blobservices.egress{$env,name:*ddst}"
            metadata {
              expression = "sum:azure.storage_storageaccounts_blobservices.egress{$env,name:*ddst}"
              alias_name = "egress"
            }
          }
        }
      }
    }
  }
}
