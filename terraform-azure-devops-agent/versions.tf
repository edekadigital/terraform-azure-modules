variable "subscription_id" {
  default = ""
}

terraform {
  required_version = ">= 1.0.0"
  required_providers {
  }
}

provider "aws" {
  region = "eu-central-1"
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
