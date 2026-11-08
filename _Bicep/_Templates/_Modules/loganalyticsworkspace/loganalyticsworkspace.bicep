///// ---------------------- HEADER ---------------------- /////

// Bicep file for defining a Log Analytics Workspace module
//
// Author: Michele Blum & Flavio Meyer
// Date: 07.06.2026

///// ---------------------- HEADER END ---------------------- /////

///// ---------------------- PARAMETERS ---------------------- /////

// The name of the Log Analytics workspace
@description('The name of the Log Analytics workspace.')
param logWorkspaceName string

// The Azure location where the workspace will be deployed
@description('The location where the workspace will be deployed.')
param logWorkspaceLocation string

// Tags to be applied to the log analytics workspace
@description('Tags to be applied to the log analytics workspace.')
param logWorkspaceTags object

// The SKU of the workspace
@description('The SKU of the workspace PerGB2018.')
param logWorkspaceSkuName string = 'PerGB2018'

// The retention period for workspace data in days
@description('The retention period for workspace data.')
param logWorkspaceRetentionInDays int

// Legacy features enabled for the workspace
@description('Enable legacy features for the workspace.')
param logWorkspaceEnableLegacyFeatures int = 0

// The Log Analytics search version for the workspace
@description('Search version for the workspace.')
param logWorkspaceSearchVersion int = 1

// Whether RBAC-only access mode is enabled
@description('Enable log access using only resource permissions.')
param logWorkspaceEnableRbacLogAccess bool = true

// The daily data ingestion quota in GB
@description('Daily data ingestion quota in GB.')
param logWorkspaceDailyQuotaGb int

// Whether to enable public network access for data ingestion
@description('Enable public network access for data ingestion.')
param logWorkspaceEnablePublicNetworkAccessForIngestion string = 'Enabled'

// Whether to enable public network access for queries
@description('Enable public network access for queries.')
param logWorkspaceEnablePublicNetworkAccessForQuery string = 'Enabled'

///// ---------------------- PARAMETERS END ---------------------- /////

///// ---------------------- RESOURCES ---------------------- /////

// Define the Log Analytics Workspace resource
resource logWorkspace_module 'Microsoft.OperationalInsights/workspaces@2025-07-01' = {
  name: logWorkspaceName
  location: logWorkspaceLocation
  tags: logWorkspaceTags
  properties: {
    sku: {
      name: logWorkspaceSkuName
    }
    retentionInDays: logWorkspaceRetentionInDays
    features: {
      legacy: logWorkspaceEnableLegacyFeatures
      searchVersion: logWorkspaceSearchVersion
      enableLogAccessUsingOnlyResourcePermissions: logWorkspaceEnableRbacLogAccess
    }
    workspaceCapping: {
      dailyQuotaGb: logWorkspaceDailyQuotaGb
    }
    publicNetworkAccessForIngestion: logWorkspaceEnablePublicNetworkAccessForIngestion
    publicNetworkAccessForQuery: logWorkspaceEnablePublicNetworkAccessForQuery
  }
}

///// ---------------------- RESOURCES END ---------------------- /////

///// ---------------------- OUTPUTS ---------------------- /////

// Output the resource ID of the Log Analytics workspace
output logWorkspaceId string = logWorkspace_module.id

///// ---------------------- OUTPUTS END ---------------------- /////

///// ---------------------- END OF BICEP FILE ---------------------- /////
