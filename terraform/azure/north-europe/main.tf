terraform {
  backend "azurerm" {
    resource_group_name  = "north-europe-terraform-group"
    storage_account_name = "northeuropeterraformsa"
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
  region = "northeurope"
}

module "databse" {
  source = "../shared/modules/database"
  region = "northeurope"
  database_password = var.database_password
  create_mode = "Default"
}