variable "aws_devops_pat_secret_arn" {
  type = string
}

variable "aws_instance_count" {
  type = number
}

variable "aws_agent_base_image" {
  type    = string
  default = ""
  validation {
    condition     = can(regex("^ami-.*", var.aws_agent_base_image)) || var.image == ""
    error_message = "AMI image name must start with 'ami-'."
  }
}

variable "aws_tags" {
  type    = map(string)
  default = {}
}

locals {
  aws_instance_count = var.aws_agent_base_image == "" ? 0 : var.aws_instance_count
}