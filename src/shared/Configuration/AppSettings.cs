namespace MarketingInsights.Shared.Configuration
{
    public class AppSettings
    {
        public AzureSettings Azure { get; set; } = new();
        public OpenAiSettings OpenAI { get; set; } = new();
        public DatabaseSettings Database { get; set; } = new();
        public GraphSettings Graph { get; set; } = new();
        public AgentSettings Agent { get; set; } = new();
        public SearchSettings Search { get; set; } = new();
        public FabricSettings Fabric { get; set; } = new();
    }
    
    public class AzureSettings
    {
        public string SubscriptionId { get; set; } = string.Empty;
        public string TenantId { get; set; } = string.Empty;
        public string ClientId { get; set; } = string.Empty;
        public string ClientSecret { get; set; } = string.Empty;
        public string KeyVaultUri { get; set; } = string.Empty;
        public string ResourceGroupName { get; set; } = string.Empty;
    }
    
    public class OpenAiSettings
    {
        public string Endpoint { get; set; } = string.Empty;
        public string ApiKey { get; set; } = string.Empty;
        public string DeploymentName { get; set; } = "gpt-4";
        public int MaxTokens { get; set; } = 4000;
        public double Temperature { get; set; } = 0.3;
        public int MaxRetries { get; set; } = 3;
    }
    
    public class DatabaseSettings
    {
        public string ConnectionString { get; set; } = string.Empty;
        public string DatabaseName { get; set; } = string.Empty;
        public int CommandTimeout { get; set; } = 30;
        public bool EnableRetryOnFailure { get; set; } = true;
    }
    
    public class GraphSettings
    {
        public string TenantId { get; set; } = string.Empty;
        public string ClientId { get; set; } = string.Empty;
        public string ClientSecret { get; set; } = string.Empty;
        public string[] Scopes { get; set; } = new[] { "https://graph.microsoft.com/.default" };
        public string Authority { get; set; } = "https://login.microsoftonline.com/";
    }
    
    public class AgentSettings
    {
        public string ManifestPath { get; set; } = string.Empty;
        public string Name { get; set; } = "MarketingInsightsAgent";
        public string Description { get; set; } = "AI-powered marketing insights agent";
        public string Version { get; set; } = "1.0.0";
        public bool EnableTeamsIntegration { get; set; } = true;
        public bool EnableCopilotIntegration { get; set; } = true;
    }
    
    public class SearchSettings
    {
        public string ServiceName { get; set; } = string.Empty;
        public string ApiKey { get; set; } = string.Empty;
        public string IndexName { get; set; } = "transcripts";
        public bool Enabled { get; set; } = false;
    }
    
    public class FabricSettings
    {
        public string WorkspaceId { get; set; } = string.Empty;
        public string DatasetId { get; set; } = string.Empty;
        public string ClientId { get; set; } = string.Empty;
        public string ClientSecret { get; set; } = string.Empty;
        public bool Enabled { get; set; } = false;
    }
}