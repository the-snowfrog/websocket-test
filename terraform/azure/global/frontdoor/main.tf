terraform {
  backend "azurerm" {
    resource_group_name  = "west-europe-terraform-group"
    storage_account_name = "westeuropeterraformsa"
    container_name       = "terraform"
    key                  = "frontdoor.tfstate"
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

resource "azurerm_resource_group" "my_front_door" {
  name     = "frontdoor-group"
  location = "westeurope"
}

resource "azurerm_cdn_frontdoor_profile" "my_front_door" {
  name                = "frontdoor-profile"
  resource_group_name = azurerm_resource_group.my_front_door.name
  sku_name            = "Standard_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_endpoint" "my_endpoint" {
  name                     = "frontdoor-test-123"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.my_front_door.id
}

resource "azurerm_cdn_frontdoor_origin_group" "my_origin_group" {
  name                     = "MyOriginGroup"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.my_front_door.id
  session_affinity_enabled = false

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    path                = "/"
    request_type        = "GET"
    protocol            = "Https"
    interval_in_seconds = 5
  }
}

resource "azurerm_cdn_frontdoor_origin" "northeurope" {
  name                          = "northeurope"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.my_origin_group.id

  enabled                        = true
  host_name                      = var.north_europe_default_hostname
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = var.north_europe_default_hostname
  priority                       = 1
  certificate_name_check_enabled = false
}

resource "azurerm_cdn_frontdoor_origin" "westeurope" {
  name                          = "westeurope"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.my_origin_group.id

  enabled                        = true
  host_name                      = var.west_europe_default_hostname
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = var.west_europe_default_hostname
  priority                       = 2
  certificate_name_check_enabled = false
}

resource "azurerm_cdn_frontdoor_route" "my_route" {
  name                          = "MyRoute"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.my_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.my_origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.northeurope.id, azurerm_cdn_frontdoor_origin.westeurope.id]

  supported_protocols    = ["Https"]
  patterns_to_match      = ["/"]
  forwarding_protocol    = "HttpsOnly"
  link_to_default_domain = true
  https_redirect_enabled = false
}