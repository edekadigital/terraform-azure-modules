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

variable "agent_version" {
  type    = string
  default = "2.194.0"
}

variable "tags" {
  type    = map(string)
  default = {}
}

source "azure-arm" "devops-agent" {
  client_id                 = var.client_id
  client_secret             = var.client_secret
  subscription_id           = var.subscription_id
  tenant_id                 = var.tenant_id
  communicator              = "ssh"
  ssh_username              = "ubuntu"
  ssh_clear_authorized_keys = true
  azure_tags                = var.tags

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
  var_retrieval  = templatefile("templates/azure-vars.pkrtpl.hcl", {})
  scripts_folder = "${path.root}/scripts"
}

build {
  sources = ["source.azure-arm.devops-agent"]

  provisioner "file" {
    content     = templatefile("templates/install-agent.pkrtpl.hcl", { RETRIEVE_PARAMETERS = local.var_retrieval })
    destination = "~/install-agent.sh" # we are not root so can't save directly to /var/lib/cloud/script/per-instance/
  }

  provisioner "shell" {
    environment_vars = [
      "AGENT_VERSION=${var.agent_version}"
    ]
    script = "${local.scripts_folder}/install-base.sh"
  }
}

