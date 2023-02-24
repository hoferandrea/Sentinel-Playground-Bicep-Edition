#######################################################################################################################################
# Andrea Hofer - https://www.linkedin.com/in/andrea-hofer-ch/ | 19.02.2023                                       #
#######################################################################################################################################
# creates and incident using the SecurityInsights/incidents endpoint                                                                  #       
#######################################################################################################################################

param(
    [Parameter(Mandatory = $true)][string]$ResourceGroup,
    [Parameter(Mandatory = $true)][string]$Workspace
)

$context = Get-AzContext  

$SubscriptionId = $context.Subscription.Id
Write-Host "Connected to Azure with subscription: $($context.Subscription) with $($context.Account.type) $($context.Account.id)"

# build incident url
$inicdentUri = "/subscriptions/${SubscriptionId}/resourceGroups/${ResourceGroup}/providers/Microsoft.OperationalInsights/workspaces/${Workspace}/providers/Microsoft.SecurityInsights/incidents/$(New-Guid)?api-version=2022-11-01"

# build incident
$properties = @{
    title                       = "Welcome to the Sentinel Playground!"
    description                 = "Have fun and happy testing."
    severity                    = "High"
    status                      = "New"
}

$incidentBody = @{}
$incidentBody | Add-Member -NotePropertyName etag -NotePropertyValue "0300bf09-0000-0000-0000-5c37296e0000"
$incidentBody | Add-Member -NotePropertyName properties -NotePropertyValue $properties

# put incident
$result = Invoke-AzRestMethod -Path $inicdentUri -Method PUT -Payload ($incidentBody | ConvertTo-Json -Depth 3)
$convertedResult = $result.Content | ConvertFrom-Json
Write-Host "incident $($convertedResult.properties.incidentNumber) created."

# create output
$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs["result"] = "incident with number $($convertedResult.properties.incidentNumber) created."