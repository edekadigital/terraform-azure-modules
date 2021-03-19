
output "display_name" {
  value = azuread_service_principal.datadog.display_name
}

output "client_id" {
  value = azuread_application.datadog.application_id
}

output "client_secret" {
  value     = azuread_service_principal_password.datadog.value
  sensitive = true
}

output "object_id" {
  value = azuread_service_principal.datadog.id
}