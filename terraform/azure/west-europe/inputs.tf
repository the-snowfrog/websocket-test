variable "database_password" {
  type        = string
  description = "Password for the database"
  sensitive   = true
}

variable "primary_database_server_id" {
  type        = string
  description = "Primary database server id for the database server"
}