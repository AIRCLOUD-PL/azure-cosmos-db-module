output "cosmosdb_account_id" {
  description = "Cosmos DB account ID"
  value       = azurerm_cosmosdb_account.main.id
}

output "cosmosdb_account_name" {
  description = "Cosmos DB account name"
  value       = azurerm_cosmosdb_account.main.name
}

output "cosmosdb_account_endpoint" {
  description = "Cosmos DB account endpoint"
  value       = azurerm_cosmosdb_account.main.endpoint
}

output "cosmosdb_account_read_endpoints" {
  description = "Cosmos DB account read endpoints"
  value       = azurerm_cosmosdb_account.main.read_endpoints
}

output "cosmosdb_account_write_endpoints" {
  description = "Cosmos DB account write endpoints"
  value       = azurerm_cosmosdb_account.main.write_endpoints
}

output "cosmosdb_account_primary_key" {
  description = "Cosmos DB account primary key"
  value       = azurerm_cosmosdb_account.main.primary_key
  sensitive   = true
}

output "cosmosdb_account_secondary_key" {
  description = "Cosmos DB account secondary key"
  value       = azurerm_cosmosdb_account.main.secondary_key
  sensitive   = true
}

output "cosmosdb_account_primary_readonly_key" {
  description = "Cosmos DB account primary readonly key"
  value       = azurerm_cosmosdb_account.main.primary_readonly_key
  sensitive   = true
}

output "cosmosdb_account_secondary_readonly_key" {
  description = "Cosmos DB account secondary readonly key"
  value       = azurerm_cosmosdb_account.main.secondary_readonly_key
  sensitive   = true
}

output "cosmosdb_account_connection_strings" {
  description = "CosmosDB account connection strings (deprecated in azurerm 4.x)"
  value       = []
  sensitive   = true
}

output "sql_databases" {
  description = "SQL databases"
  value       = azurerm_cosmosdb_sql_database.sql_databases
}

output "sql_containers" {
  description = "SQL containers"
  value       = azurerm_cosmosdb_sql_container.sql_containers
}

output "mongo_databases" {
  description = "MongoDB databases"
  value       = azurerm_cosmosdb_mongo_database.mongo_databases
}

output "mongo_collections" {
  description = "MongoDB collections"
  value       = azurerm_cosmosdb_mongo_collection.mongo_collections
}

output "identity" {
  description = "Managed identity block"
  value       = var.identity_type != null ? azurerm_cosmosdb_account.main.identity : null
}

output "identity_principal_id" {
  description = "Principal ID of the system-assigned managed identity"
  value       = var.identity_type != null ? azurerm_cosmosdb_account.main.identity[0].principal_id : null
}

output "private_endpoint_cosmosdb_id" {
  description = "Cosmos DB private endpoint ID"
  value       = var.private_endpoints.cosmosdb != null ? azurerm_private_endpoint.cosmosdb[0].id : null
}

output "notebook_workspace_id" {
  description = "Notebook workspace ID (deprecated in azurerm 4.x)"
  value       = null
}