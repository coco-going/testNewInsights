# Marketing Insights Solution

This repository contains a complete **code-first** implementation of the Marketing Insights solution - an AI-powered system that extracts insights from Microsoft Teams research interview transcripts using Azure OpenAI and provides a conversational interface through M365 Agents SDK.

## 🚀 Quick Start

### Prerequisites
- Azure Subscription with appropriate permissions
- Microsoft 365 tenant with Teams licenses
- GitHub account for CI/CD
- Azure CLI and .NET 6.0 SDK installed

### Deploy to Azure
1. **Clone the repository**:
   ```bash
   git clone https://github.com/coco-going/testNewInsights.git
   cd testNewInsights
   ```

2. **Configure GitHub Secrets** (see [Deployment Guide](./docs/deployment/DEPLOYMENT_GUIDE.md))

3. **Deploy using GitHub Actions**:
   - Push to `main` branch for production deployment
   - Use workflow dispatch for specific environments

4. **Manual deployment** (optional):
   ```bash
   ./scripts/deployment/deploy-infrastructure.sh prod {subscription-id}
   ```

## 🏗️ Solution Architecture

### Core Components
- **📥 Transcript Retrieval**: Microsoft Graph API integration for Teams call records
- **🧠 AI Processing**: Azure OpenAI GPT-4 for sentiment analysis and theme extraction
- **💾 Data Storage**: Azure SQL Database with JSON support and full-text search
- **💬 Conversational Interface**: M365 Agents SDK Declarative Agent for Teams integration

### Technology Stack
- **Infrastructure**: Azure Bicep templates
- **Backend**: Azure Functions (.NET 6.0)
- **AI Services**: Azure OpenAI Service
- **Database**: Azure SQL Database
- **Agent**: M365 Agents SDK (TypeScript)
- **CI/CD**: GitHub Actions
- **Security**: Azure Key Vault for secrets management

## 📁 Repository Structure

```
├── 📁 src/                          # Source code
│   ├── 📁 functions/                # Azure Functions (C#)
│   ├── 📁 agents/                   # M365 Agent (TypeScript)
│   ├── 📁 services/                 # Service implementations
│   └── 📁 shared/                   # Shared libraries and models
├── 📁 infrastructure/               # Infrastructure as Code
│   ├── 📁 bicep/                    # Azure Bicep templates
│   └── 📁 environments/             # Environment parameter files
├── 📁 scripts/                      # Deployment and maintenance scripts
│   ├── 📁 deployment/               # Infrastructure deployment scripts
│   └── 📁 maintenance/              # Database and operational scripts
├── 📁 config/                       # Environment-specific configurations
│   ├── 📁 dev/                      # Development environment
│   ├── 📁 test/                     # Test environment
│   └── 📁 prod/                     # Production environment
├── 📁 tests/                        # Test suites
│   ├── 📁 unit/                     # Unit tests
│   └── 📁 integration/              # Integration tests
├── 📁 docs/                         # Documentation
│   ├── 📁 deployment/               # Deployment guides
│   └── 📁 architecture/             # Architecture documentation
└── 📁 .github/workflows/            # GitHub Actions CI/CD pipelines
```

## 🌟 Key Features

### ✅ Code-First Development
- **Infrastructure as Code**: Complete Azure deployment using Bicep templates
- **Automated CI/CD**: GitHub Actions for build, test, and deployment
- **Environment Management**: Separate dev, test, and production configurations
- **Database Migrations**: Automated schema deployment and versioning

### ✅ Enterprise-Grade Security
- **Azure Key Vault**: Secure secrets management
- **Azure AD Integration**: Authentication and authorization
- **RBAC**: Role-based access control
- **Encryption**: Data encryption at rest and in transit

### ✅ Scalable Architecture
- **Multi-Environment Support**: Dev, test, and production environments
- **Auto-Scaling**: Azure Functions consumption plan
- **Performance Monitoring**: Application Insights integration
- **Cost Optimization**: Resource rightsizing and monitoring

### ✅ Future-Ready Extensibility
- **Azure Search**: Ready for enhanced search capabilities
- **Microsoft Fabric**: Prepared for advanced analytics integration
- **Modular Design**: Easy to extend with additional AI services
- **API-First**: RESTful APIs for integration flexibility

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **[Architecture.md](./Architecture.md)** | Comprehensive architecture analysis with component alternatives |
| **[Final Architecture.md](./Final%20Architecture.md)** | Final recommended architecture and implementation plan |
| **[Deployment Guide](./docs/deployment/DEPLOYMENT_GUIDE.md)** | Complete deployment instructions and configuration |
| **[API Documentation](./docs/api/)** | REST API reference and examples |

