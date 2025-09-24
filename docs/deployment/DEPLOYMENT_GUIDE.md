# Marketing Insights Solution - Deployment Guide

This guide walks you through deploying the Marketing Insights solution to Azure using Infrastructure as Code (Bicep) and GitHub Actions.

## Prerequisites

Before deploying, ensure you have:

1. **Azure Subscription** with appropriate permissions
2. **Azure CLI** installed and configured
3. **GitHub Repository** with the solution code
4. **Microsoft 365 Tenant** with Teams and required licenses
5. **Azure Active Directory** app registrations

## Environment Setup

The solution supports three environments:
- **dev**: Development environment with minimal resources
- **test**: Testing environment with production-like configuration  
- **prod**: Production environment with high availability and performance

## Step 1: Azure Prerequisites

### 1.1 Create Azure AD App Registrations

Create two app registrations:

**Main Application Registration:**
```bash
az ad app create \
    --display-name "Marketing Insights - Main" \
    --web-home-page-url "https://mi-prod-func-{uniqueSuffix}.azurewebsites.net" \
    --web-redirect-uris "https://mi-prod-func-{uniqueSuffix}.azurewebsites.net/.auth/login/aad/callback"
```

**Graph API Registration:**
```bash
az ad app create \
    --display-name "Marketing Insights - Graph" \
    --required-resource-accesses '[
        {
            "resourceAppId": "00000003-0000-0000-c000-000000000000",
            "resourceAccess": [
                {
                    "id": "df021288-bdef-4463-88db-98f22de89214",
                    "type": "Role"
                }
            ]
        }
    ]'
```

### 1.2 Create Service Principal for GitHub Actions

```bash
az ad sp create-for-rbac \
    --name "GitHub-Actions-MarketingInsights" \
    --role contributor \
    --scopes /subscriptions/{subscription-id} \
    --sdk-auth
```

Save the output JSON for GitHub Secrets configuration.

## Step 2: GitHub Repository Setup

### 2.1 Configure GitHub Secrets

Add the following secrets to your GitHub repository:

| Secret Name | Description | Value |
|-------------|-------------|-------|
| `AZURE_CREDENTIALS` | Service principal credentials | JSON from Step 1.2 |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID | Your subscription ID |
| `AZURE_TENANT_ID` | Azure AD tenant ID | Your tenant ID |
| `AZURE_CLIENT_ID` | Main app registration client ID | From Step 1.1 |
| `AZURE_CLIENT_SECRET` | Main app registration secret | Generate and store |
| `GRAPH_CLIENT_ID` | Graph app registration client ID | From Step 1.1 |
| `GRAPH_CLIENT_SECRET` | Graph app registration secret | Generate and store |

### 2.2 Update Parameter Files

Update the parameter files with your subscription ID:
- `infrastructure/environments/dev.parameters.json`
- `infrastructure/environments/test.parameters.json`  
- `infrastructure/environments/prod.parameters.json`

Replace `{subscription-id}` with your actual subscription ID.

## Step 3: Manual Infrastructure Deployment (Optional)

If you prefer manual deployment over GitHub Actions:

### 3.1 Deploy to Development

```bash
# Navigate to repository root
cd /path/to/repository

# Deploy development environment
./scripts/deployment/deploy-infrastructure.sh dev {subscription-id}
```

### 3.2 Deploy to Production

```bash
# Deploy production environment
./scripts/deployment/deploy-infrastructure.sh prod {subscription-id}
```

## Step 4: GitHub Actions Deployment

### 4.1 Automatic Deployment

Push to main branch triggers automatic deployment to production:

```bash
git push origin main
```

### 4.2 Manual Environment Deployment

Use GitHub Actions workflow dispatch for specific environments:

1. Go to **Actions** tab in GitHub
2. Select **CI/CD Pipeline** workflow
3. Click **Run workflow**
4. Select target environment (dev/test/prod)
5. Click **Run workflow**

## Step 5: Post-Deployment Configuration

### 5.1 Database Setup

The database setup runs automatically during GitHub Actions deployment. For manual setup:

```bash
# Set environment variables
export KEYVAULT_URI="https://mi-{env}-kv-{suffix}.vault.azure.net/"

# Run database setup
./scripts/maintenance/run-database-setup.sh {environment}
```

### 5.2 Configure Microsoft Graph API Permissions

1. Go to Azure AD > App registrations > Marketing Insights - Graph
2. Navigate to **API permissions**
3. Grant admin consent for the required permissions
4. Verify permissions are granted with green checkmarks

### 5.3 Deploy M365 Agent

1. Package the agent:
```bash
cd src/agents
npm ci
npm run build
npm run package
```

2. Upload `marketing-insights-agent.zip` to Teams App Studio or Partner Center

### 5.4 Update Application Settings

Update Function App settings with configuration values:

