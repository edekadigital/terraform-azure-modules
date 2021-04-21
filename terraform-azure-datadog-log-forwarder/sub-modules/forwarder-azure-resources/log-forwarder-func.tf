data "archive_file" "app_code_datadog" {
  type        = "zip"
  source_dir  = "${path.module}/azure-datadog-log-forwarder"
  output_path = "${path.module}/azure-datadog-log-forwarder.zip"
  excludes = [
    "coverage",
    "jest.config.js",
    "node_modules",
    "test",
  ]
}

resource "azurerm_storage_account" "datadog" {
  name                      = replace("${var.project_name_as_resource_prefix}-dd-st", "-", "")
  resource_group_name       = azurerm_resource_group.datadog.name
  location                  = azurerm_resource_group.datadog.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true

  tags = var.azure_tags
}

data "azurerm_storage_account_sas" "sas_deploy_datadog" {
  connection_string = azurerm_storage_account.datadog.primary_connection_string
  https_only        = true

  resource_types {
    service   = false
    container = false
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2020-10-15"
  expiry = "2030-10-15"

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
  }
}

// It is necessary to manually sync the function app triggers after deployment, see README
data "azurerm_function_app_host_keys" "datadog" {
  name                = azurerm_function_app.datadog.name
  resource_group_name = azurerm_resource_group.datadog.name
}

resource "azurerm_app_service_plan" "datadog" {
  name                = "${var.project_name_as_resource_prefix}-datadog-plan"
  location            = var.resource_location
  resource_group_name = azurerm_resource_group.datadog.name
  kind                = "FunctionApp"
  reserved            = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }

  tags = var.azure_tags
}

resource "azurerm_function_app" "datadog" {
  name                       = "${var.project_name_as_resource_prefix}-datadog-func"
  location                   = var.resource_location
  resource_group_name        = azurerm_resource_group.datadog.name
  app_service_plan_id        = azurerm_app_service_plan.datadog.id
  storage_account_name       = azurerm_storage_account.datadog.name
  storage_account_access_key = azurerm_storage_account.datadog.primary_access_key
  version                    = "node|14" // https://docs.microsoft.com/en-us/azure/azure-functions/functions-reference-node?tabs=v2#node-version
  os_type                    = "linux"
  https_only                 = true


  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    AzureWebJobsDisableHomepage    = true
    FUNCTIONS_WORKER_RUNTIME       = "node"
    WEBSITE_NODE_DEFAULT_VERSION   = "~12"
    FUNCTION_APP_EDIT_MODE         = "readonly"
    HASH                           = data.archive_file.app_code_datadog.output_base64sha256
    WEBSITE_RUN_FROM_PACKAGE       = "https://${azurerm_storage_account.datadog.name}.blob.core.windows.net/${azurerm_storage_container.deployments_datadog.name}/${azurerm_storage_blob.app_code_datadog.name}${data.azurerm_storage_account_sas.sas_deploy_datadog.sas}"
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.datadog.instrumentation_key

    DD_API_KEY                  = var.datadog_api_key
    DD_SITE                     = var.datadog_site
    DATADOG_EVENTHUB_CONNECTION = "${azurerm_eventhub_namespace.datadog.default_primary_connection_string};EntityPath=datadog"
    DD_TAGS                     = join(",", [for k, v in var.datadog_tags : "${k}:${v}"])
    DD_SERVICE_MAP              = jsonencode(var.datadog_service_map)
  }

  tags = var.azure_tags

  depends_on = [
  azurerm_app_service_plan.datadog]
}

resource "azurerm_application_insights" "datadog" {
  name                = "${var.project_name_as_resource_prefix}-datadog-app-insights"
  location            = var.resource_location
  resource_group_name = azurerm_resource_group.datadog.name
  application_type    = "Node.JS"
  tags                = var.azure_tags
}

resource "null_resource" "trigger_sync_datadog" {
  depends_on = [
  azurerm_function_app.datadog]
  triggers = {
    on_update = data.archive_file.app_code_datadog.output_base64sha256
  }

  provisioner "local-exec" {
    command = "curl -sf -d '' 'https://${azurerm_function_app.datadog.default_hostname}/admin/host/synctriggers?code=${data.azurerm_function_app_host_keys.datadog.master_key}'"
  }
}

resource "azurerm_storage_container" "deployments_datadog" {
  name                  = "function-releases"
  storage_account_name  = azurerm_storage_account.datadog.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "app_code_datadog" {
  name                   = "monitoring.zip"
  storage_account_name   = azurerm_storage_account.datadog.name
  storage_container_name = azurerm_storage_container.deployments_datadog.name
  type                   = "Block"
  source                 = data.archive_file.app_code_datadog.output_path
  content_md5            = data.archive_file.app_code_datadog.output_md5
  metadata = {
    sha = data.archive_file.app_code_datadog.output_sha
  }
}
