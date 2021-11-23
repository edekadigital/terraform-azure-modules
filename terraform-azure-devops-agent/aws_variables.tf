variable "aws_devops_pat_secret_arn" {
  type = string
}

variable "aws_instance_count" {
  type = number
}

variable "aws_agent_base_image" {
  type    = string
  validation {
    condition     = can(regex("^ami-.*", var.aws_agent_base_image))
    error_message = "AMI image name must start with 'ami-'."
  }
}

