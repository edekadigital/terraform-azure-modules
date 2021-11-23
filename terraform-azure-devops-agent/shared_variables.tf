variable "project_name_as_resource_prefix" {
  description = "Prefix for all the resource names"
  type        = string
}

variable "agent_name_prefix" {
  type = string
}

variable "devops_org_url" {
  type = string
}

variable "devops_agent_pool" {
  type = string
}

# variable "devops_pat" {
#   type = string
# }

# variable "devops_pat_secret_name" {
#   type        = string
#   description = <<EOF
#     Name of the secret to provision in AWS SecretManager and/or Azure KeyVault that will contain
#     the Azure Devops PAT with permissions to manage agents. Only alpha-numeric characters, dashes
#     and forward slashes are allowed. Forward slashes will be replaced with dashes in Azure KeyVault.
#   EOF
#   validation {
#     condition     = can(regex("^[a-zA-Z0-9-/]+$", var.devops_pat_secret_name))
#     error_message = "Secret name can only contain alphanumeric characters and the dash symbol ('-')."
#   }
# }