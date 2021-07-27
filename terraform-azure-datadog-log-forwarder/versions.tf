terraform {
  required_version = ">= 0.14.0"

  required_providers {
    azurerm = ">= 2.48.0"
    datadog = {
      version = ">= 3.0.0"
      source  = "DataDog/datadog"
    }
  }
}
