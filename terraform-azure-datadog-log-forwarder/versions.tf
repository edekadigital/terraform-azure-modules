terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = ">= 3.0.0"
    datadog = {
      version = ">= 3.0.0"
      source  = "DataDog/datadog"
    }
  }
}
