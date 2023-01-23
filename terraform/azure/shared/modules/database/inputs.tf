variable "region" {
  type        = string
  description = "Azure region to deploy resources to"
}
variable "database_password" {
  type        = string
  description = "Password for the database"
  sensitive   = true
}

variable "create_mode" {
  type        = string
  description = "Create mode for the database"
}

variable "creation_source_server_id" {
  type        = string
  description = "Creation source server id for the database"
  default = null
}