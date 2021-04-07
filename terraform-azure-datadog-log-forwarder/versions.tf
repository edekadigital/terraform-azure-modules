terraform {
  required_version = ">= 0.14.0"

  required_providers {
    azurerm = ">= 2.48.0"
    datadog = {
      source = "DataDog/datadog"
    }
  }
}
