// if you have an API key, enable this module and prvoide the variable apiKey


param logAnalyticsWorkspaceName string = 'la-${uniqueString(resourceGroup().id)}'
param baseTime string = utcNow('u')
param apiKey string = 'xxx'
param taxiiServer string = 'https://otx.alienvault.com/taxii/root'

// reference the log analytics workspace
resource workspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}

// describe the lookpack period to now -10 days
var lookbackPeriod = dateTimeAdd(baseTime, '-P10D')


// describe the taxii connector
resource taxiiAlienVault 'Microsoft.SecurityInsights/dataConnectors@2022-10-01-preview' = {
  name: 'ThreatIntelligenceTaxii'
  kind: 'ThreatIntelligenceTaxii'
  scope: workspace
  properties: {
    collectionId: 'user_AlienVault'
    dataTypes: {
      taxiiClient: {
        state: 'Enabled'
      }
    }
    friendlyName: 'AlientVault-UserSubscription'
    password: 'notNeeded'
    pollingFrequency: 'OnceAnHour'
    taxiiLookbackPeriod: lookbackPeriod
    taxiiServer: taxiiServer
    tenantId: subscription().tenantId
    userName: apiKey
    workspaceId: workspace.id
  }
}
