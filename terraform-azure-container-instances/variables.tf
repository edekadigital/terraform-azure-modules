variable "LOCATION" {
  description = "Where to deploy the container instances"
  default = "West Europe"
}

variable "RG_NAME" {
  description = "The name of the resource group"
  type = string
}

variable "TAGS" {
  description = "Which tags should each resource receive"
  type = map(string)
  default = {}
}

variable "IMAGE_TAG" {
  description = "The image:tag that you want to deploy, e.g. my-image:latest"
  type = string
}

variable "ACI_NAME" {
  description = "The name of the container instances"
  type = string
}

variable "ACI_COMMANDS" {
  description = "A list of startup commands for the docker image"
  type = list(string)
}

variable "CPU" {
  default = "1.0"
}

variable "MEMORY" {
  default = "1.5"
}

variable "RESTART_POLICY" {
  default = "Never"
}

variable "IMAGE_REGISTRY_USERNAME" {
  type = string
}

variable "IMAGE_REGISTRY_PASSWORD" {
  type = string
}

variable "IMAGE_REGISTRY_SERVER" {
  type = string
}

variable "ACI_SUBNET" {
  description = "The name of the subnet"
  type = string
}

variable "ACI_SUBNET_ADDRESS_PREFIX" {
  description = "The ip address range"
  type = string
}

variable "ACI_SUBNET_DELEGATION_NAME" {
  type = string
  description = "The name of the service delegation in the subnet"
}

variable "VIRTUAL_NETWORK_NAME" {
  description = "The name of the virtual network for the resource group"
  type = string
}

variable "ACI_NETWORK_PROFILE" {
  description = "The name of the Network Profile"
  type = string
}

variable "ACI_NETWORK_PROFILE_CONTAINER_NETWORK_INTERFACE_NAME" {
  description = "The name of the Network Profile's container network interface"
  type = string
}

variable "ACI_NETWORK_PROFILE_IP_CONFIGURATION_NAME" {
  description = "The name of the Network Profile's ip configuration"
  type = string
}