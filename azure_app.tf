#Configure the azure providers
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.66.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
  }

  backend "azurerm" {
    resource_group_name = "StorageRG"
    storage_account_name = "taskboardstoragemims2026"
    container_name = "taskboardcontainer"
    key = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {
  }
  subscription_id = "3cfe4dd8-063d-41ba-9850-2f3e1d1af15d"
}


#Generate a random integer to create globally unique name
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# #Create a resource group
resource "azurerm_resource_group" "arg" {
  name     = "${var.resource_group_name}-${random_integer.ri.result}"
  location = var.resource_group_location
}

# #Create a Linux App Service Plan
resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.app_service_plan_name}-${random_integer.ri.result}"
  location            = azurerm_resource_group.arg.location
  resource_group_name = azurerm_resource_group.arg.name
  os_type             = "Linux"
  sku_name            = "F1"
}

# #Create the web app, pass the app service plan ID
resource "azurerm_linux_web_app" "alwa" {
  name                = "${var.web_app_name}-${random_integer.ri.result}"
  location            = azurerm_resource_group.arg.location
  resource_group_name = azurerm_resource_group.arg.name
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
    always_on = false
  }

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.sql_server.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.database.name};User ID=${azurerm_mssql_server.sql_server.administrator_login};Password=${azurerm_mssql_server.sql_server.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
  }
}

resource "azurerm_mssql_server" "sql_server" {
  name                         = "${var.sql_server_name}-${random_integer.ri.result}"
  resource_group_name          = azurerm_resource_group.arg.name
  location                     = azurerm_resource_group.arg.location
  version                      = "12.0"
  administrator_login          = "  ${var.sql_admin_username}"
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_mssql_database" "database" {
  name                 = "${var.sql_database_name}-${random_integer.ri.result}"
  server_id            = azurerm_mssql_server.sql_server.id
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  license_type         = "LicenseIncluded"
  max_size_gb          = 2
  sku_name             = "S0"
  zone_redundant       = false
  storage_account_type = "Local"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}


resource "azurerm_mssql_firewall_rule" "firewall_rule" {
  name             = "${var.firewall_rule}-${random_integer.ri.result}"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# #Deploy code from a public GitHub repository
resource "azurerm_app_service_source_control" "aassc" {
  app_id                 = azurerm_linux_web_app.alwa.id
  repo_url               = "https://github.com/MimsPeeva/Terraform2026"
  branch                 = "main"
  use_manual_integration = true
}