## 🚦 Getting Started

### 1. Review Architecture
Start with the [Final Architecture document](./Final%20Architecture.md) to understand the solution design and implementation phases.

### 2. Deploy Infrastructure
Follow the [Deployment Guide](./docs/deployment/DEPLOYMENT_GUIDE.md) for step-by-step deployment instructions.

### 3. Configure Services
Set up Azure AD app registrations, Microsoft Graph permissions, and environment-specific configurations.

### 4. Deploy Applications
Use GitHub Actions or manual scripts to deploy the Function Apps and M365 Agent.

### 5. Test and Validate
Run the included test suites and verify the conversational interface in Microsoft Teams.

## 🔧 Development

### Prerequisites for Development
```bash
# Install .NET SDK
dotnet --version  # Should be 6.0+

# Install Node.js
node --version    # Should be 18+

# Install Azure CLI
az --version
```

### Local Development Setup
```bash
# Restore .NET dependencies
cd src/functions
dotnet restore

# Install Node.js dependencies for M365 Agent
cd ../agents
npm install

# Run tests
cd ../../tests/unit
dotnet test
```

### Build and Test
```bash
# Build all projects
dotnet build src/functions/MarketingInsights.Functions.csproj
dotnet build src/shared/MarketingInsights.Shared.csproj

# Run unit tests with coverage
dotnet test tests/unit/MarketingInsights.Tests.csproj --collect:"XPlat Code Coverage"

# Build M365 Agent
cd src/agents
npm run build
```

## 💰 Cost Optimization

**Monthly Operating Costs** (400 transcripts/month):
- Azure Functions: ~$30
- Azure OpenAI Service: ~$300
- Azure SQL Database: ~$150
- Azure Storage: ~$15
- Application Insights: ~$35
- **Total: ~$530/month**

**Per-User Licensing**:
- Microsoft 365 E3: $22/user/month
- Microsoft 365 Copilot (optional): $30/user/month

## 🔒 Security & Compliance

- **Data Privacy**: Automatic data anonymization options
- **Audit Trail**: Comprehensive logging and monitoring
- **Compliance**: Built-in support for common compliance frameworks
- **Access Control**: Azure AD-based authentication and RBAC
- **Encryption**: End-to-end encryption for data protection

## 🌍 Multi-Environment Support

| Environment | Purpose | Configuration | Resources |
|-------------|---------|---------------|-----------|
| **Dev** | Development and testing | Minimal resources | Basic tier services |
| **Test** | Staging and validation | Production-like | Standard tier services |
| **Prod** | Production workloads | High availability | Premium tier services |

## 🔄 CI/CD Pipeline

The GitHub Actions workflow provides:
- ✅ **Automated Testing**: Unit and integration tests
- ✅ **Security Scanning**: Vulnerability and code analysis  
- ✅ **Infrastructure Deployment**: Bicep template deployment
- ✅ **Application Deployment**: Function Apps and M365 Agent
- ✅ **Database Migrations**: Automated schema updates
- ✅ **Environment Promotion**: Dev → Test → Production

## 🚀 Future Enhancements

### Ready for Integration
- **Azure Cognitive Search**: Enhanced search capabilities
- **Microsoft Fabric**: Advanced analytics and data lakes
- **Power BI**: Custom dashboards and reporting
- **Power Platform**: Low-code workflow automation

### Extensible Architecture
- **Additional AI Models**: Easy integration of new AI services
- **Custom Connectors**: Connect to external data sources
- **Webhook Support**: Real-time event processing
- **Multi-Tenant**: Support for multiple organizations

## 📞 Support & Contributing

### Getting Help
- **Issues**: Use GitHub Issues for bugs and feature requests
- **Discussions**: Use GitHub Discussions for questions and ideas
- **Documentation**: Check the docs folder for detailed guides

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏆 Acknowledgments

Built following Microsoft's recommended practices for:
- Azure Well-Architected Framework
- M365 Development Best Practices
- Enterprise Application Patterns
- DevOps and CI/CD Excellence

---

**Ready to get started?** Follow the [Deployment Guide](./docs/deployment/DEPLOYMENT_GUIDE.md) to deploy your Marketing Insights solution today!
