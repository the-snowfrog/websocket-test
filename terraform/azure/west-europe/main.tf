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

module "databse" {
  source = "../shared/modules/database"
  region = "westeurope"
  database_password = var.database_password
  create_mode = "Replica"
  creation_source_server_id = var.primary_database_server_id
}