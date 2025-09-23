using MarketingInsights.Shared.Services;
using MarketingInsights.Shared.Models;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Linq;
using Microsoft.Extensions.Logging;

namespace MarketingInsights.Functions.Services
{
    public class TranscriptService : ITranscriptService
    {
        private readonly IDataAccessService _dataAccessService;
        private readonly ISearchService _searchService;
        private readonly ILogger<TranscriptService> _logger;

        public TranscriptService(
            IDataAccessService dataAccessService,
            ISearchService searchService,
            ILogger<TranscriptService> logger)
        {
            _dataAccessService = dataAccessService;
            _searchService = searchService;
            _logger = logger;
        }

        public async Task<IEnumerable<Transcript>> GetTranscriptsAsync()
        {
            _logger.LogInformation("Getting all transcripts");
            return await _dataAccessService.GetAllTranscriptsAsync();
        }

        public async Task<Transcript?> GetTranscriptByIdAsync(string id)
        {
            _logger.LogInformation("Getting transcript by ID: {TranscriptId}", id);
            return await _dataAccessService.GetTranscriptByIdAsync(id);
        }

        public async Task<Transcript> SaveTranscriptAsync(Transcript transcript)
        {
            _logger.LogInformation("Saving transcript: {TranscriptId}", transcript.Id);
            
            var existingTranscript = await _dataAccessService.GetTranscriptByIdAsync(transcript.Id);
            
            Transcript savedTranscript;
            if (existingTranscript == null)
            {
                savedTranscript = await _dataAccessService.InsertTranscriptAsync(transcript);
                _logger.LogInformation("Inserted new transcript: {TranscriptId}", transcript.Id);
            }
            else
            {
                savedTranscript = await _dataAccessService.UpdateTranscriptAsync(transcript);
                _logger.LogInformation("Updated existing transcript: {TranscriptId}", transcript.Id);
            }

            // Index in search service if available
            try
            {
                await _searchService.IndexTranscriptAsync(savedTranscript);
                _logger.LogInformation("Indexed transcript in search service: {TranscriptId}", transcript.Id);
            }
            catch (System.Exception ex)
            {
                _logger.LogWarning(ex, "Failed to index transcript in search service: {TranscriptId}", transcript.Id);
                // Don't fail the save operation if search indexing fails
            }

            return savedTranscript;
        }

        public async Task<bool> DeleteTranscriptAsync(string id)
        {
            _logger.LogInformation("Deleting transcript: {TranscriptId}", id);
            
            var deleted = await _dataAccessService.DeleteTranscriptAsync(id);
            
            if (deleted)
            {
                try
                {
                    await _searchService.DeleteIndexAsync(id);
                    _logger.LogInformation("Deleted transcript from search index: {TranscriptId}", id);
                }
                catch (System.Exception ex)
                {
                    _logger.LogWarning(ex, "Failed to delete transcript from search index: {TranscriptId}", id);
                }
            }

            return deleted;
        }

        public async Task<IEnumerable<Transcript>> SearchTranscriptsAsync(string query, int maxResults = 10)
        {
            _logger.LogInformation("Searching transcripts with query: {Query}", query);
            
            try
            {
                // Try search service first
                var searchResults = await _searchService.SearchAsync(query, maxResults);
                if (searchResults.Any())
                {
                    return searchResults;
                }
            }
            catch (System.Exception ex)
            {
                _logger.LogWarning(ex, "Search service unavailable, falling back to database search");
            }

            // Fallback to database search
            return await _dataAccessService.SearchTranscriptsAsync(query);
        }
    }
}