terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.80.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg-cosmos-complete-example"
  location = "westeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-cosmos-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "database" {
  name                 = "snet-database"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = ["Microsoft.AzureCosmosDB"]
}

resource "azurerm_private_dns_zone" "cosmos" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = azurerm_resource_group.example.name
}

module "cosmos_db" {
  source = "../.."

  cosmos_account_name = "cosmos-complete-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  environment         = "test"
  kind                = "GlobalDocumentDB"

  # Security
  public_network_access_enabled = false
  identity_type                 = "SystemAssigned"

  # Geo-redundancy
  enable_multiple_write_locations = true
  enable_automatic_failover       = true

  geo_locations = [
    {
      location          = "westeurope"
      failover_priority = 0
      zone_redundant    = true
    },
    {
      location          = "northeurope"
      failover_priority = 1
    }
  ]

  # Capabilities
  capabilities = [
    "EnableServerless",
    "EnableAnalyticalStorage"
  ]

  # Consistency
  consistency_policy = {
    consistency_level = "Session"
  }

  # Backup
  backup_policy = {
    type = "Continuous"
  }

  # Private Endpoints
  private_endpoints = {
    cosmosdb = {
      subnet_id = azurerm_subnet.database.id
      private_dns_zone_ids = [
        azurerm_private_dns_zone.cosmos.id
      ]
    }
  }

  # SQL Databases
  sql_databases = {
    "appdb" = {
      throughput = 400
    }
  }

  # SQL Containers
  sql_containers = {
    "users" = {
      database_name      = "appdb"
      partition_key_path = "/userId"
      throughput         = 400

      indexing_policy = {
        indexing_mode = "consistent"
        included_paths = [
          {
            path = "/*"
          }
        ]
        excluded_paths = [
          {
            path = "/_etag/?"
          }
        ]
      }
    }
  }

  # Notebook Workspace
  enable_notebook_workspace = true

  tags = {
    Example = "Complete"
  }
}

output "cosmosdb_account_id" {
  value = module.cosmos_db.cosmosdb_account_id
}

output "cosmosdb_account_name" {
  value = module.cosmos_db.cosmosdb_account_name
}

output "cosmosdb_account_endpoint" {
  value = module.cosmos_db.cosmosdb_account_endpoint
}

output "sql_databases" {
  value = module.cosmos_db.sql_databases
}

output "sql_containers" {
  value = module.cosmos_db.sql_containers
}

output "identity_principal_id" {
  value = module.cosmos_db.identity_principal_id
}

output "private_endpoint_cosmosdb_id" {
  value = module.cosmos_db.private_endpoint_cosmosdb_id
}