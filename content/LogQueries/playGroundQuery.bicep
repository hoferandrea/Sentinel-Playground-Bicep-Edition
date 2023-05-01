/*
Template Version: 1.1
Autor: Andrea Hofer
Date: 23.03.2023

Special Remarks:
- query pack get automatically created if doesn't exist
*/

// name of the query pack
var defaultQueryPackName = 'playGroundQueryPack'

// describe the query pack
resource queryPack 'microsoft.operationalInsights/querypacks@2019-09-01' = {
  name: defaultQueryPackName
  location: resourceGroup().location
  properties: {
    
  }
}

// describe the query
var queryName = 'playground query 1'
var description = 'playground query 1'
var query = '''
print "playGround"
'''
resource queryInQueryPack 'Microsoft.OperationalInsights/querypacks/queries@2019-09-01' = {
  parent: queryPack
  name: guid(queryName, resourceGroup().id, subscription().subscriptionId)
  properties: {
    displayName: queryName
    description: description
    body: query
    related: {
      categories: [
        'security'
      ]
      resourceTypes: [
        'microsoft.operationalinsights/workspaces'
      ]
    }
    tags: {
      labels: [
        'playGround'
      ]
    }
  }
}
