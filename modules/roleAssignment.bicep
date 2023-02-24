param roleDefinitionId string = '3e150937-b8fe-4cfb-8069-0eaf05ecd056'
param prinipalId string
param principalType string = 'ServicePrincipal'

// describe the role assignment
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id, roleDefinitionId, prinipalId)
  properties:{
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${roleDefinitionId}'
    principalId: prinipalId
    principalType: principalType
  }
}
