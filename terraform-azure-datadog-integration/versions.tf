terraform {
  required_version = "0.14.7"

  required_providers {
    azurerm = "2.47.0"
    datadog = {
      source = "DataDog/datadog"
    }
  }
}