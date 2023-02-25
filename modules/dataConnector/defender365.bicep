param logAnalyticsWorkspaceName string

// reference the log analytics workspace
resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01-preview' existing = {
  name: logAnalyticsWorkspaceName
}

resource defender365ConnectorIncidents 'Microsoft.OperationalInsights/workspaces/providers/dataConnectors@2022-10-01-preview' = {
  name: '${workspace.name}/Microsoft.SecurityInsights/Defender365-${guid(subscription().tenantId)}'
  kind: 'MicrosoftThreatProtection'
  properties: {
    tenantId: subscription().tenantId
    dataTypes: {
      incidents: {
        state: 'enabled'
      }
    }
  }
}
