# Local Development Guide

This guide provides step-by-step instructions for setting up and running the Marketing Insights solution locally, without requiring full Azure deployment.

## Prerequisites

Ensure you have the following tools installed:

- **.NET SDK 8.0+**: `dotnet --version`
- **Node.js 18+**: `node --version`
- **Azure CLI**: `az --version`
- **Docker Desktop**: For running local SQL Server and Azurite
- **Visual Studio Code** or **Visual Studio** (recommended)

## Quick Start (Happy Path)

For experienced developers, here's the minimal sequence to get the solution running locally:

1. **Clone and Build**:
   ```bash
   git clone <repository-url>
   cd testNewInsights
   dotnet restore && dotnet build
   cd src/agents && npm install
   ```

2. **Start Local Services**:
   ```bash
   # Terminal 1: Start SQL Server
   docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=DevPassword123!" -p 1433:1433 -d mcr.microsoft.com/mssql/server:2022-latest
   
   # Terminal 2: Start Azurite
   docker run -p 10000:10000 -p 10001:10001 -p 10002:10002 mcr.microsoft.com/azure-storage/azurite
   ```

3. **Configure Local Settings**:
   ```bash
   cp src/functions/local.settings.example.json src/functions/local.settings.json
   # Edit local.settings.json with your local database and mock endpoints
   ```

4. **Run Applications**:
   ```bash
   # Terminal 3: Start Azure Functions
   cd src/functions && func start
   
   # Terminal 4: Start M365 Agent (development mode)
   cd src/agents && npm run dev
   ```

5. **Verify Setup**: Navigate to `http://localhost:7071` to see the Function App running.

## Detailed Setup Instructions

### 1. Local Infrastructure Setup

#### SQL Server with Docker

Start a local SQL Server instance for development:

```bash
# Start SQL Server container
docker run --name marketinginsights-sql \
  -e "ACCEPT_EULA=Y" \
  -e "MSSQL_SA_PASSWORD=DevPassword123!" \
  -p 1433:1433 \
  -d mcr.microsoft.com/mssql/server:2022-latest

# Verify connection
sqlcmd -S localhost,1433 -U sa -P "DevPassword123!" -Q "SELECT @@VERSION"
```

**Connection String**: `Server=localhost,1433;Database=MarketingInsights;User Id=sa;Password=DevPassword123!;TrustServerCertificate=true;`

#### Azurite (Azure Storage Emulator)

Start Azurite for local blob and table storage:

```bash
# Using Docker
docker run --name marketinginsights-storage \
  -p 10000:10000 -p 10001:10001 -p 10002:10002 \
  -d mcr.microsoft.com/azure-storage/azurite

# Or using npm (alternative)
npm install -g azurite
azurite --silent --location ./azurite --debug ./azurite/debug.log
```

**Storage Connection String**: `UseDevelopmentStorage=true` or `DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://127.0.0.1:10000/devstoreaccount1;QueueEndpoint=http://127.0.0.1:10001/devstoreaccount1;TableEndpoint=http://127.0.0.1:10002/devstoreaccount1;`

### 2. Database Setup

Create and initialize the local database:

```bash
# Create database
sqlcmd -S localhost,1433 -U sa -P "DevPassword123!" -Q "CREATE DATABASE MarketingInsights"

# Run database setup scripts (if available)
cd scripts/maintenance
./run-database-setup.sh dev
```

If the script requires Azure authentication, you can run SQL scripts manually:

```bash
# Apply schema scripts manually
sqlcmd -S localhost,1433 -U sa -P "DevPassword123!" -d MarketingInsights -i path/to/schema.sql
```

### 3. Azure Functions Local Development

#### Configure Local Settings

1. Copy the example configuration:
   ```bash
   cp src/functions/local.settings.example.json src/functions/local.settings.json
   ```

