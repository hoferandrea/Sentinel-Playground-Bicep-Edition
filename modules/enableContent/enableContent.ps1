#####################################################################################################################################################################################
# Andrea Hofer - https://www.linkedin.com/in/andrea-hofer-ch/ | 18.02.2023                                                                                     #
#####################################################################################################################################################################################
# enables analytics rules from templates considering defined connectors
# original EnableRules.ps1 by Javier Soriano: https://github.com/javiersoriano/sentinel-all-in-one/blob/master/ARMTemplates/Scripts/EnableRules.ps1                                 #
# i added some small modifications to add more execution output and support for multiple deployments (check if deployed before creating duplicates)                                 #
#####################################################################################################################################################################################

param(
    [Parameter(Mandatory = $true)][string]$ResourceGroup,
    [Parameter(Mandatory = $true)][string]$Workspace,
    [Parameter(Mandatory = $false)][string[]]$Connectors,
    [Parameter(Mandatory = $false)][string[]]$SeveritiesToInclude = @("Informational", "Low", "Medium", "High")
)

$analyticsRuleCounter = 0

$context = Get-AzContext  

$SubscriptionId = $context.Subscription.Id
Write-Host "Connected to Azure with subscription: $($context.Subscription) with $($context.Account.type) $($context.Account.id)"


$baseUri = "/subscriptions/${SubscriptionId}/resourceGroups/${ResourceGroup}/providers/Microsoft.OperationalInsights/workspaces/${Workspace}"
$templatesUri = "$baseUri/providers/Microsoft.SecurityInsights/alertRuleTemplates?api-version=2019-01-01-preview"
$alertUri = "$baseUri/providers/Microsoft.SecurityInsights/alertRules/"

$analyticsRulesUri = "$baseUri/providers/Microsoft.SecurityInsights/alertRules?api-version=2022-11-01"


try {
    Write-Host "get analytics rules templates..."
    $alertRulesTemplates = ((Invoke-AzRestMethod -Path $templatesUri -Method GET).Content | ConvertFrom-Json).value

    Write-Host "get already deployed analytics rules..."
    $analyticsRules = ((Invoke-AzRestMethod -Path $analyticsRulesUri -Method GET).Content | ConvertFrom-Json).value

    Write-Host "found $($alertRulesTemplates.Count) analytics rules templates"
    Write-Host "found $($analyticsRules.Count) deployed analytics rules"
}
catch {
    Write-Verbose $_
    Write-Error "Unable to get analytics rules with error code: $($_.Exception.Message)" -ErrorAction Stop
}

if ($Connectors) {
    foreach ($item in $alertRulesTemplates) {
        #Make sure that the rules is not already deployed
        If($analyticsRules.Properties.displayname -notcontains $item.properties.displayName) {
            
            #Make sure that the template's severity is one we want to include
            if ($SeveritiesToInclude.Contains($item.properties.severity)) {
                switch ($item.kind) {
                    "Scheduled" {
                        foreach ($connector in $item.properties.requiredDataConnectors) {
                            if ($connector.connectorId -in $Connectors) {
                                Write-Host "##############################################################################"
                                #$return += $item.properties
                                $guid = New-Guid
                                $alertUriGuid = $alertUri + $guid + '?api-version=2022-12-01-preview'

                                $properties = @{
                                    displayName           = $item.properties.displayName
                                    enabled               = $true
                                    suppressionDuration   = "PT5H"
                                    suppressionEnabled    = $false
                                    alertRuleTemplateName = $item.name
                                    description           = $item.properties.description
                                    query                 = $item.properties.query
                                    queryFrequency        = $item.properties.queryFrequency
                                    queryPeriod           = $item.properties.queryPeriod
                                    severity              = $item.properties.severity
                                    tactics               = $item.properties.tactics
                                    triggerOperator       = $item.properties.triggerOperator
                                    triggerThreshold      = $item.properties.triggerThreshold
                                    techniques            = $item.properties.techniques
                                    eventGroupingSettings = $item.properties.eventGroupingSettings
                                    templateVersion       = $item.properties.version
                                    entityMappings        = $item.properties.entityMappings
                                }

                                $alertBody = @{}
                                $alertBody | Add-Member -NotePropertyName kind -NotePropertyValue $item.kind -Force
                                $alertBody | Add-Member -NotePropertyName properties -NotePropertyValue $properties

                                try {
                                    Write-Host "enable scheduled rule $($item.properties.displayName)"
                                    $result = Invoke-AzRestMethod -Path $alertUriGuid -Method PUT -Payload ($alertBody | ConvertTo-Json -Depth 3)

                                    If($result.StatusCode -eq 200)
                                    {
                                        Write-Host "rule successfully enabled."
                                        $analyticsRuleCounter++
                                    }
                                    else {
                                        Write-Host "rule $($item.properties.displayName) was not enabled. status code: $($result.StatusCode). content: $($result.Content)."
                                    }

                                    
                                }
                                catch {
                                    Write-Host "Can't enable rule template with connectors: " $item.properties.requiredDataConnectors
                                    Write-Verbose $_
                                    Write-Error "Unable to create alert rule with error code: $($_.Exception.Message)" -ErrorAction Stop
                                }

                                break
                            }
                        }
                    }
                    "NRT" {
                        foreach ($connector in $item.properties.requiredDataConnectors) {
                            if ($connector.connectorId -in $Connectors) {
                                Write-Host "##############################################################################"
                                #$return += $item.properties
                                $guid = New-Guid
                                $alertUriGuid = $alertUri + $guid + '?api-version=2022-12-01-preview'

                                $properties = @{
                                    displayName           = $item.properties.displayName
                                    enabled               = $true
                                    suppressionDuration   = "PT5H"
                                    suppressionEnabled    = $false
                                    alertRuleTemplateName = $item.name
                                    description           = $item.properties.description
                                    query                 = $item.properties.query
                                    severity              = $item.properties.severity
                                    tactics               = $item.properties.tactics
                                    techniques            = $item.properties.techniques
                                    eventGroupingSettings = $item.properties.eventGroupingSettings
                                    templateVersion       = $item.properties.version
                                    entityMappings        = $item.properties.entityMappings
                                }

                                $alertBody = @{}
                                $alertBody | Add-Member -NotePropertyName kind -NotePropertyValue $item.kind -Force
                                $alertBody | Add-Member -NotePropertyName properties -NotePropertyValue $properties

                                try {
                                    Write-Host "enable nrt rule $($item.properties.displayName)"
                                    $result = Invoke-AzRestMethod -Path $alertUriGuid -Method PUT -Payload ($alertBody | ConvertTo-Json -Depth 3)

                                    If($result.StatusCode -eq 200)
                                    {
                                        Write-Host "rule successfully enabled."
                                        $analyticsRuleCounter++
                                    }
                                    else {
                                        Write-Host "rule $($item.properties.displayName) was not enabled. status code: $($result.StatusCode). content: $($result.Content)."
                                    }
                                }
                                catch {
                                    Write-Host "Can't enable rule template with connectors: " $item.properties.requiredDataConnectors
                                    Write-Verbose $_
                                    Write-Error "Unable to create alert rule with error code: $($_.Exception.Message)" -ErrorAction Stop
                                }

                                break
                            }
                        }
                    }
                }
            }
        } else {
            Write-Host "rule $($item.properties.displayName) already deployed - skip"
        }
    
    }
}

# create output
$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs["result"] = "$analyticsRuleCounter analytics rules enabled."