// workspace name (automatically assigned during sentinel content deployment)
param workspace string

// reference the workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: workspace
}

// analytics rules properties (edit)
var ruleName = 'Playground Analytics Rule'
var description = 'Description'
var severity = 'Informational'
// dont remove the multiline string (''') - this way, the query formatting is preserved
var query = '''SigninLogs
| take 1
'''

resource symbolicname 'Microsoft.SecurityInsights/alertRules@2022-10-01-preview' = {
    name: guid(ruleName)
    kind: 'Scheduled'
    scope: logAnalyticsWorkspace
    properties: {
      customDetails: {}
      description: description
      displayName: ruleName
      enabled: true
      alertRuleTemplateName: null // important if you want to update to update from the analytics template (preview)
      templateVersion: null // important if you want to update to update from the analytics template (preview)
      eventGroupingSettings: {
        aggregationKind: 'SingleAlert'
      }
      incidentConfiguration: {
        createIncident: true
      }
      query: query
      queryFrequency: 'PT5H'
      queryPeriod: 'PT5H'
      severity: severity
      suppressionDuration: 'PT5H'
      suppressionEnabled: false
      tactics: [
        'DefenseEvasion'
      ]
      techniques: [
        'T1562'
      ]
      entityMappings: null
      triggerOperator: 'GreaterThan'
      triggerThreshold: 0
    }    
  }

