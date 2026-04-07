variable "resource_group_name" {
  type        = string
  description = "Resource group name in Azure"
}

variable "resource_group_location" {
  type        = string
  description = "Location of the resource group in Azure"
}

variable "app_service_plan_name" {
  type        = string
  description = "Name of the App Service Plan"
}

variable "web_app_name" {
  type        = string
  description = "Name of the Web App"
}

variable "sql_server_name" {
  type        = string
  description = "Name of the SQL Server"
}

variable "sql_database_name" {
  type        = string
  description = "Name of the SQL Database"
}

variable "sql_admin_username" {
  type        = string
  description = "Administrator username for the SQL Server"
}

variable "sql_admin_password" {
  type        = string
  description = "Administrator password for the SQL Server"
}

variable "firewall_rule" {
  type        = string
  description = "Firewall rule for the SQL Server"
}

variable "github_repo_url" {
  type        = string
  description = "URL of the GitHub repository to deploy code from"
}