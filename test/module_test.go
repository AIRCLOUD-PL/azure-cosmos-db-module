package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestCosmosDBModuleBasic(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",

		Vars: map[string]interface{}{
			"resource_group_name": "rg-test-cosmos-basic",
			"location":           "westeurope",
			"environment":        "test",
			"kind":              "GlobalDocumentDB",
			"geo_locations": []map[string]interface{}{
				{
					"location":          "westeurope",
					"failover_priority": 0,
				},
			},
		},

		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_cosmosdb_account.main")
}

func TestCosmosDBModuleWithSecurity(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/complete",

		Vars: map[string]interface{}{
			"resource_group_name": "rg-test-cosmos-security",
			"location":           "westeurope",
			"environment":        "test",
			"kind":              "GlobalDocumentDB",
			"public_network_access_enabled": false,
			"identity_type":     "SystemAssigned",
			"geo_locations": []map[string]interface{}{
				{
					"location":          "westeurope",
					"failover_priority": 0,
					"zone_redundant":    true,
				},
				{
					"location":          "northeurope",
					"failover_priority": 1,
				},
			},
			"capabilities": []string{
				"EnableServerless",
			},
			"sql_databases": map[string]interface{}{
				"appdb": map[string]interface{}{
					"throughput": 400,
				},
			},
			"sql_containers": map[string]interface{}{
				"items": map[string]interface{}{
					"database_name":      "appdb",
					"partition_key_path": "/partitionKey",
					"throughput":         400,
				},
			},
		},

		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_cosmosdb_account.main")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_cosmosdb_sql_database.sql_databases")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_cosmosdb_sql_container.sql_containers")
}

func TestCosmosDBModuleWithMongoDB(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/mongodb",

		Vars: map[string]interface{}{
			"resource_group_name": "rg-test-cosmos-mongo",
			"location":           "westeurope",
			"environment":        "test",
			"kind":              "MongoDB",
			"geo_locations": []map[string]interface{}{
				{
					"location":          "westeurope",
					"failover_priority": 0,
				},
			},
			"mongo_databases": map[string]interface{}{
				"mongodb": map[string]interface{}{
					"throughput": 400,
				},
			},
			"mongo_collections": map[string]interface{}{
				"users": map[string]interface{}{
					"database_name": "mongodb",
					"throughput":    400,
					"indexes": []map[string]interface{}{
						{
							"keys":   []string{"_id"},
							"unique": true,
						},
					},
				},
			},
		},

		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_cosmosdb_account.main")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_cosmosdb_mongo_database.mongo_databases")
	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_cosmosdb_mongo_collection.mongo_collections")
}

func TestCosmosDBModuleWithPrivateEndpoint(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/complete",

		Vars: map[string]interface{}{
			"resource_group_name": "rg-test-cosmos-pe",
			"location":           "westeurope",
			"environment":        "test",
			"kind":              "GlobalDocumentDB",
			"public_network_access_enabled": false,
			"geo_locations": []map[string]interface{}{
				{
					"location":          "westeurope",
					"failover_priority": 0,
				},
			},
			"private_endpoints": map[string]interface{}{
				"cosmosdb": map[string]interface{}{
					"subnet_id": "/subscriptions/sub/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/subnet",
				},
			},
		},

		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_private_endpoint.cosmosdb")
}

func TestCosmosDBModuleNamingConvention(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic",

		Vars: map[string]interface{}{
			"resource_group_name": "rg-test-cosmos-naming",
			"location":           "westeurope",
			"environment":        "prod",
			"naming_prefix":      "cosmosprod",
			"kind":              "GlobalDocumentDB",
			"geo_locations": []map[string]interface{}{
				{
					"location":          "westeurope",
					"failover_priority": 0,
				},
			},
		},

		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	resourceChanges := terraform.GetResourceChanges(t, planStruct)

	for _, change := range resourceChanges {
		if change.Type == "azurerm_cosmosdb_account" && change.Change.After != null {
			afterMap := change.Change.After.(map[string]interface{})
			if name, ok := afterMap["name"]; ok {
				cosmosName := name.(string)
				assert.Contains(t, cosmosName, "prod", "Cosmos DB name should contain environment")
			}
		}
	}
}

func TestCosmosDBModuleWithNotebookWorkspace(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/complete",

		Vars: map[string]interface{}{
			"resource_group_name": "rg-test-cosmos-notebook",
			"location":           "westeurope",
			"environment":        "test",
			"kind":              "GlobalDocumentDB",
			"enable_notebook_workspace": true,
			"geo_locations": []map[string]interface{}{
				{
					"location":          "westeurope",
					"failover_priority": 0,
				},
			},
		},

		PlanOnly: true,
	})

	defer terraform.Destroy(t, terraformOptions)

	planStruct := terraform.InitAndPlan(t, terraformOptions)

	terraform.RequirePlannedValuesMapKeyExists(t, planStruct, "azurerm_cosmosdb_notebook_workspace.main")
}