///// ---------------------- HEADER ---------------------- /////

// Bicep file for defining an Azure Monitor Scheduled Query Rule (Log Alert) module
//
// Author: Michele Blum & Flavio Meyer
// Date: 07.05.2026

///// ---------------------- HEADER END ---------------------- /////

///// ---------------------- SCOPE ---------------------- /////

// Scheduled Query Rules must be deployed under the 'resourceGroup' scope
targetScope = 'resourceGroup'

///// ---------------------- SCOPE END ---------------------- /////

///// ---------------------- PARAMETERS ---------------------- /////

// The name of the Scheduled Query Rule.
@description('The name of the Scheduled Query Rule.')
param scheduledQueryRuleName string

// The location where the Scheduled Query Rule will be deployed.
@description('The Azure location for the Scheduled Query Rule.')
param scheduledQueryRuleLocation string

// Tags to be applied to the Scheduled Query Rule.
@description('Tags to be applied to the Scheduled Query Rule.')
param scheduledQueryRuleTags object

// Kind of the Scheduled Query Rule, e.g., "LogAlert".
@description('The kind of the Scheduled Query Rule, e.g., "LogAlert".')
param scheduledQueryRuleKind string = 'LogAlert'

// Description of the Scheduled Query Rule.
@description('Description of the Scheduled Query Rule.')
param scheduledQueryRuleDescription string = 'Break Glass Admin Sign-In Alert Rule - Triggered when a sign-in is detected for a break glass account, indicating potential unauthorized access or misuse of privileged credentials. This rule helps to ensure that any sign-ins to break glass accounts are promptly identified and investigated, enhancing the security posture of the environment.'

// Severity level of the alert (0 for Critical, 1 for Error, 2 for Warning, 3 for Informational).
@description('Severity level of the alert (0 for Critical, 1 for Error, 2 for Warning, 3 for Informational).')
param scheduledQueryRuleSeverity int = 0

// Enable or disable the Scheduled Query Rule.
@description('Specifies whether the Scheduled Query Rule is enabled.')
param scheduledQueryRuleEnabled bool = true

// Evaluation frequency for the rule in ISO 8601 duration format (e.g., 'PT5M' for every 5 minutes).
@description('Evaluation frequency for the rule in ISO 8601 duration format (e.g., "PT5M" for every 5 minutes).')
param scheduledQueryRuleEvaluationFrequency string = 'PT5M'

// The resource ID of the Log Analytics workspace to scope the rule to.
@description('The resource ID of the Log Analytics workspace.')
param logWorkspaceResourceId string

// Target resource types for the rule, e.g., 'Microsoft.OperationalInsights/workspaces'.
@description('Target resource types for the rule, e.g., "Microsoft.OperationalInsights/workspaces".')
param scheduledQueryRuleTargetResourceTypes array = [
  'Microsoft.OperationalInsights/workspaces'
]
// Window size for the rule evaluation in ISO 8601 duration format (e.g., 'PT5M' for a 5-minute window).
@description('Window size for the rule evaluation in ISO 8601 duration format (e.g., "PT5M" for a 5-minute window).')
param scheduledQueryRuleWindowSize string = 'PT5M'

// KQL query for the alert
@description('The KQL query used for alert evaluation.')
param query string

// Time aggregation method for the alert (e.g., 'Count', 'Average', 'Sum').
@description('Time aggregation method for the alert (e.g., "Count", "Average", "Sum").')
param timeAggregation string = 'Count'

// Operator for the alert condition (e.g., 'GreaterThan', 'LessThan').
@description('Operator for the alert condition (e.g., "GreaterThan", "LessThan").')
param operator string = 'GreaterThan'

// Threshold for the alert condition.
@description('Threshold for the alert condition.')
param threshold int = 0

// Number of evaluation periods for the alert condition.
@description('Number of evaluation periods for the alert condition.')
param numberOfEvaluationPeriods int = 1

// Minimum number of failing periods to trigger the alert.
@description('Minimum number of failing periods to trigger the alert.')
param minFailingPeriodsToAlert int = 1

// Auto-mitigate setting for the alert.
@description('Specifies whether to auto-mitigate the alert.')
param autoMitigate bool = false

// The resource ID of the Action Group for alert notifications.
@description('The resource ID of the Action Group for alert notifications.')
param actionGroupResourceId string

///// ---------------------- PARAMETERS END ---------------------- /////

///// ---------------------- RESOURCES ---------------------- /////

// Define the Azure Monitor Scheduled Query Rule resource
resource scheduledQueryRule_module 'microsoft.insights/scheduledqueryrules@2026-03-01' = {
  name: scheduledQueryRuleName
  location: scheduledQueryRuleLocation
  tags: scheduledQueryRuleTags
  kind: scheduledQueryRuleKind
  properties: {
    displayName: scheduledQueryRuleName
    description: scheduledQueryRuleDescription
    severity: scheduledQueryRuleSeverity
    enabled: scheduledQueryRuleEnabled
    evaluationFrequency: scheduledQueryRuleEvaluationFrequency
    scopes: [
      logWorkspaceResourceId
    ]
    targetResourceTypes: scheduledQueryRuleTargetResourceTypes
    windowSize: scheduledQueryRuleWindowSize
    criteria: {
      allOf: [
        {
          query: query
          timeAggregation: timeAggregation
          dimensions: []
          operator: operator
          threshold: threshold
          failingPeriods: {
            numberOfEvaluationPeriods: numberOfEvaluationPeriods
            minFailingPeriodsToAlert: minFailingPeriodsToAlert
          }
        }
      ]
    }
    autoMitigate: autoMitigate
    actions: {
      actionGroups: [
        actionGroupResourceId
      ]
    customProperties: {}
    actionProperties: {}
    }
  }
}

///// ---------------------- RESOURCES END ---------------------- /////

///// ---------------------- OUTPUTS ---------------------- /////

// Output the resource ID of the Scheduled Query Rule
output scheduledQueryRuleId string = scheduledQueryRule_module.id

///// ---------------------- OUTPUTS END ---------------------- /////

///// ---------------------- END OF BICEP FILE ---------------------- /////