```bash
# Update function app settings
az functionapp config appsettings set \
    --name mi-{env}-func-{suffix} \
    --resource-group mi-{env}-rg \
    --settings \
    "GraphClientId={graph-client-id}" \
    "GraphClientSecret={graph-client-secret}"
```

## Step 6: Verification and Testing

### 6.1 Health Checks

Verify deployment health:

```bash
# Check Function App health
curl https://mi-{env}-func-{suffix}.azurewebsites.net/api/health

# Check database connectivity
./scripts/maintenance/test-database-connection.sh {environment}
```

### 6.2 API Testing

Test the REST API endpoints:

```bash
# Get transcripts
curl -X GET "https://mi-{env}-func-{suffix}.azurewebsites.net/api/transcripts" \
     -H "x-functions-key: {function-key}"

# Search transcripts
curl -X GET "https://mi-{env}-func-{suffix}.azurewebsites.net/api/transcripts/search?q=marketing" \
     -H "x-functions-key: {function-key}"
```

### 6.3 M365 Agent Testing

1. Install the agent in Microsoft Teams
2. Test conversational interface
3. Verify data retrieval and insights generation

## Step 7: Monitoring and Maintenance

### 7.1 Enable Monitoring

Application Insights is configured automatically. Create custom dashboards:

1. Navigate to Application Insights in Azure Portal
2. Create workbook for transcript processing metrics
3. Set up alerts for failures and performance issues

### 7.2 Cost Management

Set up cost alerts and budgets:

```bash
az consumption budget create \
    --budget-name "MarketingInsights-{env}" \
    --amount 1000 \
    --time-grain Monthly \
    --time-period start-date=2024-01-01 end-date=2024-12-31
```

### 7.3 Backup and Recovery

- **Database**: Automated backups are enabled
- **Configuration**: Store secrets in Key Vault
- **Code**: Version control with Git

## Step 8: Future Extensibility

### 8.1 Enable Azure Search

To enable Azure Search for enhanced search capabilities:

1. Update parameter files: `"enableAzureSearch": true`
2. Redeploy infrastructure
3. Configure search indexing in application settings

### 8.2 Enable Microsoft Fabric

To enable Microsoft Fabric integration:

1. Set up Fabric workspace and datasets
2. Update configuration with Fabric connection details
3. Update parameter files: `"enableFabricIntegration": true`
4. Redeploy solution

## Troubleshooting

### Common Issues

**Deployment Failures:**
- Verify Azure CLI authentication: `az account show`
- Check resource quotas and limits
- Review deployment logs in Azure Portal

**Function App Issues:**
- Check Application Insights logs
- Verify Key Vault access permissions
- Test database connectivity

**M365 Agent Issues:**
- Verify app registration permissions
- Check Teams app manifest validation
- Test API endpoints independently

### Support and Documentation

- **Architecture**: See [Architecture.md](../Architecture.md)
- **API Documentation**: Available at Function App `/swagger` endpoint
- **Logs**: Application Insights and Function App logs
- **Monitoring**: Azure Monitor dashboards

## Security Considerations

### 1. Secrets Management
All secrets are stored in Azure Key Vault following these best practices:

#### Key Vault Secret Naming Conventions
```
SqlConnectionString       # Database connection string
OpenAIKey                # Azure OpenAI API key
OpenAIEndpoint           # Azure OpenAI endpoint URL
GraphClientSecret        # Microsoft Graph client secret
StorageConnectionString  # Azure Storage connection string
AppInsightsKey          # Application Insights instrumentation key
```

#### Managed Identity Setup
The Function App uses System-Assigned Managed Identity to access Key Vault:
- **Role**: Key Vault Secrets User
- **Scope**: Key Vault resource
- **Access**: Read secrets only (principle of least privilege)

#### Key Vault Reference Syntax
Function App settings reference Key Vault secrets using:
```
@Microsoft.KeyVault(VaultName={vault-name};SecretName={secret-name})
```

### 2. Network Security
- Function Apps use HTTPS only
- Key Vault allows public access but uses RBAC
- SQL Database uses encrypted connections
- All inter-service communication is encrypted

### 3. Access Control
- RBAC and Azure AD integration throughout
- Service principals for CI/CD pipelines
- Managed identities for Azure service access
- Principle of least privilege enforced

### 4. Data Protection
- Encryption at rest for all storage
- Encryption in transit for all communications
- Personal data anonymization where required
- Audit logging for compliance

### 5. Compliance
- Audit logging and data retention policies
- Security scanning in CI/CD pipeline
- Regular security assessments
- Documentation of security controls

## Next Steps

After successful deployment:

1. **User Training**: Train end users on the conversational interface
2. **Data Migration**: Import existing transcript data if needed
3. **Customization**: Adjust AI prompts and themes for your organization
4. **Integration**: Connect with additional data sources as needed
5. **Scaling**: Monitor usage and scale resources accordingly