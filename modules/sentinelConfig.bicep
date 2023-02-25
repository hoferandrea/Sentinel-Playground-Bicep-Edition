param logAnalyticsWorkspaceName string = 'la-bicep'

// reference log analytics workspace
resource workspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}

// describe entity analaytics
resource entityAnalytics 'Microsoft.SecurityInsights/settings@2022-10-01-preview' = {
  name: 'EntityAnalytics'
  kind: 'EntityAnalytics'
  scope: workspace
  properties: {
    entityProviders: [
      'AzureActiveDirectory'
    ]
  }
}

// describe ueba
resource ueba 'Microsoft.SecurityInsights/settings@2022-10-01-preview' = {
  name: 'Ueba'
  kind: 'Ueba'
  scope: workspace
  dependsOn: [entityAnalytics]
  properties: {
    dataSources: [
      'AuditLogs'
      'AzureActivity'
      'SecurityEvent'
      'SigninLogs'
    ]
  }
}

// describe anomalies
resource anomalies 'Microsoft.SecurityInsights/settings@2022-10-01-preview' = {
  name: 'Anomalies'
  kind: 'Anomalies'
  scope: workspace
  dependsOn: [ueba]
}

// describe health settings
resource healthSettings 'Microsoft.OperationalInsights/workspaces/providers/settings/providers/diagnosticSettings@2021-05-01-preview' = {
  name: '${workspace.name}/Microsoft.SecurityInsights/SentinelHealth/Microsoft.Insights/HealthSettings'
  properties: {
    workspaceId: workspace.id
    logs: [
      {
        category: 'Automation'
        enabled: true
      }
      {
        category: 'DataConnectors'
        enabled: true
      }
      {
        category: 'Analytics'
        enabled: true
      }
    ]
  }
}
