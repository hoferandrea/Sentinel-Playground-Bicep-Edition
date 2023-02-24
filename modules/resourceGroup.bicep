targetScope = 'subscription'
param ressourceGroupName string = 'rg-${uniqueString(subscription().id)}'
param ressourceGroupLocation string = 'switzerlandnorth'

// describe the resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: ressourceGroupName
  location: ressourceGroupLocation
}


