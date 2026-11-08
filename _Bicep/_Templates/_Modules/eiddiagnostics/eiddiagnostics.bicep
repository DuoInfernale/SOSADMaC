///// ---------------------- HEADER ---------------------- /////

// Bicep file for defining Entra ID Diagnostic Settings module 
//
// Author: Michele Blum & Flavio Meyer
// Date: 07.05.2026

///// ---------------------- HEADER END ---------------------- /////

///// ---------------------- SCOPE ---------------------- /////

// Entra ID Diagnostic Settings must be deployed at the 'tenant' scope
targetScope = 'tenant'

///// ---------------------- SCOPE END ---------------------- /////

///// ---------------------- PARAMETERS ---------------------- /////

// The name of the Entra ID diagnostic setting
@description('The name of the Entra ID diagnostic setting.')
param eidDiagnosticsName string

// The Resource ID of the Log Analytics workspace
@description('The Resource ID of a Log Analytics workspace. Leave empty if not used.')
param logWorkspaceId string 

// The log categories configuration for Entra ID diagnostic settings
@description('Array of Entra ID log categories to enable.')
param eidLogs array = [
  {
    category: 'AuditLogs'
    enabled: true
    retentionPolicy: {
      enabled: true
      days: 0
    }
  }
  {
    category: 'SignInLogs'
    enabled: true
    retentionPolicy: {
      enabled: true
      days: 0
    }
  }
  {
    category: 'NonInteractiveUserSignInLogs'
    enabled: true
    retentionPolicy: {
      enabled: true
      days: 0
    }
  }
]

///// ---------------------- PARAMETERS END ---------------------- /////

///// ---------------------- RESOURCES ---------------------- /////

// Define the Entra ID Diagnostic Settings module resource
resource eidDiagnosticsSettings_module 'microsoft.aadiam/diagnosticSettings@2017-04-01' = {
  name: eidDiagnosticsName
  properties: {
    logs: eidLogs
    workspaceId: logWorkspaceId
  }
}

///// ---------------------- RESOURCES END ---------------------- /////

///// ---------------------- OUTPUTS ---------------------- /////

// Output the resource ID of the Entra ID diagnostic settings
output eidDiagnosticsSettingsId string = eidDiagnosticsSettings_module.id

///// ---------------------- OUTPUTS END ---------------------- /////

///// ---------------------- END OF BICEP FILE ---------------------- /////
