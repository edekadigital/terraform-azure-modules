variable "subscription_id" {}

terraform {
  required_providers {
    azurerm = ">= 2.48.0"
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}