2. Update `local.settings.json` with your local configuration (see [Configuration Reference](#configuration-reference) below).

#### Run Azure Functions

```bash
cd src/functions

# Install Azure Functions Core Tools (if not already installed)
npm install -g azure-functions-core-tools@4 --unsafe-perm true

# Start the function app
func start --port 7071
```

The Functions will be available at `http://localhost:7071`.

### 4. M365 Agent Local Development

#### Setup and Run

```bash
cd src/agents

# Install dependencies
npm install

# Start in development mode with hot reload
npm run dev

# Or build and start
npm run build
npm start
```

#### Testing the Agent

The M365 Agent runs in development mode and can be tested using:
- **Teams App Studio** for Teams integration testing
- **Postman** or **REST Client** for API endpoint testing
- **Browser** for web-based interactions

### 5. Mocking Cloud Dependencies

For local development without Azure services, use these mocking strategies:

#### Microsoft Graph API Mocking

Create a mock Graph service for testing:

```csharp
// In your local development setup
public class MockGraphService : IGraphService
{
    public async Task<string> GetTranscriptAsync(string callId)
    {
        // Return mock transcript data
        return "Mock transcript content for testing...";
    }
    
    // Implement other required methods with mock data
}
```

Register the mock service in your local configuration:

```csharp
// In Startup.cs or Program.cs (for local dev only)
#if DEBUG
services.AddScoped<IGraphService, MockGraphService>();
#else
services.AddScoped<IGraphService, GraphService>();
#endif
```

#### Azure OpenAI Mocking

For local testing without Azure OpenAI costs:

```bash
# Set mock endpoint in local.settings.json
"OpenAI:Endpoint": "http://localhost:8080/mock-openai"
"OpenAI:ApiKey": "mock-key-for-local-dev"
```

Or use a mock service that returns predefined responses.

## Configuration Reference

### local.settings.json Structure

Here's what each setting in your `local.settings.json` should contain:

```json
{
  "IsEncrypted": false,
  "Values": {
    // Azure Functions Runtime
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet",
    
    // Database Connection
    "ConnectionStrings:DefaultConnection": "Server=localhost,1433;Database=MarketingInsights;User Id=sa;Password=DevPassword123!;TrustServerCertificate=true;",
    
    // Azure OpenAI (use mock for local dev)
    "OpenAI:Endpoint": "http://localhost:8080/mock-openai",
    "OpenAI:ApiKey": "mock-api-key",
    "OpenAI:DeploymentName": "gpt-4",
    
    // Microsoft Graph (use mock for local dev)
    "Graph:TenantId": "mock-tenant-id",
    "Graph:ClientId": "mock-client-id",
    "Graph:ClientSecret": "mock-client-secret",
    
    // Application Insights (optional for local dev)
    "APPINSIGHTS_INSTRUMENTATIONKEY": "",
    
    // Key Vault (not used in local dev)
    "KeyVaultUri": ""
  }
}
```

## Troubleshooting

### Common Issues

#### "Cannot connect to SQL Server"
- Ensure Docker container is running: `docker ps`
- Check port availability: `netstat -an | grep 1433`
- Verify password complexity requirements

#### "Azurite connection failed"
- Restart Azurite container: `docker restart marketinginsights-storage`
- Check ports 10000-10002 are available
- Clear Azurite data if corrupted: `docker volume prune`

#### "Function app won't start"
- Verify .NET 8.0 SDK: `dotnet --version`
- Check `local.settings.json` syntax
- Ensure all required NuGet packages are restored: `dotnet restore`

#### "M365 Agent build fails"
- Check Node.js version: `node --version` (should be 18+)
- Clear npm cache: `npm cache clean --force`
- Delete `node_modules` and reinstall: `rm -rf node_modules && npm install`

### Debug Configuration

For debugging in Visual Studio Code, create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Attach to .NET Functions",
      "type": "coreclr",
      "request": "attach",
      "processId": "${command:pickProcess}"
    }
  ]
}
```

## Development Workflow

### Making Changes

1. **Backend Changes** (Azure Functions):
   - Edit files in `src/functions/`
   - The function app will auto-reload on file changes
   - Test endpoints using Postman or curl

2. **Frontend Changes** (M365 Agent):
   - Edit files in `src/agents/src/`
   - Use `npm run dev` for hot reload
   - Test in Teams App Studio or browser

3. **Database Changes**:
   - Update schema files in `scripts/maintenance/`
   - Apply manually during development
   - Test with SQL Server Management Studio or Azure Data Studio

### Testing

```bash
# Run unit tests
dotnet test tests/unit/

# Run with coverage
dotnet test tests/unit/ --collect:"XPlat Code Coverage"

