/*
Template Version: 1.1
Autor: Andrea Hofer
Date: 23.03.2023

Special Remarks:
- etag is needed for updates (https://github.com/MicrosoftDocs/azure-docs/issues/49275)
*/

// workspace name (automatically assigned during sentinel content deployment)
param workspace string

// reference the workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: workspace
}

// function properties (edit)
var functionName = 'playGroundFunction'
var functionCategory = 'playGround'
var query = '''
SigninLogs
| take 1010
'''

// describe the function
// etag is needed for updates (https://github.com/MicrosoftDocs/azure-docs/issues/49275)
resource workspaceName_FunctionDeployment 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  name: '${logAnalyticsWorkspace.name}/${functionName}'
  properties: {
    etag: '*'
    displayName: functionName
    category: functionCategory
    functionAlias: functionName
    query: query
    version: 2
  }
}
