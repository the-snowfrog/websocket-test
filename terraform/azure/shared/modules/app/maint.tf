resource "azurerm_resource_group" "app" {
  name     = "${var.region}-app-group"
  location = var.region
}

resource "azurerm_service_plan" "app" {
  name                = "${var.region}-app-plan"
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_linux_web_app" "app" {
  name                = "${var.region}-app"
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_service_plan.app.location
  service_plan_id     = azurerm_service_plan.app.id
  https_only          = true  

  site_config { 
    minimum_tls_version = "1.2"

    application_stack {
      dotnet_version = "7.0"
    }  
  }

  app_settings = {
    "Region" = var.region
  }
}