data "azurerm_storage_account_sas" "sas_deploy_datadog" {
  connection_string = var.forwarder-func-storage_connection_string
  https_only = true

  resource_types {
    service = false
    container = false
    object = true
  }

  services {
    blob = true
    queue = false
    table = false
    file = false
  }

  start = "2020-10-15"
  expiry = "2030-10-15"

  permissions {
    read = true
    write = false
    delete = false
    list = false
    add = false
    create = false
    update = false
    process = false
  }
}

data "archive_file" "app_code_datadog" {
  type = "zip"
  source_dir = "${path.module}/monitoring"
  output_path = "${path.module}/monitoring-${replace(timestamp(), ":", "")}.zip"
}

// It is necessary to manually sync the function app triggers after deployment, see README
data "azurerm_function_app_host_keys" "datadog" {
  name = azurerm_function_app.datadog.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_app_service_plan" "datadog" {
  name = "${var.project_name_as_resource_prefix}-datadog-plan"
  location = var.resource_location
  resource_group_name = var.resource_group_name
  kind = "FunctionApp"
  reserved = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "datadog" {
  name = "${var.project_name_as_resource_prefix}-datadog-func"
  location = var.resource_location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.datadog.id
  storage_account_name = var.forwarder-func-storage_account_name
  storage_account_access_key = var.forwarder-func-storage_account_access_key
  version = "~3"
  os_type = "linux"
  https_only = true

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    AzureWebJobsDisableHomepage = true
    FUNCTIONS_WORKER_RUNTIME = "node"
    WEBSITE_NODE_DEFAULT_VERSION = "~12"
    FUNCTION_APP_EDIT_MODE = "readonly"
    HASH = filebase64sha256(data.archive_file.app_code_datadog.output_path)
    WEBSITE_RUN_FROM_PACKAGE = "https://${var.forwarder-func-storage_account_name}.blob.core.windows.net/${azurerm_storage_container.deployments_datadog.name}/${azurerm_storage_blob.app_code_datadog.name}${data.azurerm_storage_account_sas.sas_deploy_datadog.sas}"

    DD_API_KEY = var.datadog_api_key
    DD_SITE = "datadoghq.eu"
    DATADOG_EVENTHUB_CONNECTION = "${azurerm_eventhub_namespace.datadog.default_primary_connection_string};EntityPath=datadog"
    DD_TAGS_RULES = var.dd_tags_rules
  }

  depends_on = [
    azurerm_app_service_plan.datadog]
}

resource "null_resource" "trigger_sync_datadog" {
  depends_on = [
    azurerm_function_app.datadog]
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "curl -s -d '' https://${azurerm_function_app.datadog.default_hostname}/admin/host/synctriggers?code=$FUNC_APP_MASTER_KEY"

    environment = {
      FUNC_APP_MASTER_KEY = data.azurerm_function_app_host_keys.datadog.master_key
    }
  }
}

resource "azurerm_storage_container" "deployments_datadog" {
  name = "function-releases"
  storage_account_name = var.forwarder-func-storage_account_name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "app_code_datadog" {
  name = "monitoring.zip"
  storage_account_name = var.forwarder-func-storage_account_name
  storage_container_name = azurerm_storage_container.deployments_datadog.name
  type = "Block"
  source = data.archive_file.app_code_datadog.output_path
  metadata = {
    sha = data.archive_file.app_code_datadog.output_sha
  }
}
