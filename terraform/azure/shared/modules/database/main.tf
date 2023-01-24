resource "azurerm_resource_group" "database" {
  name     = "${var.region}-database-group"
  location = var.region
}

resource "azurerm_postgresql_server" "database" {
  name                = "${var.region}-database-server"
  location            = azurerm_resource_group.database.location
  resource_group_name = azurerm_resource_group.database.name

  administrator_login          = "admin_user"
  administrator_login_password = var.database_password

  sku_name   = "GP_Gen5_2"
  version    = "11"
  storage_mb = 32768

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = false

  public_network_access_enabled    = true
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"

  create_mode = var.create_mode
  creation_source_server_id = var.creation_source_server_id
}

resource "azurerm_postgresql_database" "database" {
  count = var.create_mode == "Default" ? 1 : 0

  name                = "${var.region}-database"
  charset             = "UTF8"
  collation           = "English_United States.1252"
  resource_group_name = azurerm_resource_group.database.name
  server_name         = azurerm_postgresql_server.database.name
}

resource "azurerm_postgresql_firewall_rule" "database" {
  name                = "HomeOffice"
  resource_group_name = azurerm_resource_group.database.name
  server_name         = azurerm_postgresql_server.database.name
  start_ip_address    = "92.206.56.211"
  end_ip_address      = "92.206.56.211"
}