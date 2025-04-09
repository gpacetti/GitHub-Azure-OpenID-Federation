#Install this packages and restart the powershell windows to achive the executale path
#Install-Module Az.ManagedServiceIdentity -Force
#winget install --id GitHub.cli

#run the script in the directory with the .github folder that you want to configure

Connect-AzAccount # Follow the steps needed to sign in

Set-AzContext -SubscriptionId "" # Replace with subscription idof the target subscription

$ResourceGroupName  = "sw-avm-sandbox-sand-rg-we" # Name of a new resource group sw-<workload>-<appenv>-<app>-rg-<#optional#>

$Location           = "westeurope"          # Location for the resource grop

$IdentityName       = "sw-avm-sandbox-github-rg-we-lzenv-mi"   # Name of the Managed Identity sw-<workload>-<appenv>-<app>-<resourcetype>-<#optional#>-<region>-<lzenv>-<provider>

$GhUserName         = "giuseppe.pacetti@outlook.it"     # Your GitHub username

$GhRepoName         = "Playground"   # Name of your existing repository

$GhEnvName          = "Azure" # For the Environment you will set up in GitHub

$RoleDefinitionName = "Owner" # The role you want to assign to the managed identity

#* Create resource group

$rg = New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Force



#* Create user assigned managed identity

$identity = New-AzUserAssignedIdentity -ResourceGroupName $rg.ResourceGroupName -Name $IdentityName -Location $Location



#* Create subscription-level role assignment for the managed identity

#New-AzRoleAssignment -PrincipalId $identity.PrincipalId -RoleDefinitionName $RoleDefinitionName -ObjectType "ServicePrincipal"

#* Create credentials for user assigned managed identity

#New-AzFederatedIdentityCredentials -ResourceGroupName $rg.ResourceGroupName -IdentityName $identity.Name -Name $GhRepoName -Issuer "https://token.actions.githubusercontent.com" -Subject "repo:${GhUserName}/${GhRepoName}:environment:${GhEnvName}"

New-AzFederatedIdentityCredentials -ResourceGroupName $rg.ResourceGroupName -IdentityName $identity.Name -Name $GhRepoName -Issuer "https://token.actions.githubusercontent.com" -Subject "repo:${GhUserName}/${GhRepoName}"
#* Output subscription id, client id and tenant id

 $out = [ordered]@{

     SUBSCRIPTION_ID = $(Get-AzContext).Subscription.Id

     CLIENT_ID = $identity.ClientId

     TENANT_ID = $identity.TenantId

    }

  Write-Host ($out | ConvertTo-Json | Out-String)

# gh auth login -w -p https

# gh secret set SUBSCRIPTION_ID --body $out.SUBSCRIPTION_ID --env $GhEnvName
# gh secret set CLIENT_ID --body $out.CLIENT_ID --env $GhEnvName
# gh secret set TENANT_ID --body $out.TENANT_ID --env $GhEnvName

#TEST---------------------------------

# gh auth login -w -p https

# $GhEnvName          = "Azure" # For the Environment you will set up in GitHub

# $out = [ordered]@{

#     SUBSCRIPTION_ID = "eb38b636-105c-41e3-b705-87029297ad99"

#     CLIENT_ID = "72a8e320-ba2f-47af-a963-5ac904ea50be"

#     TENANT_ID = "16b3c013-d300-468d-ac64-7eda0820b6d3"

# }

# gh secret set SUBSCRIPTION_ID --body $out.SUBSCRIPTION_ID 
# gh secret set CLIENT_ID --body $out.CLIENT_ID 
# gh secret set TENANT_ID --body $out.TENANT_ID 
