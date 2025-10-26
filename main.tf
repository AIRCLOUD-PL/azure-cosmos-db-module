/**
 * # Azure Cosmos DB Module
 *
 * Enterprise-grade Azure Cosmos DB module with comprehensive security, compliance, and performance features.
 *
 * ## Features
 * - Multi-model databases (SQL, MongoDB, Cassandra, Gremlin, Table)
 * - Global distribution and geo-redundancy
 * - Advanced security (encryption, private endpoints, threat protection)
 * - Backup and restore capabilities
 * - Performance monitoring and alerting
 * - Azure Policy integration
 * - Multi-region write support
 */

locals {
  # Auto-generate Cosmos DB account name if not provided
  cosmos_account_name = var.cosmos_account_name != null ? var.cosmos_account_name : "${var.naming_prefix}${var.environment}${replace(var.location, "-", "")}cosmos"

  # Default tags
  default_tags = {
    ManagedBy   = "Terraform"
    Module      = "azure-cosmos-db"
    Environment = var.environment
  }

  tags = merge(local.default_tags, var.tags)
}

# Cosmos DB Account
resource "azurerm_cosmosdb_account" "main" {
  name                = local.cosmos_account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = var.offer_type
  kind                = var.kind

  # Consistency Policy
  consistency_policy {
    consistency_level       = var.consistency_policy.consistency_level
    max_interval_in_seconds = try(var.consistency_policy.max_interval_in_seconds, null)
    max_staleness_prefix    = try(var.consistency_policy.max_staleness_prefix, null)
  }

  # Geo-Location
  dynamic "geo_location" {
    for_each = var.geo_locations
    content {
      location          = geo_location.value.location
      failover_priority = geo_location.value.failover_priority
      zone_redundant    = try(geo_location.value.zone_redundant, false)
    }
  }

  # Capabilities
  dynamic "capabilities" {
    for_each = var.capabilities
    content {
      name = capabilities.value
    }
  }

  # Backup Policy
  dynamic "backup" {
    for_each = var.backup_policy != null ? [var.backup_policy] : []
    content {
      type                = backup.value.type
      interval_in_minutes = try(backup.value.interval_in_minutes, null)
      retention_in_hours  = try(backup.value.retention_in_hours, null)
      storage_redundancy  = try(backup.value.storage_redundancy, null)
    }
  }

  # Analytical Storage
  analytical_storage_enabled = var.analytical_storage_enabled

  # Public Network Access
  public_network_access_enabled = var.public_network_access_enabled

  # Network ACLs
  dynamic "virtual_network_rule" {
    for_each = var.virtual_network_rules
    content {
      id                                   = virtual_network_rule.value.id
      ignore_missing_vnet_service_endpoint = try(virtual_network_rule.value.ignore_missing_vnet_service_endpoint, false)
    }
  }

  # IP Range Filter
  ip_range_filter = var.ip_range_filter != null && var.ip_range_filter != "" ? [var.ip_range_filter] : []

  # Identity
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned" ? var.identity_ids : null
    }
  }

  # Customer Managed Key (handled via identity and key_vault_key_id)
  key_vault_key_id = var.customer_managed_key != null ? var.customer_managed_key.key_vault_key_id : null

  # Analytical Storage Configuration
  dynamic "analytical_storage" {
    for_each = var.analytical_storage != null ? [var.analytical_storage] : []
    content {
      schema_type = analytical_storage.value.schema_type
    }
  }

  # Capacity
  dynamic "capacity" {
    for_each = var.capacity != null ? [var.capacity] : []
    content {
      total_throughput_limit = capacity.value.total_throughput_limit
    }
  }

  # Local Authentication
  local_authentication_disabled = var.local_authentication_disabled

  # Multiple Write Locations
  multiple_write_locations_enabled = var.enable_multiple_write_locations

  # Free Tier
  free_tier_enabled = var.enable_free_tier

  # Automatic Failover
  automatic_failover_enabled = var.enable_automatic_failover

  # Access Key Metadata Writes
  access_key_metadata_writes_enabled = var.access_key_metadata_writes_enabled

  # Partition Merge
  partition_merge_enabled = var.partition_merge_enabled

  # Burst Capacity
  burst_capacity_enabled = var.burst_capacity_enabled

  tags = local.tags
}

# SQL Databases (for SQL API)
resource "azurerm_cosmosdb_sql_database" "sql_databases" {
  for_each = var.kind == "GlobalDocumentDB" ? var.sql_databases : {}

  name                = each.key
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  throughput          = try(each.value.throughput, null)

  dynamic "autoscale_settings" {
    for_each = try(each.value.autoscale_settings, null) != null ? [each.value.autoscale_settings] : []
    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }
}

