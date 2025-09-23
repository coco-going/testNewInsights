using System.Collections.Generic;
using System.Threading.Tasks;
using MarketingInsights.Shared.Models;

namespace MarketingInsights.Shared.Services
{
    public interface ITranscriptService
    {
        Task<IEnumerable<Transcript>> GetTranscriptsAsync();
        Task<Transcript?> GetTranscriptByIdAsync(string id);
        Task<Transcript> SaveTranscriptAsync(Transcript transcript);
        Task<bool> DeleteTranscriptAsync(string id);
        Task<IEnumerable<Transcript>> SearchTranscriptsAsync(string query, int maxResults = 10);
    }
    
    public interface IGraphService
    {
        Task<IEnumerable<Transcript>> RetrieveTranscriptsAsync();
        Task<Transcript> GetTranscriptDetailsAsync(string meetingId);
        Task<bool> ValidatePermissionsAsync();
    }
    
    public interface IAiProcessingService
    {
        Task<AiInsights> ProcessTranscriptAsync(string content);
        Task<SentimentAnalysis> AnalyzeSentimentAsync(string content);
        Task<IEnumerable<Theme>> ExtractThemesAsync(string content);
        Task<string> GenerateSummaryAsync(string content);
        Task<IEnumerable<ActionItem>> ExtractActionItemsAsync(string content);
    }
    
    public interface IDataAccessService
    {
        Task<IEnumerable<Transcript>> GetAllTranscriptsAsync();
        Task<Transcript?> GetTranscriptByIdAsync(string id);
        Task<Transcript> InsertTranscriptAsync(Transcript transcript);
        Task<Transcript> UpdateTranscriptAsync(Transcript transcript);
        Task<bool> DeleteTranscriptAsync(string id);
        Task<IEnumerable<Transcript>> SearchTranscriptsAsync(string searchTerm);
        Task<bool> ExecuteMigrationAsync();
    }
    
    public interface ISearchService
    {
        Task<bool> IndexTranscriptAsync(Transcript transcript);
        Task<IEnumerable<Transcript>> SearchAsync(string query, int maxResults = 10);
        Task<bool> DeleteIndexAsync(string transcriptId);
        Task<bool> CreateIndexAsync();
    }
    
    public interface IFabricService
    {
        Task<bool> SendToFabricAsync(Transcript transcript);
        Task<IEnumerable<dynamic>> GetFabricInsightsAsync();
        Task<bool> ConfigureFabricConnectionAsync();
    }
    
    public interface IConfigurationService
    {
        Task<T> GetSettingAsync<T>(string key);
        Task<bool> SetSettingAsync<T>(string key, T value);
        Task<string> GetSecretAsync(string secretName);
    }
}