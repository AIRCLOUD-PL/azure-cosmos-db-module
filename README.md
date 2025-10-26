# Azure Cosmos DB Terraform Module

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

### Basic Example

```hcl
module "cosmos_db" {
  source = "github.com/AIRCLOUD-PL/terraform-azurerm-cosmos-db?ref=v1.0.0"

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
  source = "github.com/AIRCLOUD-PL/terraform-azurerm-cosmos-db?ref=v1.0.0"

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
  source = "github.com/AIRCLOUD-PL/terraform-azurerm-cosmos-db?ref=v1.0.0"

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

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | >= 3.80.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.80.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| location | Azure region | `string` | n/a | yes |
| resource_group_name | Resource group name | `string` | n/a | yes |
| environment | Environment name | `string` | n/a | yes |
| kind | Cosmos DB API type | `string` | GlobalDocumentDB | no |
| geo_locations | Geo-locations config | `list(object)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| cosmosdb_account_id | Cosmos DB account ID |
| cosmosdb_account_name | Cosmos DB account name |
| cosmosdb_account_endpoint | Cosmos DB endpoint |
| connection_strings | Connection strings |

## Examples

- [Basic](./examples/basic/) - Simple Cosmos DB account
- [Complete](./examples/complete/) - Full enterprise features
- [MongoDB](./examples/mongodb/) - MongoDB API setup

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