variable "project_name_as_resource_prefix" {
  description = "Prefix for all the resource names"
  type        = string
}

variable "azure_devops_pat_keyvault_name" {
  type = string
}

variable "azure_devops_pat_keyvault_resource_grou" {
  type = string
}

variable "azure_devops_pat_secret_name" {
  type = string
}

variable "ssh_public_keys" {
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

variable "existing_resource_group" {
  type    = string
  default = ""
}

# variable "key_vault_name" {
#   type = string
# }

# variable "key_vault_rg_name" {
#   type = string
# }

# variable "azure_devops_pat_secret_name" {
#   type    = string
# }

# locals {
#   keyvault_devops_pat_secret_name = replace(var.devops_pat_secret_name, "/", "-")
#   resource_group_name             = var.existing_resource_group == "" ? data.resource_group_name.devops-agent.name : azurerm_resource_group.devops_agent.name
#   resource_group_location         = var.existing_resource_group == "" ? data.resource_group_name.devops-agent.location : azurerm_resource_group.devops_agent.location
# }
