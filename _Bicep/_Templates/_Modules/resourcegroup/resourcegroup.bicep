///// ---------------------- HEADER ---------------------- /////

// Bicep file for defining a resource group module
//
// Author: Michele Blum & Flavio Meyer
// Date: 07.05.2026

///// ---------------------- HEADER END ---------------------- /////

///// ---------------------- SCOPE ---------------------- /////

// Resource groups must be deployed under the 'subscription' scope
targetScope = 'subscription'

///// ---------------------- SCOPE END ---------------------- /////

///// ---------------------- PARAMETERS ---------------------- /////

// The name of the resource group to be created
@description('The name of the resource group')
param rgName string

// The location where the resource group will be deployed
@description('The location of the resource group')
param rgLocation string

// Tags to be applied to the resource group
@description('Tags to be applied to the resource group')
param rgTags object

///// ---------------------- PARAMETERS END ---------------------- /////

///// ---------------------- RESOURCES ---------------------- /////

// Define the Resource group module resource
resource resourcegroup_module 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: rgName
  location: rgLocation
  tags: rgTags
}

///// ---------------------- RESOURCES END ---------------------- /////

///// ---------------------- OUTPUTS ---------------------- /////

// Output the ID of the resource group
output resourceGroupId string = resourcegroup_module.id

///// ---------------------- OUTPUTS END ---------------------- /////

///// ---------------------- END OF BICEP FILE ---------------------- /////
