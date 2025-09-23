using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using MarketingInsights.Shared.Services;
using MarketingInsights.Functions.Services;
using System.IO;

[assembly: FunctionsStartup(typeof(MarketingInsights.Functions.Startup))]

namespace MarketingInsights.Functions
{
    public class Startup : FunctionsStartup
    {
        public override void Configure(IFunctionsHostBuilder builder)
        {
            var context = builder.GetContext();
            
            var config = new ConfigurationBuilder()
                .SetBasePath(context.ApplicationRootPath)
                .AddJsonFile("local.settings.json", optional: true, reloadOnChange: true)
                .AddEnvironmentVariables()
                .Build();

            builder.Services.AddSingleton<IConfiguration>(config);

            // Register services
            builder.Services.AddScoped<ITranscriptService, TranscriptService>();
            builder.Services.AddScoped<IGraphService, GraphService>();
            builder.Services.AddScoped<IAiProcessingService, AiProcessingService>();
            builder.Services.AddScoped<IDataAccessService, DataAccessService>();
            builder.Services.AddScoped<ISearchService, SearchService>();
            builder.Services.AddScoped<IFabricService, FabricService>();
            builder.Services.AddScoped<IConfigurationService, ConfigurationService>();

            // Configure HttpClient
            builder.Services.AddHttpClient();
            
            // Configure logging
            builder.Services.AddLogging();
        }
    }
}