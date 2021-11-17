variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "vpc_id" {
  type = string
}

variable "sg_id" {
  type = string
}

variable "devops_org_token_secret_arn" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "agent_version" {
  type    = string
  default = "2.194.0"
}

data "amazon-ami" "ubuntu" {
  filters = {
    virtualization-type = "hvm"
    name                = "ubuntu/images/hvm-ssd/ubuntu-groovy-20.10-amd64-server-*"
    root-device-type    = "ebs"
  }
  owners      = ["099720109477"]
  most_recent = true
}

locals {
  source_ami_id   = data.amazon-ami.ubuntu.id
  source_ami_name = data.amazon-ami.ubuntu.name
  var_retrieval = templatefile("templates/aws-vars.pkrtpl.hcl", {
    SECRET_ID = var.devops_org_token_secret_arn
  })
}

source "amazon-ebs" "devops-agent" {
  ami_name                    = "az-devops-agent-{{timestamp}}"
  vpc_id                      = var.vpc_id
  instance_type               = "m5.large"
  region                      = var.region
  source_ami                  = local.source_ami_id
  ssh_username                = "ubuntu"
  ssh_clear_authorized_keys   = true
  encrypt_boot                = false
  associate_public_ip_address = true
  communicator                = "ssh"
  security_group_ids          = [var.sg_id]
  subnet_filter {
    filters = {
      "vpc-id" : "${var.vpc_id}",
      "tag:tier" : "public"
    }
    random = true
  }
  tags                  = var.tags
  run_tags              = var.tags
  force_deregister      = true
  force_delete_snapshot = true

}


build {
  sources = ["source.amazon-ebs.devops-agent"]

  provisioner "file" {
    content     = templatefile("templates/install-agent.pkrtpl.hcl", { RETRIEVE_PARAMETERS = local.var_retrieval })
    destination = "~/install-agent.sh" # we are not root so can't save directly to /var/lib/cloud/script/per-instance/
  }

  provisioner "shell" {
    environment_vars = [
      "AGENT_VERSION=${var.agent_version}"
    ]
    script = "scripts/install-base.sh"
  }
}

