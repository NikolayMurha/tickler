# Масив публічних SSH ключів юзера від якого запускається ansible
variable "authorized_keys" {
  type = list(string)
}

# Авторизація Azure
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli
variable "azure_subscription_id" {
  type = string
  default = ""
}

variable "azure_tenant_id" {
  type = string
  default = ""
}

# Локаія інстансів
#  az account list-locations
#  az account list-locations | grep name
variable "azure_location" {
  type = string
  default = "japaneast"
}
# Кількість віртуалок
variable "azure_vm_count" {
  type = number
  default = 0
}

# Linode api токен
variable "linode_token" {
  type = string
  default = ""
}

# Linode регіон за змовчанням (покищо не використовується тому, що береться рандомно)
variable "linode_default_region" {
  type    = string
  default = "eu-west"
}

# Тип linode інстансу
variable "linode_node_type" {
  type = string
  default = "g6-nanode-1"
}

# Кількість Linode віртуалок
variable "linode_vm_count" {
  type = number
  default = 0
}

# Digitalocen API токен
variable "do_token" {
  type = string
  default = ""
}

# Digitalocen регіон
variable "do_region" {
  type = string
  default = "fra1"
}
# Розмір дроплету Digitalocen
variable "do_node_size" {
  type = string
  default = "s-1vcpu-1gb"
}

# Кількість дроплетів
variable "do_vm_count" {
  type = number
  default = 1
}


