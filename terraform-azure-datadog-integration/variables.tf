variable "subscriptions" {
  type = list(string)
}

variable "tenant_id" {
  type = string
}

variable "password_expires_in" {
  type    = string
  default = "17520h" // 2 years
}