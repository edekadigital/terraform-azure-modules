# Assign monitoring reader role for subscriptions
resource "azurerm_role_assignment" "datadog" {
  for_each             = toset( var.subscriptions )
  scope                = "/subscriptions/" + each.value
  role_definition_name = "Monitoring Reader"
  principal_id         = azuread_service_principal.datadog.id

  depends_on = [
    azuread_service_principal.datadog
  ]
}

# Datadog Azure integration
resource "datadog_integration_azure" "shared" {
  tenant_name   = var.tenant_id
  client_id     = azuread_application.datadog.application_id
  client_secret = azuread_service_principal_password.datadog.value

  depends_on = [
    azuread_service_principal.datadog
  ]
}