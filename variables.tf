variable "cosmos_account_name" {
  description = "Name of the Cosmos DB account. If null, will be auto-generated."
  type        = string
  default     = null
}

variable "naming_prefix" {
  description = "Prefix for Cosmos DB naming"
  type        = string
  default     = "cosmos"
}

variable "environment" {
  description = "Environment name (e.g., prod, dev, test)"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "offer_type" {
  description = "Cosmos DB offer type"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard"], var.offer_type)
    error_message = "Offer type must be Standard."
  }
}

variable "kind" {
  description = "Cosmos DB account kind"
  type        = string
  default     = "GlobalDocumentDB"
  validation {
    condition     = contains(["GlobalDocumentDB", "MongoDB", "Parse"], var.kind)
    error_message = "Kind must be GlobalDocumentDB, MongoDB, or Parse."
  }
}

variable "consistency_policy" {
  description = "Consistency policy configuration"
  type = object({
    consistency_level       = string
    max_interval_in_seconds = optional(number)
    max_staleness_prefix    = optional(number)
  })
  default = {
    consistency_level = "Session"
  }
  validation {
    condition = contains([
      "BoundedStaleness", "ConsistentPrefix", "Eventual", "Session", "Strong"
    ], var.consistency_policy.consistency_level)
    error_message = "Consistency level must be one of: BoundedStaleness, ConsistentPrefix, Eventual, Session, Strong."
  }
}

variable "geo_locations" {
  description = "List of geo-locations for the Cosmos DB account"
  type = list(object({
    location          = string
    failover_priority = number
    zone_redundant    = optional(bool, false)
  }))
  default = []
}

variable "capabilities" {
  description = "List of capabilities to enable"
  type        = list(string)
  default     = []
}

variable "backup_policy" {
  description = "Backup policy configuration"
  type = object({
    type                = string
    interval_in_minutes = optional(number)
    retention_in_hours  = optional(number)
    storage_redundancy  = optional(string)
  })
  default = null
}

variable "analytical_storage_enabled" {
  description = "Enable analytical storage"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = false
}

variable "virtual_network_rules" {
  description = "Virtual network rules"
  type = list(object({
    id                                   = string
    ignore_missing_vnet_service_endpoint = optional(bool, false)
  }))
  default = []
}

variable "ip_range_filter" {
  description = "IP range filter"
  type        = string
  default     = null
}

variable "identity_type" {
  description = "Type of Managed Identity"
  type        = string
  default     = "SystemAssigned"
  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "Must be SystemAssigned, UserAssigned, or 'SystemAssigned, UserAssigned'."
  }
}

variable "identity_ids" {
  description = "List of User Assigned Identity IDs"
  type        = list(string)
  default     = []
}

variable "customer_managed_key" {
  description = "Customer managed key configuration"
  type = object({
    key_vault_key_id = string
  })
  default = null
}

variable "analytical_storage" {
  description = "Analytical storage configuration"
  type = object({
    schema_type = string
  })
  default = null
}

variable "capacity" {
  description = "Capacity configuration"
  type = object({
    total_throughput_limit = number
  })
  default = null
}

variable "local_authentication_disabled" {
  description = "Disable local authentication"
  type        = bool
  default     = false
}

variable "enable_multiple_write_locations" {
  description = "Enable multiple write locations"
  type        = bool
  default     = false
}

variable "enable_free_tier" {
  description = "Enable free tier"
  type        = bool
  default     = false
}

variable "enable_automatic_failover" {
  description = "Enable automatic failover"
  type        = bool
  default     = true
}

variable "access_key_metadata_writes_enabled" {
  description = "Enable access key metadata writes"
  type        = bool
  default     = true
}

variable "partition_merge_enabled" {
  description = "Enable partition merge"
  type        = bool
  default     = false
}

variable "burst_capacity_enabled" {
  description = "Enable burst capacity"
  type        = bool
  default     = false
}

variable "sql_databases" {
  description = "SQL databases configuration (for SQL API)"
  type = map(object({
    throughput = optional(number)

    autoscale_settings = optional(object({
      max_throughput = number
    }))
  }))
  default = {}
}

variable "sql_containers" {
  description = "SQL containers configuration (for SQL API)"
  type = map(object({
    database_name         = string
    partition_key_path    = string
    partition_key_version = optional(number)
    throughput            = optional(number)

    autoscale_settings = optional(object({
      max_throughput = number
    }))

    indexing_policy = optional(object({
      indexing_mode = optional(string, "consistent")

      included_paths = optional(list(object({
        path = string
      })), [])

      excluded_paths = optional(list(object({
        path = string
      })), [])

      composite_indexes = optional(list(object({
        indexes = list(object({
          path  = string
          order = string
        }))
      })), [])

      spatial_indexes = optional(list(object({
        path = string
      })), [])
    }))

    unique_keys = optional(list(object({
      paths = list(string)
    })), [])

    conflict_resolution_policy = optional(object({
      mode                          = string
      conflict_resolution_path      = optional(string)
      conflict_resolution_procedure = optional(string)
    }))
  }))
  default = {}
}

variable "mongo_databases" {
  description = "MongoDB databases configuration (for MongoDB API)"
  type = map(object({
    throughput = optional(number)

    autoscale_settings = optional(object({
      max_throughput = number
    }))
  }))
  default = {}
}

variable "mongo_collections" {
  description = "MongoDB collections configuration (for MongoDB API)"
  type = map(object({
    database_name = string
    throughput    = optional(number)

    autoscale_settings = optional(object({
      max_throughput = number
    }))

    indexes = optional(list(object({
      keys   = list(string)
      unique = optional(bool, false)
    })), [])

    shard_key = optional(string)
  }))
  default = {}
}

variable "private_endpoints" {
  description = "Private endpoint configurations"
  type = object({
    cosmosdb = optional(object({
      subnet_id            = string
      private_dns_zone_ids = optional(list(string))
    }))
  })
  default = {}
}

variable "enable_notebook_workspace" {
  description = "Enable notebook workspace"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}