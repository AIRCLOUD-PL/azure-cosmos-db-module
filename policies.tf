/**
 * Security configurations and policies for Cosmos DB
 */

# Azure Policy - Require encryption at rest
resource "azurerm_resource_group_policy_assignment" "cosmos_encryption" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${azurerm_cosmosdb_account.main.name}-encryption"
  resource_group_id    = data.azurerm_resource_group.main.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1f905d99-2ab7-462c-a6b0-f709acca6c8f0"
  display_name         = "Cosmos DB accounts should use customer-managed keys to encrypt data at rest"
  description          = "Ensures Cosmos DB uses customer-managed keys for encryption"

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

# Azure Policy - Require secure connections
resource "azurerm_resource_group_policy_assignment" "cosmos_secure_connections" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${azurerm_cosmosdb_account.main.name}-secure-connections"
  resource_group_id    = data.azurerm_resource_group.main.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/58535244-621a-4a0f-aca7-ef8ba5bf362b"
  display_name         = "Cosmos DB should disable public network access"
  description          = "Ensures Cosmos DB disables public network access"

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

# Azure Policy - Require advanced threat protection
resource "azurerm_resource_group_policy_assignment" "cosmos_threat_protection" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${azurerm_cosmosdb_account.main.name}-threat-protection"
  resource_group_id    = data.azurerm_resource_group.main.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/36149a0d-3af6-4e6d-9c8e-263098861e5f"
  display_name         = "Cosmos DB accounts should have advanced threat protection enabled"
  description          = "Ensures advanced threat protection is enabled for Cosmos DB"

  parameters = jsonencode({
    effect = {
      value = "AuditIfNotExists"
    }
  })
}

# Azure Policy - Require geo-redundancy
resource "azurerm_resource_group_policy_assignment" "cosmos_geo_redundancy" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${azurerm_cosmosdb_account.main.name}-geo-redundancy"
  resource_group_id    = data.azurerm_resource_group.main.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/0473574d-2d43-4217-aefe-941fcdf7e684"
  display_name         = "Cosmos DB accounts should have geo-redundancy enabled"
  description          = "Ensures geo-redundancy is enabled for Cosmos DB accounts"

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

# Data source for resource group
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# Variables for policies
variable "enable_policy_assignments" {
  description = "Enable Azure Policy assignments for this Cosmos DB"
  type        = bool
  default     = true
}