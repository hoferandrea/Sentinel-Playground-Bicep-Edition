param uamiName string
param laName string
param utcValue string = utcNow()

// reference the user-assigned managed identity
resource userAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: uamiName
  scope: resourceGroup()

}

// use the current time in the name, otherwise the script isn't triggered again 
resource enableContentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'enableContentScript-${utcValue}'
  location: resourceGroup().location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedManagedIdentity.id}': {}
    }
  }
  properties: {
    azPowerShellVersion: '8.3'
    forceUpdateTag: utcValue
    scriptContent: loadTextContent('enableContent.ps1')
    arguments: '-ResourceGroup ${resourceGroup().name} -workspace ${laName} -connectors "AzureActiveDirectory","AzureActivity"'
    retentionInterval: 'P1D'
  }
}

output enableContentResult string = enableContentScript.properties.outputs.result
