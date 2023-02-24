/*
Welcome to the Sentinel Playground!
#########################################################################################
# developed by Andrea Hofer - https://www.linkedin.com/in/andrea-hofer-ch/ | 20.02.2023 #
#########################################################################################
*/
targetScope = 'subscription'

// parameters
@description('resource group name')
param rgName string = 'rg-sentinel-playground-01'

@description('log analytics workspace name')
param laName string = 'la-sentinel-playground-01'

@description('user assigned managed identity name')
param uamiName string = 'mi-sentinel-playbooks'

@description('log analytics retention days')
param laRetentionDays int = 30

@description('log analytics daily cap in GB')
param laDailyCapGb int = 1

// describe the rg
module resourceGroup './modules/resourceGroup.bicep' = {
  name: 'resourceGroupDeployment'
  scope: subscription()
  params:{
    ressourceGroupName: rgName
  }
}

// describe the log analytics workspace and the sentinel solution
module sentinel './modules/sentinel.bicep' = {
  name: 'sentinelDeployment'
  scope: az.resourceGroup(rgName)
  dependsOn: [ resourceGroup ]
  params:{
    logAnalyticsWorkspaceName: laName
    logAnalyticsWorkspaceRetentionDays: laRetentionDays
    logAnalyticsWorkspaceDailyCapGb: laDailyCapGb
  }
}

// describe the azure active directory connector
module azureActiveDirectoryConnector './modules/dataConnector/azureActiveDirectory.bicep' = {
  name: 'azureActiveDirectoryConnectorDeployment'
  scope: az.resourceGroup(rgName)
  dependsOn: [sentinel]
  params:{
    logAnalyticsWorkspaceName: laName
  }
}

// describe the azure activity connector
module azureActivityConnector 'modules/dataConnector/azureAcivity.bicep' = {
  name: 'azureActivityConnectorDeployment'
  dependsOn: [sentinel]
  params:{
    logAnalyticsWorkspaceId: sentinel.outputs.logAnalyticsWorkspaceId
  }
}

// describe the taxii connector for e.g. alientvault
// disabled per default - if you have an api key, change the parameter apiKey/taxii server and enable this module
/*
module taxiiConnector 'modules/dataConnector/taxii.bicep' = {
  name: 'taxiiConnectorDeployment'
  scope: az.resourceGroup(rgName)
  dependsOn: [sentinel]
  params:{
    logAnalyticsWorkspaceName: laName
    apiKey: 'xxx'
    taxiiServer: 'https://otx.alienvault.com/taxii/root'
  }
}
*/

// describe the sentinel config (entity analytics, ueba, anomalies)
module sentinelConfig 'modules/sentinelConfig.bicep' = {
  name: 'sentinelConfigDeployment'
  scope: az.resourceGroup(rgName)
  dependsOn: [azureActivityConnector, azureActiveDirectoryConnector]
  params:{
    logAnalyticsWorkspaceName: laName
  }
}

// describe the user-assigned managed identity for the playbooks
module playbookUserAssignedManagedIdenity 'modules/userAssignedManagedIdentity.bicep' = {
  name: 'playbookUserAssignedManagedIdenityDeployment'
  scope: az.resourceGroup(rgName)
  dependsOn: [resourceGroup]
  params:{
    userAssignedManagedIdentityName: uamiName
  }
}

// describe the sentinel api connection
module sentinelApiConnection 'modules/apiConnection.bicep' = {
  name: 'sentinelApiConnectionDeployment'
  scope: az.resourceGroup(rgName)
  dependsOn: [playbookUserAssignedManagedIdenity]
  params:{
    sentinelApiConnectionName: '${playbookUserAssignedManagedIdenity.outputs.uamiName}-connection'
  }
}


// describe the required permissions for the user-assigned managed identity to update incidents
// the user-assigned managed identity needs the 'microsoft sentinel contributor' role (for enabling the content, otherwise 'responder' would be sufficient)
module uamiSentinelRoleAssignment 'modules/roleAssignment.bicep' = {
  name: 'uamiSentinelRoleAssignmentDeployment'
  dependsOn: [playbookUserAssignedManagedIdenity]
  scope: az.resourceGroup(rgName)
  params:{
    roleDefinitionId: 'ab8e14d6-4a74-4a29-9ba8-549422addade' // microsoft sentinel contributor role
    prinipalId: playbookUserAssignedManagedIdenity.outputs.uamiPrincipalId // user assigned managed identity id
  }
}

// describe the required permissions for sentinel to trigger playbooks
// the enterprise application azure security insights needs the 'microsoft sentinel automation contributor' role
module sentinelTriggerPlaybooksRoleAssignment 'modules/roleAssignment.bicep' = {
  name: 'sentinelTriggerPlaybooksRoleAssignmentDeployment'
  dependsOn: [resourceGroup]
  scope: az.resourceGroup(rgName)
  params:{
    roleDefinitionId: 'f4c81013-99ee-4d62-a7ee-b3f1f648599a' // microsoft sentinel automation contributor role
    prinipalId: '7c6538eb-e706-483d-bde3-9500f39c938a' // ea azure security insights object id
  }
}

// describe the demo playbook
module playbook 'modules/playbook.bicep' = {
  name: 'playbookDeployment'
  dependsOn: [sentinelApiConnection, playbookUserAssignedManagedIdenity]
  scope: az.resourceGroup(rgName)
  params:{
    playbookName: 'la-sentinel-addCommentToIncident'
    sentinelApiConnectionName: sentinelApiConnection.outputs.sentinelApiConnectionName
    uamiName: playbookUserAssignedManagedIdenity.outputs.uamiName
  }
}

// describe deployment script for enabling content based on data connectors
module deyplomentScriptContent 'modules/enableContent/enableContent.bicep' = {
  name: 'contentEnablement'
  dependsOn: [playbookUserAssignedManagedIdenity, sentinel]
  scope: az.resourceGroup(rgName)
  params:{
    uamiName: playbookUserAssignedManagedIdenity.outputs.uamiName
    laName: laName
  }
}

// describe deployment script for creating an incident
module deyplomentScriptIncident 'modules/createIncident/createIncident.bicep' = {
  name: 'incidentDeployment'
  dependsOn: [sentinel]
  scope: az.resourceGroup(rgName)
  params:{
    uamiName: playbookUserAssignedManagedIdenity.outputs.uamiName
    laName: laName
  }
}

// describe custom sentinel content
module contentDeployment 'content/mainContent.bicep' = {
  name: 'contentDeployment'
  dependsOn: [playbookUserAssignedManagedIdenity, sentinel]
  scope: az.resourceGroup(rgName)
  params:{
    logAnalyticsWorkspaceName: laName
  }
}

output playGround string = 'Thanks for using Playground!'
output incidentResult string = deyplomentScriptIncident.outputs.incidenResult
output contentResult string = deyplomentScriptContent.outputs.enableContentResult
