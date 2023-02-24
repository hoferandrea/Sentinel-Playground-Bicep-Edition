param logAnalyticsWorkspaceName string = 'la-bicep'

// reference log analytics workspace
resource workspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}


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

resource anomalies 'Microsoft.SecurityInsights/settings@2022-10-01-preview' = {
  name: 'Anomalies'
  kind: 'Anomalies'
  scope: workspace
  dependsOn: [ueba]
}


// sentinel health monitoring - unspupported as of now
/*

      // describe the diagnostic settings on the subscription
      var subscriptionLogs = [
        'Analytics'
        'Automation'
        'DataConnectors'
      ]

      resource sentinel 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' existing = {
        name: 'SecurityInsights(la-sentinel-playground-01)'
      }

      resource subscriptionToLa 'Microsoft.Insights/diagnosticSettings@2023-02-01-preview' = {
        name: 'sentinelToLogAnalyticsWorkspace'
        scope: sentinel
        properties: {
          workspaceId: workspace.id
          logs: [for log in subscriptionLogs: {
            category: log
            enabled: true
          }]
        }
      }

*/
