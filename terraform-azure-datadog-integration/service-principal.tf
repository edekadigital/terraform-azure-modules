# az ad sp create-for-rbac --years 2
resource "random_id" "rbac" {
  byte_length = 8
  prefix      = "datadog-"
}

# Create Azure AD App
resource "azuread_application" "datadog" {
  display_name               = random_id.rbac.hex
  available_to_other_tenants = false
}

# Create Service Principal associated with the Azure AD App
resource "azuread_service_principal" "datadog" {
  application_id = azuread_application.datadog.application_id
}

# Generate random string to be used for Service Principal password
resource "random_string" "password" {
  length  = 32
  special = true
}

# Create Service Principal password
resource "azuread_service_principal_password" "datadog" {
  service_principal_id = azuread_service_principal.datadog.id
  value                = random_string.password.result
  end_date_relative    = var.password_expires_in
}