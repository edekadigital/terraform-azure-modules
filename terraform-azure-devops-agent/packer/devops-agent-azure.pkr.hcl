variable "client_id" {
  default = ""
}

variable "client_secret" {
  default = ""
}

variable "tenant_id" {
  default = ""
}

variable "subscription_id" {
  default = ""
}

variable "rg_name" {
  default = ""
}

variable "vault_name" {
  default = "crm-shared-kv"
}

variable "secret_name" {
  default = "eddi-crm-azure-devops-manage-agents-pat"
}

variable "devops_org_token" {
  default = "IMNOTATOKEN"
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
  var_retrieval = templatefile("${path.root}/templates/azure-vars.pkrtpl.hcl", {
    VAULT_NAME = var.vault_name,
    SECRET_NAME = var.secret_name
  })
}

build {
  sources = ["source.azure-arm.devops-agent"]

  provisioner "file" {
    content     = templatefile("${path.root}/templates/install-agent.pkrtpl.hcl", { RETRIEVE_PARAMETERS = local.var_retrieval })
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

