param sentinelApiConnectionName string

// describe the api connection
resource sentinelApiConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: sentinelApiConnectionName
  location: resourceGroup().location
  properties: {
    displayName: sentinelApiConnectionName
    parameterValueType: 'Alternative'
    api: {
      id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${resourceGroup().location}/managedApis/azuresentinel'
    }
  }
}

output sentinelApiConnectionName string = sentinelApiConnection.name
