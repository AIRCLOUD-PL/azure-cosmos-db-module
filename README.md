<p align="center">
  <a href="https://aircloud.com.pl"><img src=".github/assets/banner.png" alt="AIRCLOUD: DevOps, cloud and AI engineering" width="100%"></a>
</p>

# azure-cosmos-db-module

**Azure Cosmos DB Terraform module — parameterised, azurerm 4.x, CI-validated.**

[![CI](https://github.com/AIRCLOUD-PL/azure-cosmos-db-module/actions/workflows/ci.yml/badge.svg)](https://github.com/AIRCLOUD-PL/azure-cosmos-db-module/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/AIRCLOUD-PL/azure-cosmos-db-module?sort=semver)](https://github.com/AIRCLOUD-PL/azure-cosmos-db-module/releases)

Enterprise-grade Azure Cosmos DB module with comprehensive security, compliance, and performance features.

## Features

✅ **Multi-Model Support** - SQL, MongoDB, Cassandra, Gremlin, Table APIs  
✅ **Global Distribution** - Multi-region replication, automatic failover  
✅ **Advanced Security** - Customer-managed keys, private endpoints, threat protection  
✅ **High Performance** - Serverless, autoscale, burst capacity  
✅ **Backup & Recovery** - Continuous backup, point-in-time restore  
✅ **Analytics** - Synapse Link, analytical storage  
✅ **Compliance** - Azure Policy integration, audit logging  
✅ **Identity** - Azure AD authentication, managed identities  

## Usage

Pin the module to a release tag:

```hcl
module "cosmos_db" {
  source = "git::https://github.com/AIRCLOUD-PL/azure-cosmos-db-module.git?ref=v1.0.0"

  # required inputs
  environment         = "..."
  location            = "..."
  resource_group_name = "..."
}
```

All inputs and outputs are listed in the generated reference below ([Inputs](#inputs), [Outputs](#outputs)). Worked examples live in [`examples/`](examples/).

### Basic Example

```hcl
module "cosmos_db" {
  source = "git::https://github.com/AIRCLOUD-PL/azure-cosmos-db-module.git?ref=v1.0.0"

  cosmos_account_name = "cosmos-prod-westeurope-001"
  location           = "westeurope"
  resource_group_name = "rg-production"
  environment        = "prod"
  kind              = "GlobalDocumentDB"

  geo_locations = [
    {
      location          = "westeurope"
      failover_priority = 0
    }
  ]

  tags = {
    Environment = "Production"
  }
}
```

### Complete Example with SQL API

```hcl
module "cosmos_db" {
  source = "git::https://github.com/AIRCLOUD-PL/azure-cosmos-db-module.git?ref=v1.0.0"

  cosmos_account_name = "cosmos-prod-westeurope-001"
  location           = "westeurope"
  resource_group_name = "rg-production"
  environment        = "prod"
  kind              = "GlobalDocumentDB"

  # Security
  public_network_access_enabled = false
  identity_type                = "SystemAssigned"

  # Geo-redundancy
  enable_multiple_write_locations = true
  enable_automatic_failover      = true

  geo_locations = [
    {
      location          = "westeurope"
      failover_priority = 0
      zone_redundant    = true
    },
    {
      location          = "northeurope"
      failover_priority = 1
    },
    {
      location          = "eastus"
      failover_priority = 2
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

  # Customer-managed encryption
  customer_managed_key = {
    key_vault_key_id = azurerm_key_vault_key.cosmos.id
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
    "analytics" = {
      autoscale_settings = {
        max_throughput = 4000
      }
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

      unique_keys = [
        {
          paths = ["/email"]
        }
      ]
    }

    "orders" = {
      database_name      = "appdb"
      partition_key_path = "/orderId"
      throughput         = 1000

      conflict_resolution_policy = {
        mode                     = "LastWriterWins"
        conflict_resolution_path = "/_ts"
      }
    }
  }

  # Notebook Workspace
  enable_notebook_workspace = true

  tags = {
    Environment = "Production"
    DataClass   = "Confidential"
    Compliance  = "SOX"
  }
}
```

### MongoDB API Example

```hcl
module "cosmos_mongo" {
  source = "git::https://github.com/AIRCLOUD-PL/azure-cosmos-db-module.git?ref=v1.0.0"

  cosmos_account_name = "cosmos-mongo-prod-westeurope-001"
  location           = "westeurope"
  resource_group_name = "rg-production"
  environment        = "prod"
  kind              = "MongoDB"

  geo_locations = [
    {
      location          = "westeurope"
      failover_priority = 0
    }
  ]

  capabilities = [
    "EnableMongo"
  ]

  mongo_databases = {
    "ecommerce" = {
      throughput = 400
    }
  }

  mongo_collections = {
    "products" = {
      database_name = "ecommerce"
      throughput    = 400

      indexes = [
        {
          keys   = ["category", "price"]
          unique = false
        },
        {
          keys   = ["sku"]
          unique = true
        }
      ]

      shard_key = "category"
    }
  }

  tags = {
    Environment = "Production"
  }
}
```

## Examples

- [Basic](./examples/basic/) - Simple Cosmos DB account
- [Complete](./examples/complete/) - Full enterprise features
- [MongoDB](examples/) - MongoDB API setup

## Security Features

### Data Protection
- **Customer-Managed Keys** - Full encryption control
- **Advanced Threat Protection** - Real-time security monitoring
- **Private Endpoints** - Secure private connectivity
- **Network Isolation** - VNet integration, IP filtering

### High Availability
- **Multi-Region Replication** - Global distribution
- **Automatic Failover** - Zero-downtime failover
- **Zone Redundancy** - Cross-zone replication
- **Multi-Write Regions** - Active-active replication

### Performance & Scalability
- **Autoscale** - Automatic throughput scaling
- **Serverless** - Pay-per-request model
- **Burst Capacity** - Handle traffic spikes
- **Partitioning** - Efficient data distribution

### Compliance & Governance
- **Azure Policy** - Automated compliance
- **Audit Logging** - Comprehensive audit trails
- **Resource Locks** - Prevent accidental deletion
- **Backup Encryption** - Secure backup data

## Version

Current version: **v1.0.0**

## License

MIT

## Reference

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.81.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_cosmosdb_account.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_account) | resource |
| [azurerm_cosmosdb_mongo_collection.mongo_collections](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_mongo_collection) | resource |
| [azurerm_cosmosdb_mongo_database.mongo_databases](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_mongo_database) | resource |
| [azurerm_cosmosdb_sql_container.sql_containers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_container) | resource |
| [azurerm_cosmosdb_sql_database.sql_databases](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cosmosdb_sql_database) | resource |
| [azurerm_private_endpoint.cosmosdb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group_policy_assignment.cosmos_encryption](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.cosmos_geo_redundancy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.cosmos_secure_connections](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.cosmos_threat_protection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_key_metadata_writes_enabled"></a> [access\_key\_metadata\_writes\_enabled](#input\_access\_key\_metadata\_writes\_enabled) | Enable access key metadata writes | `bool` | `true` | no |
| <a name="input_analytical_storage"></a> [analytical\_storage](#input\_analytical\_storage) | Analytical storage configuration | <pre>object({<br/>    schema_type = string<br/>  })</pre> | `null` | no |
| <a name="input_analytical_storage_enabled"></a> [analytical\_storage\_enabled](#input\_analytical\_storage\_enabled) | Enable analytical storage | `bool` | `false` | no |
| <a name="input_backup_policy"></a> [backup\_policy](#input\_backup\_policy) | Backup policy configuration | <pre>object({<br/>    type                = string<br/>    interval_in_minutes = optional(number)<br/>    retention_in_hours  = optional(number)<br/>    storage_redundancy  = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_burst_capacity_enabled"></a> [burst\_capacity\_enabled](#input\_burst\_capacity\_enabled) | Enable burst capacity | `bool` | `false` | no |
| <a name="input_capabilities"></a> [capabilities](#input\_capabilities) | List of capabilities to enable | `list(string)` | `[]` | no |
| <a name="input_capacity"></a> [capacity](#input\_capacity) | Capacity configuration | <pre>object({<br/>    total_throughput_limit = number<br/>  })</pre> | `null` | no |
| <a name="input_consistency_policy"></a> [consistency\_policy](#input\_consistency\_policy) | Consistency policy configuration | <pre>object({<br/>    consistency_level       = string<br/>    max_interval_in_seconds = optional(number)<br/>    max_staleness_prefix    = optional(number)<br/>  })</pre> | <pre>{<br/>  "consistency_level": "Session"<br/>}</pre> | no |
| <a name="input_cosmos_account_name"></a> [cosmos\_account\_name](#input\_cosmos\_account\_name) | Name of the Cosmos DB account. If null, will be auto-generated. | `string` | `null` | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | Customer managed key configuration | <pre>object({<br/>    key_vault_key_id = string<br/>  })</pre> | `null` | no |
| <a name="input_enable_automatic_failover"></a> [enable\_automatic\_failover](#input\_enable\_automatic\_failover) | Enable automatic failover | `bool` | `true` | no |
| <a name="input_enable_free_tier"></a> [enable\_free\_tier](#input\_enable\_free\_tier) | Enable free tier | `bool` | `false` | no |
| <a name="input_enable_multiple_write_locations"></a> [enable\_multiple\_write\_locations](#input\_enable\_multiple\_write\_locations) | Enable multiple write locations | `bool` | `false` | no |
| <a name="input_enable_notebook_workspace"></a> [enable\_notebook\_workspace](#input\_enable\_notebook\_workspace) | Enable notebook workspace | `bool` | `false` | no |
| <a name="input_enable_policy_assignments"></a> [enable\_policy\_assignments](#input\_enable\_policy\_assignments) | Enable Azure Policy assignments for this Cosmos DB | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., prod, dev, test) | `string` | n/a | yes |
| <a name="input_geo_locations"></a> [geo\_locations](#input\_geo\_locations) | List of geo-locations for the Cosmos DB account | <pre>list(object({<br/>    location          = string<br/>    failover_priority = number<br/>    zone_redundant    = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | List of User Assigned Identity IDs | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | Type of Managed Identity | `string` | `"SystemAssigned"` | no |
| <a name="input_ip_range_filter"></a> [ip\_range\_filter](#input\_ip\_range\_filter) | IP range filter | `string` | `null` | no |
| <a name="input_kind"></a> [kind](#input\_kind) | Cosmos DB account kind | `string` | `"GlobalDocumentDB"` | no |
| <a name="input_local_authentication_disabled"></a> [local\_authentication\_disabled](#input\_local\_authentication\_disabled) | Disable local authentication | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region where resources will be created | `string` | n/a | yes |
| <a name="input_mongo_collections"></a> [mongo\_collections](#input\_mongo\_collections) | MongoDB collections configuration (for MongoDB API) | <pre>map(object({<br/>    database_name = string<br/>    throughput    = optional(number)<br/><br/>    autoscale_settings = optional(object({<br/>      max_throughput = number<br/>    }))<br/><br/>    indexes = optional(list(object({<br/>      keys   = list(string)<br/>      unique = optional(bool, false)<br/>    })), [])<br/><br/>    shard_key = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_mongo_databases"></a> [mongo\_databases](#input\_mongo\_databases) | MongoDB databases configuration (for MongoDB API) | <pre>map(object({<br/>    throughput = optional(number)<br/><br/>    autoscale_settings = optional(object({<br/>      max_throughput = number<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_naming_prefix"></a> [naming\_prefix](#input\_naming\_prefix) | Prefix for Cosmos DB naming | `string` | `"cosmos"` | no |
| <a name="input_offer_type"></a> [offer\_type](#input\_offer\_type) | Cosmos DB offer type | `string` | `"Standard"` | no |
| <a name="input_partition_merge_enabled"></a> [partition\_merge\_enabled](#input\_partition\_merge\_enabled) | Enable partition merge | `bool` | `false` | no |
| <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints) | Private endpoint configurations | <pre>object({<br/>    cosmosdb = optional(object({<br/>      subnet_id            = string<br/>      private_dns_zone_ids = optional(list(string))<br/>    }))<br/>  })</pre> | `{}` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Enable public network access | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_sql_containers"></a> [sql\_containers](#input\_sql\_containers) | SQL containers configuration (for SQL API) | <pre>map(object({<br/>    database_name         = string<br/>    partition_key_path    = string<br/>    partition_key_version = optional(number)<br/>    throughput            = optional(number)<br/><br/>    autoscale_settings = optional(object({<br/>      max_throughput = number<br/>    }))<br/><br/>    indexing_policy = optional(object({<br/>      indexing_mode = optional(string, "consistent")<br/><br/>      included_paths = optional(list(object({<br/>        path = string<br/>      })), [])<br/><br/>      excluded_paths = optional(list(object({<br/>        path = string<br/>      })), [])<br/><br/>      composite_indexes = optional(list(object({<br/>        indexes = list(object({<br/>          path  = string<br/>          order = string<br/>        }))<br/>      })), [])<br/><br/>      spatial_indexes = optional(list(object({<br/>        path = string<br/>      })), [])<br/>    }))<br/><br/>    unique_keys = optional(list(object({<br/>      paths = list(string)<br/>    })), [])<br/><br/>    conflict_resolution_policy = optional(object({<br/>      mode                          = string<br/>      conflict_resolution_path      = optional(string)<br/>      conflict_resolution_procedure = optional(string)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_sql_databases"></a> [sql\_databases](#input\_sql\_databases) | SQL databases configuration (for SQL API) | <pre>map(object({<br/>    throughput = optional(number)<br/><br/>    autoscale_settings = optional(object({<br/>      max_throughput = number<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_virtual_network_rules"></a> [virtual\_network\_rules](#input\_virtual\_network\_rules) | Virtual network rules | <pre>list(object({<br/>    id                                   = string<br/>    ignore_missing_vnet_service_endpoint = optional(bool, false)<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cosmosdb_account_connection_strings"></a> [cosmosdb\_account\_connection\_strings](#output\_cosmosdb\_account\_connection\_strings) | CosmosDB account connection strings (deprecated in azurerm 4.x) |
| <a name="output_cosmosdb_account_endpoint"></a> [cosmosdb\_account\_endpoint](#output\_cosmosdb\_account\_endpoint) | Cosmos DB account endpoint |
| <a name="output_cosmosdb_account_id"></a> [cosmosdb\_account\_id](#output\_cosmosdb\_account\_id) | Cosmos DB account ID |
| <a name="output_cosmosdb_account_name"></a> [cosmosdb\_account\_name](#output\_cosmosdb\_account\_name) | Cosmos DB account name |
| <a name="output_cosmosdb_account_primary_key"></a> [cosmosdb\_account\_primary\_key](#output\_cosmosdb\_account\_primary\_key) | Cosmos DB account primary key |
| <a name="output_cosmosdb_account_primary_readonly_key"></a> [cosmosdb\_account\_primary\_readonly\_key](#output\_cosmosdb\_account\_primary\_readonly\_key) | Cosmos DB account primary readonly key |
| <a name="output_cosmosdb_account_read_endpoints"></a> [cosmosdb\_account\_read\_endpoints](#output\_cosmosdb\_account\_read\_endpoints) | Cosmos DB account read endpoints |
| <a name="output_cosmosdb_account_secondary_key"></a> [cosmosdb\_account\_secondary\_key](#output\_cosmosdb\_account\_secondary\_key) | Cosmos DB account secondary key |
| <a name="output_cosmosdb_account_secondary_readonly_key"></a> [cosmosdb\_account\_secondary\_readonly\_key](#output\_cosmosdb\_account\_secondary\_readonly\_key) | Cosmos DB account secondary readonly key |
| <a name="output_cosmosdb_account_write_endpoints"></a> [cosmosdb\_account\_write\_endpoints](#output\_cosmosdb\_account\_write\_endpoints) | Cosmos DB account write endpoints |
| <a name="output_identity"></a> [identity](#output\_identity) | Managed identity block |
| <a name="output_identity_principal_id"></a> [identity\_principal\_id](#output\_identity\_principal\_id) | Principal ID of the system-assigned managed identity |
| <a name="output_mongo_collections"></a> [mongo\_collections](#output\_mongo\_collections) | MongoDB collections |
| <a name="output_mongo_databases"></a> [mongo\_databases](#output\_mongo\_databases) | MongoDB databases |
| <a name="output_notebook_workspace_id"></a> [notebook\_workspace\_id](#output\_notebook\_workspace\_id) | Notebook workspace ID (deprecated in azurerm 4.x) |
| <a name="output_private_endpoint_cosmosdb_id"></a> [private\_endpoint\_cosmosdb\_id](#output\_private\_endpoint\_cosmosdb\_id) | Cosmos DB private endpoint ID |
| <a name="output_sql_containers"></a> [sql\_containers](#output\_sql\_containers) | SQL containers |
| <a name="output_sql_databases"></a> [sql\_databases](#output\_sql\_databases) | SQL databases |
<!-- END_TF_DOCS -->

---

## Part of the AIRCLOUD Azure module catalog

Browse all modules with usage snippets in the [module catalog](https://aircloud-pl.github.io/) or on [github.com/AIRCLOUD-PL](https://github.com/AIRCLOUD-PL). Built and maintained by [AIRCLOUD](https://aircloud.com.pl): DevOps, cloud and AI engineering. Need a hand with Azure landing zones or platform engineering? See [aircloud.com.pl/consulting](https://aircloud.com.pl/consulting).
