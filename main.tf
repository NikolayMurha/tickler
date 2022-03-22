provider "local" {

}
provider "linode" {
  token = var.linode_token
}

terraform {
#  experiments = [module_variable_optional_attrs]
  required_providers {
    linode = {
      source = "linode/linode"
      version = "1.25.0"
    }

    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.97.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.azure_subscription_id
  tenant_id = var.azure_tenant_id
}

provider "digitalocean" {
  token = var.do_token
}

resource "random_password" "password" {
  length           = 128
  special          = true
  override_special = "_%@"
}


resource "random_shuffle" "regions" {
  input        = ["eu-central", "ap-southeast", "ap-west", "us-west", "ca-central", "ap-northeast"]
  result_count = 1
}
