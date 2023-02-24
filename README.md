# intro
Sentinel playground is a project that aims to speed up deployment and configuration tasks of a sentinel lab/demo environment, including sample content. This project seeks to use bicep only.

## feedback / contributions / bugs / feature requests
Everyone is welcome to contribute / provide feedback / request features / report bugs / whatever -> create an issue or contact me directly: https://www.linkedin.com/in/andrea-hofer-ch/


# sentinel playground - **bicep edition**
## overview
The following components are deployed/configured:
- resource group
- log analytics workspace + sentinel solution
- log analytics workspace config (retention, daily cap)
- sentinel config (ueba, anomalies)
- data connectors
    - azure activity
    - azure ad 
- demo playbook (with a user-assigned managed identity + required permissions)
- sentinel permissions to trigger playbooks
- analytics rule (template)
- automation rule (template)
- log query (in a query pack) (template)
- watchlist (with CSV-support) (template)
- all analytics rules for azure ad and azure activities are enabled

## preparation
- make sure that you have the resource provider microsoft.insights registered (subscription -> resource providers)
- make sure that you have less than 5 aad diagnostic settings configured (5 is max)
- [az cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed (check with `az --help`) or equivalent powershell module
- if you need to build arm from bicep: az bicep module installed (check with `az bicep --help`, inlcluded in newer az releases)
- if you need to edit bicep files: [vsc](https://code.visualstudio.com/) with the [official bicep extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-bicep)
## deployment
download the latest release (on the right)

deploy either with default parameters (laName=la-sentinel-playground-01, rgName=rg-sentinel-playground-01)
```
az deployment sub create --template-file .\mainPlayground.bicep --location switzerlandnorth
```
or deploy with custom parameters:
- **rgName:** resource group name *-> rg-sentinel-playground-01*
- **laName:** log analytics workspace name *-> la-sentinel-playground-01*
- **uamiName:** name of the user-assigned managed identity (used in playbook) *-> mi-sentinel-playbooks*
- **laRetentionDays:** log analytics workspace retention in days *-> 30*
- **laDailyCapGb:** log analytics workspace daily cap in GB (only integers are supported) *-> 1*
```
az deployment sub create --template-file .\mainPlayground.bicep --location switzerlandnorth --parameters rgName=rg-sentinel-playground-01 laName=la-sentinel-playground-01 uamiName=mi-sentinel-playbooks laRetentionDays=30 laDailyCapGb=1
```

you can also deploy the prebuilt arm file (mainInfra.json) directly in azure using 'Deploy a custom template'

to check progress: go to your subscription -> depyloments -> mainPlayground:

![deployment progress](doc/images/infraDeployment.png)

![deployment progress output](doc/images/infraDeploymentOutputs.png)


## post deployment checks
- create a new incident, trigger the playbook "la-sentinel-addCommentToIncident" -> check if comment is added
- check data connectors (should take ~10min until events are received)
- check sentinel config (ueba, anomalies)

## update the infra
change code/parameters (e.g. log analytics retention days), redeploy with the same commands as in previous deployment -> the infra gets updated.

check the "faq / limitations / bugs" bugs chapter...

## useful commands
delete created resource group (with all resources in it)
```
az group delete --name rg-sentinel-playground-01 --yes
```

show existing diagnostic setting for azure activity
```
az monitor diagnostic-settings subscription list
```

delete existing diagnostic setting for azure activity
```
az monitor diagnostic-settings subscription delete --name subscriptionToLa
```
build arm from bicep (not really needed)
```
az bicep build --file .\sentinelInfra\mainInfra.bicep
```

## faq / limitations / bugs
- if you rerun the deployment (to update the infra), the deployment of the sentinel config EntitiyAnalystics resource fails with "Bad Request: Update request should provide ETag". Other resources get updated. This is a known API issue: https://github.com/Azure/bicep/issues/9206 (https://github.com/Azure/bicep/issues/5256 / https://techcommunity.microsoft.com/t5/azure-observability/update-saved-search/m-p/328553). 

# to do
- ~~replace this "to do" list with github issues :)~~ -> check/create issues for bugs / features requests / ...
