variable "client_id" {
  type = string
}

variable "client_secret" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "rg_name" {
  type = string
}

variable "vault_name" {
  type = string
}

variable "secret_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "devops_org_token" {
  type = string
}

source "azure-arm" "devops-agent" {
  client_id                 = var.client_id
  client_secret             = var.client_secret
  subscription_id           = var.subscription_id
  tenant_id                 = var.tenant_id
  communicator              = "ssh"
  ssh_username              = "ubuntu"
  ssh_clear_authorized_keys = true

  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-groovy"
  image_sku       = "20_10-gen2"

  managed_image_resource_group_name = var.rg_name
  managed_image_name                = "devops-agent-{{timestamp}}"
  vm_size                           = "Standard_DS2_v2"

  location = "West Europe"

}

locals {
  var_retrieval = templatefile("templates/azure-vars.pkrtpl.hcl", {
    VAULT_NAME  = var.vault_name,
    SECRET_NAME = var.secret_name
  })
}

build {
  sources = ["source.azure-arm.devops-agent"]

  provisioner "file" {
    content     = templatefile("templates/install-agent.pkrtpl.hcl", { RETRIEVE_PARAMETERS = local.var_retrieval })
    destination = "~/install-agent.sh" # we are not root so can't save directly to /var/lib/cloud/script/per-instance/
  }

  provisioner "shell" {
    script = "scripts/install-base.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo ls -al /var/lib/cloud/scripts/per-instance/",
      "sudo cat /var/lib/cloud/scripts/per-instance/install-agent.sh"
    ]
  }

}