# Run M365 Agent tests (if available)
cd src/agents && npm test
```

## Production vs Local Development

| Aspect | Production | Local Development |
|--------|------------|-------------------|
| **Database** | Azure SQL Database | SQL Server in Docker |
| **Storage** | Azure Storage Account | Azurite emulator |
| **Authentication** | Azure AD + Key Vault | Mock services |
| **OpenAI** | Azure OpenAI Service | Mock API or personal key |
| **Graph API** | Production Graph endpoint | Mock service |
| **Secrets** | Azure Key Vault | local.settings.json |
| **Monitoring** | Application Insights | Console logs |

## Next Steps

After setting up local development:

1. **Explore the Code**: Review `src/functions/Functions/` and `src/agents/src/`
2. **Run Tests**: Execute `dotnet test` to verify everything works
3. **Make Changes**: Start with small modifications to understand the architecture
4. **Deploy to Dev**: Follow the [Deployment Guide](../deployment/DEPLOYMENT_GUIDE.md) for cloud deployment
5. **Read Architecture**: Review [Architecture.md](../../Architecture.md) for system design details

## Project Structure Reference

```
testNewInsights/
├── src/
│   ├── functions/                    # Azure Functions (.NET 8.0)
│   │   ├── Functions/               # Function endpoints
│   │   ├── Services/                # Business logic services
│   │   ├── local.settings.example.json  # ← Copy this to local.settings.json
│   │   └── host.json                # Function runtime configuration
│   ├── agents/                      # M365 Agent (TypeScript)
│   │   ├── src/                     # Agent source code
│   │   ├── manifest/                # Teams app manifest
│   │   └── package.json             # Node.js dependencies
│   └── shared/                      # Shared libraries (.NET)
├── infrastructure/
│   ├── bicep/                       # Azure Bicep templates
│   └── environments/                # Environment parameter files
├── scripts/
│   ├── deployment/                  # Infrastructure deployment scripts
│   └── maintenance/                 # Database and operational scripts
├── docs/
│   ├── development/                 # ← This guide is here
│   └── deployment/                  # Production deployment guide
├── config/                          # Environment-specific configurations
│   ├── dev/appsettings.dev.json    # Development configuration
│   └── prod/appsettings.prod.json  # Production configuration
└── tests/
    └── unit/                        # Unit tests (.NET)
```

## Key Vault Best Practices

When moving from local development to Azure deployment, understanding Key Vault usage is crucial for security.

### Key Vault vs App Settings

| Setting Type | Local Development | Production/Test |
|--------------|-------------------|-----------------|
| **Secrets** (API keys, passwords, connection strings) | `local.settings.json` | Azure Key Vault |
| **Configuration** (feature flags, URLs, numbers) | `local.settings.json` | Function App Settings |
| **Environment Variables** | `local.settings.json` | Function App Settings |

### Recommended Secret Naming Conventions

Use these naming conventions in Azure Key Vault:

```
# Database
SqlConnectionString
SqlServerAdminPassword

# Azure OpenAI
OpenAIKey
OpenAIEndpoint

# Microsoft Graph
GraphClientSecret
GraphClientId (can be app setting)

# Storage
StorageAccountKey
StorageConnectionString

# Application Insights
AppInsightsInstrumentationKey
AppInsightsConnectionString
```

### Key Vault Reference Syntax

In Function App settings, reference Key Vault secrets using this syntax:

```
@Microsoft.KeyVault(VaultName=mi-prod-kv-suffix;SecretName=OpenAIKey)
@Microsoft.KeyVault(VaultName=mi-prod-kv-suffix;SecretName=SqlConnectionString)
```

### Setting Up Key Vault Access

1. **Enable Managed Identity** for your Function App:
   ```bash
   az functionapp identity assign --name mi-prod-func-suffix --resource-group mi-prod-rg
   ```

2. **Grant Key Vault Access**:
   ```bash
   # Get the Function App's principal ID
   PRINCIPAL_ID=$(az functionapp identity show --name mi-prod-func-suffix --resource-group mi-prod-rg --query principalId --output tsv)
   
   # Assign Key Vault Secrets User role
   az role assignment create \
     --assignee $PRINCIPAL_ID \
     --role "Key Vault Secrets User" \
     --scope /subscriptions/{subscription-id}/resourceGroups/mi-prod-rg/providers/Microsoft.KeyVault/vaults/mi-prod-kv-suffix
   ```

3. **Add Secrets to Key Vault**:
   ```bash
   # Add OpenAI API key
   az keyvault secret set --vault-name mi-prod-kv-suffix --name "OpenAIKey" --value "your-openai-key"
   
   # Add SQL connection string
   az keyvault secret set --vault-name mi-prod-kv-suffix --name "SqlConnectionString" --value "Server=tcp:..."
   ```

### Security Checklist

- [ ] **Never commit secrets** to source control
- [ ] **Use managed identities** instead of service principals when possible
- [ ] **Rotate secrets regularly** (quarterly for production)
- [ ] **Use different Key Vaults** for different environments (dev/test/prod)
- [ ] **Enable Key Vault logging** for audit trails
- [ ] **Set appropriate access policies** following principle of least privilege
- [ ] **Use Key Vault references** in Function App settings instead of plain text

## Additional Resources

- **[Deployment Guide](../deployment/DEPLOYMENT_GUIDE.md)**: Full Azure deployment instructions
- **[Architecture Documentation](../../Architecture.md)**: System design and component overview
- **[Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local)**: Official documentation
- **[M365 Development](https://docs.microsoft.com/en-us/microsoftteams/platform/)**: Teams app development guide
- **[Key Vault Developer Guide](https://docs.microsoft.com/en-us/azure/key-vault/general/developers-guide)**: Azure Key Vault best practices