///// ---------------------- HEADER ---------------------- /////

// Main Bicep template for deploying the Break Glass Sign-In Alerting solution in Azure, including resource group, Log Analytics workspace, Action Group, Scheduled Query Rule, and Entra ID Diagnostic Settings.
// This template deploys the following resources:
// - Resource Group
// - Log Analytics Workspace
// - Action Group
// - Scheduled Query Rule
// - Entra ID Diagnostic Settings
//
// Authors: Michele Blum & Flavio Meyer
// Creation date: 07.05.2026
// Last updated: 14.05.2026

///// ---------------------- HEADER END ---------------------- /////

///// ---------------------- SCOPE ---------------------- /////

// Deployment scoped to tenant level to allow creation of Entra ID Diagnostic Settings, which require tenant scope.
targetScope = 'tenant'

///// ---------------------- SCOPE END ---------------------- /////

///// ---------------------- PARAMETERS ---------------------- /////

//// ---------------------- GLOBAL PARAMETERS ---------------------- ////

// The subscription ID where the resource group and related resources will be deployed.
param gpar_subscriptionId string

// The abbreviation of the customer for the deployment.
param gpar_customerAbbreviation string

// The environment for the deployment (e.g., dev, test, prod).
param gpar_environment string

// Tags to be applied to the resources for resource management and organization.
param gpar_tags object

//// ---------------------- GLOBAL PARAMETERS END ---------------------- ////

//// ---------------------- STATIC PARAMETERS ---------------------- ////

//// ---------------------- STATIC PARAMETERS END ---------------------- ////

//// ---------------------- DYNAMIC PARAMETERS ---------------------- ////

// The location for the deployment.
param dpar_location string

// The retention period for Log Analytics workspace data (in days).
param dpar_logWorkspaceRetentionInDays int

// The daily data ingestion quota in GB for Log Analytics workspace.
param dpar_logWorkspaceDailyQuotaGb int

// Email addresses for the Action Group notifications.
param dpar_emailReceivers array

// The name of the Entra ID Diagnostic Settings resource (fixed value).
param dpar_eidDiagnosticsSettingsName string 

// The Kusto Query Language (KQL) query for the Scheduled Query Rule alert.
param dpar_query string

//// ---------------------- DYNAMIC PARAMETERS END ---------------------- ////

///// ---------------------- PARAMETERS END ---------------------- /////

///// ---------------------- VARIABLES ---------------------- /////

// Construct the name of the resource group based on the customer abbreviation, environment, location, and a fixed suffix.
var var_rgLogWorkspaceName = '${gpar_customerAbbreviation}-rg-signinmonitoring-${gpar_environment != '' ? gpar_environment : 'prod'}-${dpar_location != '' ? dpar_location : 'switzerlandnorth'}-001'

// Construct the name of the Log Analytics workspace based on the customer abbreviation, environment, location, and a fixed suffix.
var var_logWorkspaceName = '${gpar_customerAbbreviation}-log-signinmonitoring-${gpar_environment != '' ? gpar_environment : 'prod'}-${dpar_location != '' ? dpar_location : 'switzerlandnorth'}-001'

// Change the customer abbreviation to uppercase for use in the Action Group short name, which has a character limit and often benefits from uppercase for readability.
var var_customerAbbreviationCaps = toUpper(gpar_customerAbbreviation)

// Construct the name of the Action Group based on the customer abbreviation and a fixed suffix.
var var_actionGroupDeploymentName = '${var_customerAbbreviationCaps}-SOSAdminSignInActionGroup'
var var_actionGroupName = '${var_customerAbbreviationCaps} - Break Glass Admin Sign-In Action Group'

// Construct the short name of the Action Group.
var var_actionGroupShortName = 'SOSAdmSignIn'

// Construct the name of the Scheduled Query Rule based on the customer abbreviation and a fixed suffix.
var var_scheduledQueryRuleDeploymentName = '${var_customerAbbreviationCaps}-SOSAdminAlertingAlertRule'
var var_scheduledQueryRuleName = '${var_customerAbbreviationCaps} - Break Glass Admin Sign-In Alert Rule'

// Construct the name of the Entra ID Diagnostic Settings resource based on the customer abbreviation and a fixed suffix.
var var_eidDiagnosticsSettingsName = '${var_customerAbbreviationCaps}-SOSAdminSignInDiagSettings'

///// ---------------------- VARIABLES END ---------------------- /////

///// ---------------------- MODULES ---------------------- /////

// Resource Group
module resourceGroup '_Modules/resourcegroup/resourcegroup.bicep' = {
  name: var_rgLogWorkspaceName
  scope: az.subscription(gpar_subscriptionId)
  params: {
    rgName: var_rgLogWorkspaceName
    rgLocation: dpar_location
    rgTags: gpar_tags
  }
}

// Log Analytics Workspace
module logAnalyticsWorkspace '_Modules/loganalyticsworkspace/loganalyticsworkspace.bicep' = {
  name: var_logWorkspaceName
  scope: az.resourceGroup(gpar_subscriptionId, var_rgLogWorkspaceName)
  params: {
    logWorkspaceName: var_logWorkspaceName
    logWorkspaceLocation: dpar_location
    logWorkspaceTags: gpar_tags
    logWorkspaceRetentionInDays: dpar_logWorkspaceRetentionInDays
    logWorkspaceDailyQuotaGb: dpar_logWorkspaceDailyQuotaGb
  }
  dependsOn: [
  resourceGroup
  ]
}

// Action Group
module actionGroup '_Modules/actiongroup/actiongroup.bicep' = {
  name: var_actionGroupDeploymentName
  scope: az.resourceGroup(gpar_subscriptionId, var_rgLogWorkspaceName)
  params: {
    actionGroupName: var_actionGroupName
    actionGroupTags: gpar_tags
    actionGroupShortName: var_actionGroupShortName
    emailReceivers: dpar_emailReceivers
  }
  dependsOn: [
    resourceGroup
  ]
}

// Scheduled Query Rule
module scheduledQueryRule '_Modules/scheduledqueryrule/scheduledqueryrule.bicep' = {
  name: var_scheduledQueryRuleDeploymentName
  scope: az.resourceGroup(gpar_subscriptionId, var_rgLogWorkspaceName)
  params: {
    scheduledQueryRuleName: var_scheduledQueryRuleName
    scheduledQueryRuleLocation: dpar_location
    scheduledQueryRuleTags: gpar_tags
    query: dpar_query
    logWorkspaceResourceId: logAnalyticsWorkspace.outputs.logWorkspaceId
    actionGroupResourceId: actionGroup.outputs.actionGroupId
  }
  dependsOn: [
    logAnalyticsWorkspace
    actionGroup
  ]
}

// Entra ID Diagnostic Settings (Tenant scope!)
module eidDiagnosticsSettings '_Modules/eiddiagnostics/eiddiagnostics.bicep' = {
  name: var_eidDiagnosticsSettingsName
  params: {
    eidDiagnosticsName: dpar_eidDiagnosticsSettingsName
    logWorkspaceId: logAnalyticsWorkspace.outputs.logWorkspaceId
    // logs parameter assumed to be defined in the module with defaults; main does not need to declare it
  }
  dependsOn: [
    logAnalyticsWorkspace
  ] 
}

///// ---------------------- MODULES END ---------------------- /////

///// ---------------------- OUTPUTS ---------------------- /////

///// ---------------------- OUTPUTS END ---------------------- /////

///// ---------------------- END OF BICEP FILE ---------------------- /////
