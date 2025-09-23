@description('The environment name (dev, test, prod)')
param environment string = 'dev'

@description('The location for all resources')
param location string = resourceGroup().location

@description('The unique suffix for resource names')
param uniqueSuffix string = uniqueString(resourceGroup().id)

@description('SQL Server administrator username')
@secure()
param sqlAdminUsername string

@description('SQL Server administrator password')
@secure()
param sqlAdminPassword string

@description('Azure OpenAI service name')
param openAiServiceName string = 'openai-${environment}-${uniqueSuffix}'

@description('Enable Azure Search for future extensibility')
param enableAzureSearch bool = false

@description('Enable Microsoft Fabric integration for future extensibility')
param enableFabricIntegration bool = false

// Variables
var resourcePrefix = 'mi-${environment}'
var sqlServerName = '${resourcePrefix}-sql-${uniqueSuffix}'
var databaseName = '${resourcePrefix}-db'
var functionAppName = '${resourcePrefix}-func-${uniqueSuffix}'
var storageAccountName = '${resourcePrefix}sa${uniqueSuffix}'
var appInsightsName = '${resourcePrefix}-ai'
var appServicePlanName = '${resourcePrefix}-asp'
var keyVaultName = '${resourcePrefix}-kv-${uniqueSuffix}'

// Resource Group Tags
var commonTags = {
  Environment: environment
  Project: 'Marketing-Insights'
  ManagedBy: 'Bicep'
  CostCenter: 'Marketing'
}

// Storage Account for Azure Functions
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: replace(storageAccountName, '-', '')
  location: location
  tags: commonTags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

// Application Insights
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  tags: commonTags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// App Service Plan for Azure Functions
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  tags: commonTags
  sku: {
    name: environment == 'prod' ? 'P1v2' : 'B1'
    tier: environment == 'prod' ? 'PremiumV2' : 'Basic'
  }
  kind: 'functionapp'
  properties: {
    reserved: false
  }
}

// Azure Functions App
resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: functionAppName
  location: location
  tags: commonTags
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: functionAppName
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'KeyVaultUri'
          value: keyVault.properties.vaultUri
        }
      ]
      netFrameworkVersion: 'v6.0'
      use32BitWorkerProcess: false
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Key Vault for secrets management
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: commonTags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enableRbacAuthorization: true
    publicNetworkAccess: 'Enabled'
    accessPolicies: []
  }
}

// Grant Key Vault access to Function App
resource keyVaultAccessPolicy 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: keyVault
  name: guid(keyVault.id, functionApp.id, 'Key Vault Secrets User')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') // Key Vault Secrets User
    principalId: functionApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// SQL Server
resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' = {
  name: sqlServerName
  location: location
  tags: commonTags
  properties: {
    administratorLogin: sqlAdminUsername
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    publicNetworkAccess: 'Enabled'
  }
}

// SQL Database
resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  tags: commonTags
  sku: {
    name: environment == 'prod' ? 'S2' : 'S0'
    tier: 'Standard'
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: environment == 'prod' ? 268435456000 : 2147483648 // 250GB for prod, 2GB for dev/test
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: environment == 'prod'
  }
}

// SQL Server firewall rule for Azure services
resource sqlFirewallRule 'Microsoft.Sql/servers/firewallRules@2023-05-01-preview' = {
  parent: sqlServer
  name: 'AllowAzureServices'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

// Azure OpenAI Service
resource openAiService 'Microsoft.CognitiveServices/accounts@2023-10-01-preview' = {
  name: openAiServiceName
  location: location
  tags: commonTags
  sku: {
    name: 'S0'
  }
  kind: 'OpenAI'
  properties: {
    customSubDomainName: openAiServiceName
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
  }
}

// GPT-4 Model Deployment
resource gpt4ModelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2023-10-01-preview' = {
  parent: openAiService
  name: 'gpt-4'
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4'
      version: '0613'
    }
    scaleSettings: {
      scaleType: 'Standard'
      capacity: environment == 'prod' ? 40 : 10
    }
  }
}

// Conditional Azure Search Service (for future extensibility)
resource searchService 'Microsoft.Search/searchServices@2023-11-01' = if (enableAzureSearch) {
  name: '${resourcePrefix}-search-${uniqueSuffix}'
  location: location
  tags: commonTags
  sku: {
    name: environment == 'prod' ? 'standard' : 'basic'
  }
  properties: {
    replicaCount: environment == 'prod' ? 2 : 1
    partitionCount: 1
    hostingMode: 'default'
    publicNetworkAccess: 'enabled'
    networkRuleSet: {
      ipRules: []
    }
    disableLocalAuth: false
  }
}

// Store secrets in Key Vault
resource sqlConnectionStringSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'SqlConnectionString'
  properties: {
    value: 'Server=tcp:${sqlServer.properties.fullyQualifiedDomainName},1433;Initial Catalog=${databaseName};Persist Security Info=False;User ID=${sqlAdminUsername};Password=${sqlAdminPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
  }
}

resource openAiKeySecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'OpenAIKey'
  properties: {
    value: openAiService.listKeys().key1
  }
}

resource openAiEndpointSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: 'OpenAIEndpoint'
  properties: {
    value: openAiService.properties.endpoint
  }
}

// Outputs
output functionAppName string = functionApp.name
output sqlServerName string = sqlServer.name
output databaseName string = sqlDatabase.name
output keyVaultUri string = keyVault.properties.vaultUri
output openAiServiceName string = openAiService.name
output openAiEndpoint string = openAiService.properties.endpoint
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey
output searchServiceName string = enableAzureSearch ? searchService.name : ''
output resourceGroupName string = resourceGroup().name