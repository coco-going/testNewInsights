# Copilot Instructions - Marketing Insights Solution

## Overview
This solution is a code-first AI-powered marketing insights platform built using the Microsoft ecosystem. It extracts insights from Microsoft Teams research interview transcripts using Azure OpenAI and provides conversational interfaces through M365 Agents SDK.

## Architecture & Technology Stack
- **Backend**: Azure Functions (.NET 8.0) for orchestration and API endpoints
- **AI Processing**: Azure OpenAI Service with GPT-4 for sentiment analysis and insight extraction
- **Data Storage**: Azure SQL Database with JSON support and full-text search
- **Conversational Interface**: M365 Agents SDK Declarative Agent (TypeScript)
- **Transcript Retrieval**: Microsoft Graph API for Teams Call Records
- **Infrastructure**: Azure Bicep templates for Infrastructure as Code
- **CI/CD**: GitHub Actions with multi-environment deployment (dev/test/prod)
- **Security**: Azure Key Vault for secrets management, Azure AD for authentication

## Development Best Practices

### Code Organization
Follow the established repository structure:
```
src/
├── functions/          # Azure Functions (.NET 8.0)
├── agents/            # M365 Agents SDK (TypeScript)
├── shared/            # Shared libraries and models
└── services/          # Service implementations

infrastructure/
├── bicep/             # Azure Bicep templates
└── environments/      # Environment parameter files

tests/
├── unit/              # Unit tests (.NET)
└── integration/       # Integration tests
```

