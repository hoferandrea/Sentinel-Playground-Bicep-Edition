param logAnalyticsWorkspaceName string = 'la-bicep'

// reference log analytics workspace
resource workspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: logAnalyticsWorkspaceName
}


// deploy automation rules
module automationRule 'AutomationRules/playGroundAutomationRule.bicep'= {
  name: 'automationRuleDeployment'
  scope: resourceGroup()
  params:{
    workspace: workspace.name
  }
}

// deploy analytics rules
module anaylticsRule 'AnalyticsRules/playGroundAnalyticsRule.bicep' = {
  name: 'analyticsRuleDeployment'
  scope: resourceGroup()
  params:{
    workspace: workspace.name
  }
}

// deploy queries (in a query pack)
module queryPack 'LogQueries/playGroundQuery.bicep' = {
  name: 'queryPackDeployment'
  scope: resourceGroup()
  params:{
  }
}

// deploy hunting queries
module huntingQuery 'HuntingQueries/playGroundHuntingQuery.bicep' = {
  name: 'huntingQueryDeployment'
  scope: resourceGroup()
  params:{
    workspace: workspace.name
  }
}

// deploy watchlists
module watchlist 'Watchlists/playGroundWatchlist.bicep' = {
  name: 'watchlistDeployment'
  scope: resourceGroup()
  params:{
    workspace: workspace.name
  }
}
