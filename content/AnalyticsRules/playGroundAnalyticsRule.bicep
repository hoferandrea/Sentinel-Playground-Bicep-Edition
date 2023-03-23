/*
Template Version: 1.1
Autor: Andrea Hofer
Date: 23.03.2023

Special Remarks:
This template uses Custom Details to Tag Incidents (stable/experimental) using an automation rule.
*/

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
var query = '''
SigninLogs
| take 1
| extend ContentProvider='HoferLabsAG'
| extend ContentStatus='experimental'
'''

resource symbolicname 'Microsoft.SecurityInsights/alertRules@2022-10-01-preview' = {
    name: guid(ruleName)
    kind: 'Scheduled'
    scope: logAnalyticsWorkspace
    properties: {
      displayName: ruleName
      description: description
      severity: severity
      query: query
      enabled: true
      customDetails: {
        ContentProvider: 'ContentProvider'
        ContentStatus: 'ContentStatus'
      }
      alertRuleTemplateName: null
      templateVersion: null
      eventGroupingSettings: {
        aggregationKind: 'SingleAlert'
      }
      incidentConfiguration: {
        createIncident: true
      }
      queryFrequency: 'PT5H'
      queryPeriod: 'PT5H'
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

