variable "prefix" {
  description = "Prefix for all the resource names"
  type        = string
}

variable "location" {
  description = "Azure location to deploy all the things"
  type        = string
  default     = "West Europe"
}

variable "sftp_user_name" {
  description = "sftp user"
  type        = string
}

variable "sftp_password" {
  description = "sftp pass"
  type        = string
  sensitive   = true
}

variable "sftp_quota" {
  type    = number
  default = 5120
}

variable "azure_tags" {
  description = "Tags to attach to all created Azure Resources for Log Forwarder"
  type        = map(string)
  default     = { template = "edekadigital:terraform-azure-sftp" }
}

locals {
  sftp_folder = "sftp"
}

variable "ssh_host_ed25519_key" {
  description = "your own generated ssh_host_ed25519_key"
  type        = string
  sensitive   = true
}

variable "ssh_host_rsa_key" {
  description = "your own generated ssh_host_rsa_key"
  type        = string
  sensitive   = true
}