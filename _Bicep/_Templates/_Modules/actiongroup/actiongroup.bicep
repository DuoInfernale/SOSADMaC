//// ---------------------- HEADER ---------------------- /////

// Bicep file for defining an Azure Monitor Action Group module
//
// Author: Michele Blum & Flavio Meyer
// Date: 07.05.2026
// Last updated: 14.05.2026

///// ---------------------- HEADER END ---------------------- /////

///// ---------------------- SCOPE ---------------------- /////

// Action Groups must be deployed under the 'resourceGroup' scope
targetScope = 'resourceGroup'

///// ---------------------- SCOPE END ---------------------- /////

///// ---------------------- PARAMETERS ---------------------- /////

// The name of the Azure Monitor Action Group
@description('The name of the Azure Monitor Action Group.')
param actionGroupName string

// The Azure location for the Action Group
@description('The Azure location for the Action Group. Must be Global.')
param actionGroupLocation string = 'Global'

// The tags to be applied to the Action Group
@description('Tags to be applied to the Action Group.')
param actionGroupTags object

// The short name for the Action Group (used in notifications)
@description('The short name for the Action Group (used in notifications).')
param actionGroupShortName string

// Whether the Action Group is enabled
@description('Specifies whether the Action Group is enabled.')
param enabled bool = true

// The email receivers for the Action Group notifications
@description('The email receivers for the Action Group notifications.')
param emailReceivers array

///// ---------------------- PARAMETERS END ---------------------- /////

///// ---------------------- RESOURCES ---------------------- /////

// Define the Azure Monitor Action Group module resource
resource actionGroup_module 'microsoft.insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: actionGroupLocation
  tags: actionGroupTags
  properties: {
    groupShortName: actionGroupShortName
    enabled: enabled
    emailReceivers: emailReceivers
  }
}

///// ---------------------- RESOURCES END ---------------------- /////

///// ---------------------- OUTPUTS ---------------------- /////

// Output the resource ID of the Action Group
output actionGroupId string = actionGroup_module.id

///// ---------------------- OUTPUTS END ---------------------- /////

///// ---------------------- END OF BICEP FILE ---------------------- /////
