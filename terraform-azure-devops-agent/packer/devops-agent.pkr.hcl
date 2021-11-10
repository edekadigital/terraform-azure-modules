variable "region" {
  default = "eu-central-1"
}

variable "vpc_id" {
  default = ""
}

variable "sg_id" {
  default = ""
}

variable "devops_org_token" {
  default = "IMNOTATOKEN"
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
}

source "file" "example" {
  content = "example content"
}

source "amazon-ebs" "ssm-example" {
  ami_name                    = "az-devops-agent-{{timestamp}}"
  vpc_id                      = var.vpc_id
  instance_type               = "m5.large"
  region                      = var.region
  source_ami                  = data.amazon-ami.ubuntu.id
  ssh_username                = "ubuntu"
  ssh_clear_authorized_keys   = true
  encrypt_boot                = false
  associate_public_ip_address = true
  communicator                = "ssh"
  security_group_ids          = [var.sg_id]
  # temporary_iam_instance_profile_policy_document {
  #   Version = "2012-10-17"
  #   Statement {
  #     Action   = ["ssm:GetParameter"]
  #     Effect   = "Allow"
  #     Resource = ["arn:aws:ssm:*:*:parameter/azure-devops/*"]
  #   }
  # }
  subnet_filter {
    filters = {
      "vpc-id" : "${var.vpc_id}",
      "tag:tier" : "public"
    }
    random = true
  }
  tags = {
    "Name" : "azure-devops",
    "service" : "azure-devops",
    "team" : "thundercats"
  }
  run_tags = {
    "Name" : "azure-devops",
    "service" : "azure-devops",
    "team" : "thundercats"
  }
  force_deregister      = true
  force_delete_snapshot = true

}


build {
  sources = ["source.amazon-ebs.ssm-example"]

  provisioner "file" {
    content     = templatefile("${path.root}/templates/install-agent.pkrtpl.hcl", {})
    destination = "~/install-agent.sh" # we are not root so can't save directly to /var/lib/cloud/script/per-instance/
  }

  provisioner "shell" {
    script = "scripts/install-base.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo ls -al /var/lib/cloud/scripts/per-instance/"
      #"sudo cat /var/lib/cloud/scripts/per-instance/install-agent.sh"
    ]
  }

}

