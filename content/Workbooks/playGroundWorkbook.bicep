// workspace name (automatically assigned during sentinel content deployment)
param workspace string

// reference the workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: workspace
}

var workbookDisplayName = 'Playground Workbook'
var sourceId = '/subscriptions/${subscription().id}/resourcegroups/${resourceGroup().name}/providers/microsoft.operationalinsights/workspaces/${logAnalyticsWorkspace.name}'


resource workbook 'microsoft.insights/workbooks@2021-03-08' = {
  name: guid(workbookDisplayName)
  location: resourceGroup().location
  kind: 'shared'
  properties: {
    displayName: workbookDisplayName
    serializedData: '{"version":"Notebook/1.0","items":[{"type":1,"content":{"json":"## Playground workbook Template\\n---\\n\\nThis is the default new workbook query:"},"name":"text - 2"},{"type":3,"content":{"version":"KqlItem/1.0","query":"union withsource=_TableName *\\n| summarize Count=count() by _TableName\\n| render barchart","size":1,"queryType":0,"resourceType":"microsoft.operationalinsights/workspaces"},"name":"query - 2"}],"isLocked":false,"fallbackResourceIds":["${sourceId}"],"fromTemplateId":"sentinel-UserWorkbook"}'
    version: '1.0'
    category: 'sentinel'
    sourceId: sourceId
  }
  dependsOn: []
}
