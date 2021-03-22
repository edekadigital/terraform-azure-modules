output "eventhub_authorization_rule_id" {
  value = data.azurerm_eventhub_namespace_authorization_rule.datadog.id
}
