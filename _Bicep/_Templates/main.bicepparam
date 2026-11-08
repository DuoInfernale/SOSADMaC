using './main.bicep'

//// ---------------------- HEADER ---------------------- /////

// Bicep parameters file for deploying the Break Glass Sign‑In Alerting solution.
// This file defines the parameter values passed to main.bicep during deployment.
//
// Authors: Michele Blum & Flavio Meyer
// Creation date: 07.05.2026
// Last updated: 14.05.2026

//// ---------------------- HEADER END ---------------------- /////

//// ---------------------- PARAMETERS ---------------------- /////

// The subscription ID where the solution resources will be deployed.
param gpar_subscriptionId = '00000000-0000-0000-0000-000000000000' 

// The customer abbreviation (used for resource naming). Must be provided in lowercase and will be converted to uppercase for naming conventions.
param gpar_customerAbbreviation = 'xxx'

// The environment (e.g., dev, test, prod). Must be provided in lowercase and will be used for tagging and naming conventions.
param gpar_environment = 'xxx'

// Tags applied to all deployed resources.
param gpar_tags = {}

// The name of the Entra ID Diagnostic Settings resource.
param dpar_eidDiagnosticsSettingsName = 'xxx'

// Azure region in which the solution will be deployed.
param dpar_location = 'xxx'

// Retention period (in days) for the Log Analytics workspace.
param dpar_logWorkspaceRetentionInDays = 90

// Daily ingestion quota (in GB) for the Log Analytics workspace.
param dpar_logWorkspaceDailyQuotaGb = 1

// Email receivers for the Action Group.
// Up to 4 email objects can be provided. Each object must include:
// - emailAddress: The email address designated to receive alerts
// - name: A display name for the receiver (usually the email itself)
// - useCommonAlertSchema: Whether to use the unified alert schema
param dpar_emailReceivers = [
  {
    emailAddress: 'xxx'
    name: 'xxx'
    useCommonAlertSchema: false
  }
]

// KQL query used by the Scheduled Query Alert to detect Break Glass sign-in events.
param dpar_query = '''
SigninLogs
| project UserId
| where UserId == "xxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
'''

//// ---------------------- PARAMETERS END ---------------------- /////