### Microsoft Graph API Development
- Use Microsoft Graph .NET SDK v5+ for all Graph API interactions
- Implement proper authentication with Azure AD app registrations
- Follow Graph API throttling guidelines and implement exponential backoff
- Reference: [Microsoft Graph .NET SDK Documentation](https://docs.microsoft.com/en-us/graph/sdks/sdks-overview)
- Required permissions: `CallRecords.Read.All` for Teams transcript access

### Azure OpenAI Integration
- Use Azure OpenAI .NET SDK for consistent integration patterns
- Implement token management and cost optimization strategies
- Use GPT-4 for complex reasoning tasks, GPT-3.5-turbo for simpler operations
- Cache responses when appropriate to minimize costs
- Reference: [Azure OpenAI Service Documentation](https://docs.microsoft.com/en-us/azure/cognitive-services/openai/)

### M365 Agents SDK Development
- Follow declarative agent patterns using M365 Agents SDK
- Implement proper Teams app manifest configuration
- Use TypeScript for type safety and better developer experience
- Follow Microsoft's agent design guidelines for conversational flows
- Reference: [M365 Agents SDK Documentation](https://docs.microsoft.com/en-us/microsoftteams/platform/bots/what-are-bots)

### Azure Functions Best Practices
- Use dependency injection for service registration
- Implement proper error handling and logging with ILogger
- Follow async/await patterns consistently
- Use Azure Functions v4 isolated worker model
- Implement health checks and monitoring endpoints
- Reference: [Azure Functions .NET Developer Guide](https://docs.microsoft.com/en-us/azure/azure-functions/dotnet-isolated-process-guide)

### Data Access & Azure SQL
- Use Entity Framework Core for data access with code-first migrations
- Leverage JSON support for flexible schema design
- Implement full-text search using SQL Server capabilities
- Use connection pooling and implement retry policies
- Reference: [Entity Framework Core Documentation](https://docs.microsoft.com/en-us/ef/core/)

## Infrastructure as Code

### Bicep Templates
- Use Azure Bicep for all infrastructure definitions
- Implement parameterized templates for multi-environment deployment
- Follow Azure Resource Manager best practices
- Use proper resource naming conventions: `{service}-{environment}-{suffix}`
- Reference: [Azure Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/)

### Key Vault Integration
- Store all secrets in Azure Key Vault
- Use managed identities for service authentication
- Implement proper RBAC for Key Vault access
- Reference: [Azure Key Vault Developer Guide](https://docs.microsoft.com/en-us/azure/key-vault/general/developers-guide)

## Security & Compliance

### Authentication & Authorization
- Use Azure AD for all authentication flows
- Implement proper RBAC for resource access
- Follow principle of least privilege
- Enable audit logging for compliance
- Reference: [Azure AD Authentication Documentation](https://docs.microsoft.com/en-us/azure/active-directory/develop/)

### Data Protection
- Implement encryption at rest and in transit
- Use Azure Key Vault for certificate management
- Follow data retention and deletion policies
- Implement proper data anonymization where required
- Reference: [Azure Security Documentation](https://docs.microsoft.com/en-us/azure/security/)

### Compliance
- Follow Microsoft 365 compliance guidelines
- Implement audit trails for all data processing
- Use Azure Policy for governance enforcement
- Reference: [Microsoft 365 Compliance Documentation](https://docs.microsoft.com/en-us/microsoft-365/compliance/)

## CI/CD & DevOps

### GitHub Actions Workflows
- Use the existing `.github/workflows/ci-cd.yml` as the primary workflow
- Implement environment-specific deployments (dev → test → prod)
- Use GitHub secrets for sensitive configuration
- Implement automated testing in CI pipeline
- Reference: [GitHub Actions Documentation](https://docs.github.com/en/actions)

### Testing Strategy
- Write unit tests for all service classes and functions
- Implement integration tests for API endpoints
- Use xUnit for .NET testing, Jest for TypeScript testing
- Maintain minimum 80% code coverage
- Reference: [Testing in .NET Documentation](https://docs.microsoft.com/en-us/dotnet/core/testing/)

### Monitoring & Observability
- Use Application Insights for telemetry and monitoring
- Implement structured logging with ILogger
- Create custom dashboards for business metrics
- Set up alerting for critical failures
- Reference: [Application Insights Documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)

## Environment Management

### Multi-Environment Strategy
- **Dev**: Development and initial testing with minimal resources
- **Test**: Production-like environment for validation
- **Prod**: Production workloads with high availability

### Configuration Management
- Use environment-specific parameter files in `infrastructure/environments/`
- Store environment secrets in respective Key Vaults
- Use managed identities to avoid credential management
- Reference configuration in `config/{environment}/appsettings.{environment}.json`

## Cost Optimization

### Resource Management
- Use Azure Functions consumption plan for cost efficiency
- Right-size Azure SQL Database based on usage patterns
- Implement auto-scaling where appropriate
- Monitor costs with Azure Cost Management
- Reference: [Azure Cost Management Documentation](https://docs.microsoft.com/en-us/azure/cost-management-billing/)

### AI Service Optimization
- Cache Azure OpenAI responses when possible
- Optimize prompts for token efficiency
- Use appropriate models for different tasks (GPT-4 vs GPT-3.5-turbo)
- Monitor token usage and implement budgets

## Code Quality Standards

### .NET Development
- Follow Microsoft's C# coding conventions
- Use nullable reference types consistently
- Implement proper async/await patterns
- Use dependency injection throughout
- Reference: [C# Coding Conventions](https://docs.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions)

### TypeScript Development
- Use strict TypeScript configuration
- Follow ESLint rules configured in the project
- Implement proper error handling
- Use async/await for asynchronous operations
- Reference: [TypeScript Best Practices](https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html)

## Common Patterns & Examples

### Service Registration Pattern
```csharp
// In Program.cs or Startup.cs
services.AddScoped<IGraphService, GraphService>();
services.AddScoped<IAiProcessingService, AiProcessingService>();
services.AddHttpClient<GraphService>();
```

### Azure Function Implementation
```csharp
[Function("ProcessTranscript")]
public async Task<IActionResult> ProcessTranscript(
    [HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequest req,
    ILogger log)
{
    // Implementation following established patterns
}
```

### Error Handling Pattern
```csharp
try
{
    // Service call
}
catch (ServiceException ex) when (ex.Error.Code == "TooManyRequests")
{
    // Implement exponential backoff
    await Task.Delay(TimeSpan.FromSeconds(Math.Pow(2, retryCount)));
}
```

## Documentation & Standards

### Code Documentation
- Use XML documentation comments for public APIs
- Maintain up-to-date README files in each component
- Document architecture decisions in ADR format
- Keep deployment guides current

### API Documentation
- Use OpenAPI/Swagger for REST API documentation
- Document all endpoints with proper examples
- Include authentication requirements
- Maintain Postman collections for testing

## Troubleshooting & Support

### Common Issues
- **Graph API Rate Limiting**: Implement exponential backoff and caching
- **Function App Cold Starts**: Consider premium plans for production
- **Key Vault Access**: Verify managed identity permissions
- **M365 Agent Deployment**: Validate Teams app manifest

### Debugging Resources
- Use Application Insights for distributed tracing
- Enable detailed logging in development environments
- Use Azure Portal for resource health monitoring
- Reference logs in Azure Functions and Key Vault audit logs

## Future Extensibility

### Microsoft Fabric Integration
- The architecture supports optional Microsoft Fabric integration
- Use the `enableFabricIntegration` parameter in Bicep templates
- Implement fabric services in the `IFabricService` interface

### Advanced AI Features
- Consider Azure AI Foundry for advanced AI workflows
- Implement custom models when appropriate
- Use Azure Machine Learning for model training scenarios
- Reference: [Azure AI Foundry Documentation](https://docs.microsoft.com/en-us/azure/machine-learning/)

## Version Control & Branching

### Git Workflow
- Use feature branches for development
- Require pull request reviews before merging
- Use conventional commit messages
- Tag releases with semantic versioning

### Branch Protection
- Protect main branch with required reviews
- Run all tests before merge
- Require up-to-date branches before merge
- Use GitHub Actions status checks as gates

Remember: This solution prioritizes code-first development, Microsoft ecosystem integration, and enterprise-grade security and compliance. Always reference the latest Microsoft documentation and follow established patterns in the existing codebase.