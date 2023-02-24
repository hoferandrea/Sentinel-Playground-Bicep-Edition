//workspace name (automatically assigned during sentinel content deployment)
param workspace string

//watchlist properties (edit)
var displayName = 'Playground Watchlist'
var description = 'Watchlist queried by xxx'
var searchKey = 'header3'
var csvFileName = 'playGroundWatchlist.csv'
var watchlistVersion = 2 //used to trigger deployments using smart deployment (/fail safe)

//preset properties (do not edit)
var watchlistProvider = 'Playground SOC'
var source = 'GitHub Repository'
var resourceGuid = guid(displayName,resourceGroup().id, subscription().subscriptionId)

//describe the watchlist (the resource symbolic name 'watchlist1' doesn't matter as we don't need it)
resource symbolicname 'Microsoft.OperationalInsights/workspaces/providers/Watchlists@2021-03-01-preview' = {
  name: '${workspace}/Microsoft.SecurityInsights/${resourceGuid}'
  kind: ''
  properties: {
    displayName: displayName
    source: source
    description: description
    provider: watchlistProvider
    isDeleted: false
    labels: []
    defaultDuration: 'P1000Y'
    contentType: 'Text/Csv'
    numberOfLinesToSkip: 0
    itemsSearchKey: searchKey
    rawContent: format('''{0}''', loadTextContent(csvFileName))  //allow multi line strings from csv files
  }
}
     