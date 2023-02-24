param logAnalyticsWorkspaceName string = 'la-${uniqueString(resourceGroup().id)}'
param logAnalyticsWorkspaceLocation string = resourceGroup().location
param logAnalyticsWorkspaceRetentionDays int = 30
param logAnalyticsWorkspaceDailyCapGb int = 1

// describe the workspace
resource workspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: logAnalyticsWorkspaceName
  location: logAnalyticsWorkspaceLocation
  properties: {
    retentionInDays: logAnalyticsWorkspaceRetentionDays
    sku: {
      name: 'PerGB2018'
    }
    workspaceCapping: {
      dailyQuotaGb: logAnalyticsWorkspaceDailyCapGb
    }

  }
}

// describe the sentinel solution
resource solution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'SecurityInsights(${workspace.name})'
  location: logAnalyticsWorkspaceLocation
  properties: {
    workspaceResourceId: workspace.id
  }
  plan: {
    name: 'SecurityInsights(${workspace.name})'
    product: 'OMSGallery/SecurityInsights'
    publisher: 'Microsoft'
    promotionCode: ''
  }
}

output logAnalyticsWorkspaceId string = workspace.id

