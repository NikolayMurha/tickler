variable "linode_token" {
  type = string
}

variable "azure_subscription_id" {
  type = string
}

variable "azure_tenant_id" {
  type = string
}


variable "linode_default_region" {
  type    = string
  default = "eu-west"
}

variable "authorized_keys" {
  type = list(string)
}

variable "do_token" {
  type = string
}

variable "azure_vm_count" {
  type = number
  default = 0
}

variable "linode_vm_count" {
  type = number
  default = 0
}

variable "do_vm_count" {
  type = number
  default = 0
}


