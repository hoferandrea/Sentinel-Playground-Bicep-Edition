param logAnalyticsWorkspaceName string

// reference the log analytics workspace
resource workspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}

// describe the aad connector
resource azureActiveDirectoryConnector 'Microsoft.SecurityInsights/dataConnectors@2022-10-01-preview' = {
  name: 'AzureActiveDirectory'
  kind: 'AzureActiveDirectory'
  scope: workspace
  properties: {
    dataTypes: {
      alerts: {
        state: 'enabled'
      }
    }
    tenantId: subscription().tenantId
  }
}


// describe the aad diagnostic settings
var aadLogs = [
  'AuditLogs'
  'SignInLogs'
  'NonInteractiveUserSignInLogs'
  'ServicePrincipalSignInLogs'
  'ManagedIdentitySignInLogs'
  'ProvisioningLogs'
  'ADFSSignInLogs'
  'RiskyUsers'
  'UserRiskEvents'
  'NetworkAccessTrafficLogs'
  'RiskyServicePrincipals'
  'ServicePrincipalRiskEvents'
]

resource aadDiagnosticSetttings 'microsoft.aadiam/diagnosticSettings@2017-04-01' = {
  name: '${workspace.name}-aadDiagnosticSetttings'
  properties: {
    workspaceId: workspace.id
    logs: [for log in aadLogs: {
      category: log
      enabled: true
    }]
  }
  scope: tenant()
}


