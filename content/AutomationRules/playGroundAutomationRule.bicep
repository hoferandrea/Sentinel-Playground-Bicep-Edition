//workspace name (automatically assigned during sentinel content deployment)
param workspace string

// reference the workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: workspace
}

// automation rule properties (edit)
var ruleName = 'Playground Automation Rule'

resource automationRule 'Microsoft.SecurityInsights/automationRules@2019-01-01-preview' = {
  name: guid(ruleName, resourceGroup().id, subscription().subscriptionId)
  scope: logAnalyticsWorkspace // Log analytics workspace object
  properties: {
    displayName: ruleName
    order: 1
    triggeringLogic: {
      isEnabled: true
      expirationTimeUtc: ''
      triggersOn: 'Incidents'
      triggersWhen: 'Created'
      conditions: []
    }
    actions: [
      {
        order: 1
        actionType: 'ModifyProperties'
        actionConfiguration: {
          labels: [
            {
              labelName: 'Playground'
            }
          ]
        }
      }
    ]
  }
}

