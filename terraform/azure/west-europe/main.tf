terraform {
  backend "azurerm" {
    resource_group_name  = "west-europe-terraform-group"
    storage_account_name = "westeuropeterraformsa"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.39.1"
    }
  }
}

provider "azurerm" {
  features {}
}

module "app" {
  source = "../shared/modules/app"
  region = "westeurope"
}