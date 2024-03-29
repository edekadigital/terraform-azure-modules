variable "azure_devops_pat_keyvault_name" {
  type = string
}

variable "azure_devops_pat_keyvault_resource_group" {
  type = string
}

variable "azure_devops_pat_secret_name" {
  type = string
}

variable "azure_ssh_public_keys" {
  type    = list(string)
  default = []
}

variable "azure_vm_instance_size" {
  type    = string
  default = "Standard_DS3_v2"
}

variable "azure_instance_count" {
  type = number
}

variable "azure_agent_image_id" {
  type = string
}

variable "azure_devops_agent_subnet_id" {
  type = string
}

variable "azure_existing_resource_group" {
  type    = string
  default = ""
}

variable "azure_resource_location" {
  description = "Azure location to deploy all the things"
  type        = string
  default     = "West Europe"
}

variable "azure_tags" {
  description = "Tags to attach to all created Azure Resources for the Devops Agents"
  type        = map(string)
  default     = {}
}

locals {
  resource_group_name     = var.azure_existing_resource_group == "" ? azurerm_resource_group.devops_agent[0].name : data.azurerm_resource_group.devops_agent[0].name
  resource_group_location = var.azure_existing_resource_group == "" ? azurerm_resource_group.devops_agent[0].location : data.azurerm_resource_group.devops_agent[0].location
  azure_instance_count    = var.azure_agent_image_id == "" ? 0 : var.azure_instance_count
}
