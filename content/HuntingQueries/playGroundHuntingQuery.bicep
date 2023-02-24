// workspace name (automatically assigned during sentinel content deployment)
param workspace string

// reference the workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: workspace
}

// hunting query properties (edit)
var queryName = 'Playground Hunting Query'
var description = 'Playground Hunting Query'
// dont remove the multiline string (''') - this way, the query formatting is preserved
var query = '''SigninLogs
| take 1
'''

resource symbolicname 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: logAnalyticsWorkspace
  name: guid(queryName)
  properties: {
    category: 'Hunting Queries'
    etag: '*'
    displayName: queryName
    query: query
    tags: [
      {
        name: 'description'
        value: description
      }
      {
        name: 'tactics'
        value: 'DefenseEvasion'
      }
      {
        name: 'techniques'
        value: 'T1218,T1218.005'
      }
      {
        name: 'createdBy'
        value: 'playground'
      }
      {
        name: 'createdTimeUtc'
        value: '11/25/2022 12:30:05'
      }
    ]
    version: 2
  }
}
