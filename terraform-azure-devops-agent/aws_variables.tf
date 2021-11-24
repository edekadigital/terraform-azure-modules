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
    condition     = can(regex("^ami-.*", var.aws_agent_base_image)) || var.aws_agent_base_image == ""
    error_message = "AMI image name must start with 'ami-'."
  }
}

variable "aws_tags" {
  type    = map(string)
  default = {}
}

variable "aws_instance_type" {
  type    = string
  default = "m5.xlarge"
}

variable "aws_ssh_key_name" {
  type    = string
  default = ""
}

variable "aws_subnet_id" {
  type = string
}

variable "aws_security_group_ids" {
  type    = list(string)
  default = []
}

variable "aws_role_policies" {
  type    = list(string)
  default = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
}

locals {
  aws_instance_count = var.aws_agent_base_image == "" ? 0 : var.aws_instance_count
}