# SQL Containers (for SQL API)
resource "azurerm_cosmosdb_sql_container" "sql_containers" {
  for_each = var.kind == "GlobalDocumentDB" ? var.sql_containers : {}

  name                  = each.key
  resource_group_name   = var.resource_group_name
  account_name          = azurerm_cosmosdb_account.main.name
  database_name         = each.value.database_name
  partition_key_paths   = [each.value.partition_key_path]
  partition_key_version = try(each.value.partition_key_version, null)
  throughput            = try(each.value.throughput, null)

  dynamic "autoscale_settings" {
    for_each = try(each.value.autoscale_settings, null) != null ? [each.value.autoscale_settings] : []
    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }

  dynamic "indexing_policy" {
    for_each = try(each.value.indexing_policy, null) != null ? [each.value.indexing_policy] : []
    content {
      indexing_mode = try(indexing_policy.value.indexing_mode, "consistent")

      dynamic "included_path" {
        for_each = try(indexing_policy.value.included_paths, [])
        content {
          path = included_path.value.path
        }
      }

      dynamic "excluded_path" {
        for_each = try(indexing_policy.value.excluded_paths, [])
        content {
          path = excluded_path.value.path
        }
      }

      dynamic "composite_index" {
        for_each = try(indexing_policy.value.composite_indexes, [])
        content {
          dynamic "index" {
            for_each = composite_index.value.indexes
            content {
              path  = index.value.path
              order = index.value.order
            }
          }
        }
      }

      dynamic "spatial_index" {
        for_each = try(indexing_policy.value.spatial_indexes, [])
        content {
          path = spatial_index.value.path
        }
      }
    }
  }

  dynamic "unique_key" {
    for_each = try(each.value.unique_keys, [])
    content {
      paths = unique_key.value.paths
    }
  }

  dynamic "conflict_resolution_policy" {
    for_each = try(each.value.conflict_resolution_policy, null) != null ? [each.value.conflict_resolution_policy] : []
    content {
      mode                          = conflict_resolution_policy.value.mode
      conflict_resolution_path      = try(conflict_resolution_policy.value.conflict_resolution_path, null)
      conflict_resolution_procedure = try(conflict_resolution_policy.value.conflict_resolution_procedure, null)
    }
  }
}

# MongoDB Databases (for MongoDB API)
resource "azurerm_cosmosdb_mongo_database" "mongo_databases" {
  for_each = var.kind == "MongoDB" ? var.mongo_databases : {}

  name                = each.key
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  throughput          = try(each.value.throughput, null)

  dynamic "autoscale_settings" {
    for_each = try(each.value.autoscale_settings, null) != null ? [each.value.autoscale_settings] : []
    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }
}

# MongoDB Collections (for MongoDB API)
resource "azurerm_cosmosdb_mongo_collection" "mongo_collections" {
  for_each = var.kind == "MongoDB" ? var.mongo_collections : {}

  name                = each.key
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = each.value.database_name
  throughput          = try(each.value.throughput, null)

  dynamic "autoscale_settings" {
    for_each = try(each.value.autoscale_settings, null) != null ? [each.value.autoscale_settings] : []
    content {
      max_throughput = autoscale_settings.value.max_throughput
    }
  }

  dynamic "index" {
    for_each = try(each.value.indexes, [])
    content {
      keys   = index.value.keys
      unique = try(index.value.unique, false)
    }
  }

  shard_key = try(each.value.shard_key, null)
}

# Private Endpoints
resource "azurerm_private_endpoint" "cosmosdb" {
  count = var.private_endpoints.cosmosdb != null ? 1 : 0

  name                = "${azurerm_cosmosdb_account.main.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints.cosmosdb.subnet_id

  private_service_connection {
    name                           = "${azurerm_cosmosdb_account.main.name}-psc"
    private_connection_resource_id = azurerm_cosmosdb_account.main.id
    subresource_names              = ["Sql", "MongoDB", "Cassandra", "Gremlin", "Table"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_endpoints.cosmosdb.private_dns_zone_ids != null ? [1] : []
    content {
      name                 = "cosmosdb-dns-zone-group"
      private_dns_zone_ids = var.private_endpoints.cosmosdb.private_dns_zone_ids
    }
  }

  tags = local.tags
}

# Notebook Workspace
# Notebook workspace is no longer supported in azurerm provider 4.x
# resource "azurerm_cosmosdb_notebook_workspace" "main" {
#   count = var.enable_notebook_workspace ? 1 : 0
#
#   name                = "${azurerm_cosmosdb_account.main.name}-notebook"
#   resource_group_name = var.resource_group_name
#   account_name        = azurerm_cosmosdb_account.main.name
# }