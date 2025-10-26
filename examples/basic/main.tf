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
  name     = "rg-cosmos-basic-example"
  location = "westeurope"
}

module "cosmos_db" {
  source = "../.."

  cosmos_account_name = "cosmos-basic-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  environment         = "test"
  kind                = "GlobalDocumentDB"

  geo_locations = [
    {
      location          = "westeurope"
      failover_priority = 0
    }
  ]

  tags = {
    Example = "Basic"
  }
}

output "cosmosdb_account_name" {
  value = module.cosmos_db.cosmosdb_account_name
}

output "cosmosdb_account_endpoint" {
  value = module.cosmos_db.cosmosdb_account_endpoint
}