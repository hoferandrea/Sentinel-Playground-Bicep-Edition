targetScope = 'subscription'
param logAnalyticsWorkspaceId string

// describe the diagnostic settings on the subscription
var subscriptionLogs = [
  'Administrative'
  'Security'
  'ServiceHealth'
  'Alert'
  'Recommendation'
  'Policy'
  'Autoscale'
  'ResourceHealth'
]

resource subscriptionToLa 'Microsoft.Insights/diagnosticSettings@2017-05-01-preview' = {
  name: 'subscriptionToLogAnalyticsWorkspace'
  scope: subscription()
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [for log in subscriptionLogs: {
      category: log
      enabled: true
    }]
  }
}
