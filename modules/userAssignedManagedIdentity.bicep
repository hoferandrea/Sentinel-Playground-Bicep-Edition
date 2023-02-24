param userAssignedManagedIdentityName string

// describe the user assigned managed identity
resource userAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: userAssignedManagedIdentityName
  location: resourceGroup().location
}

output uamiPrincipalId string = userAssignedManagedIdentity.properties.principalId
output uamiName string = userAssignedManagedIdentity.name
