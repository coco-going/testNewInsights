using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;
using MarketingInsights.Shared.Services;
using MarketingInsights.Shared.Models;

namespace MarketingInsights.Functions.Functions
{
    public class TranscriptProcessingOrchestrator
    {
        private readonly IGraphService _graphService;
        private readonly IAiProcessingService _aiProcessingService;
        private readonly IDataAccessService _dataAccessService;
        private readonly ISearchService _searchService;
        private readonly IFabricService _fabricService;

        public TranscriptProcessingOrchestrator(
            IGraphService graphService,
            IAiProcessingService aiProcessingService,
            IDataAccessService dataAccessService,
            ISearchService searchService,
            IFabricService fabricService)
        {
            _graphService = graphService;
            _aiProcessingService = aiProcessingService;
            _dataAccessService = dataAccessService;
            _searchService = searchService;
            _fabricService = fabricService;
        }

        [FunctionName("TranscriptProcessingOrchestrator")]
        public async Task Run([TimerTrigger("0 0 */6 * * *")] TimerInfo myTimer, ILogger log)
        {
            log.LogInformation($"Transcript processing orchestrator executed at: {DateTime.Now}");

            try
            {
                // Step 1: Retrieve new transcripts from Microsoft Graph
                var newTranscripts = await _graphService.RetrieveTranscriptsAsync();
                log.LogInformation($"Retrieved {newTranscripts.Count()} new transcripts");

                foreach (var transcript in newTranscripts)
                {
                    await ProcessTranscriptAsync(transcript, log);
                }
            }
            catch (Exception ex)
            {
                log.LogError(ex, "Error in transcript processing orchestrator");
                throw;
            }
        }

        [FunctionName("ProcessSingleTranscript")]
        public async Task ProcessSingleTranscriptFunction(
            [QueueTrigger("transcript-processing")] string transcriptId,
            ILogger log)
        {
            log.LogInformation($"Processing single transcript: {transcriptId}");

            try
            {
                var transcript = await _dataAccessService.GetTranscriptByIdAsync(transcriptId);
                if (transcript == null)
                {
                    log.LogWarning($"Transcript not found: {transcriptId}");
                    return;
                }

                await ProcessTranscriptAsync(transcript, log);
            }
            catch (Exception ex)
            {
                log.LogError(ex, $"Error processing transcript {transcriptId}");
                throw;
            }
        }

        private async Task ProcessTranscriptAsync(Transcript transcript, ILogger log)
        {
            try
            {
                // Update status to processing
                transcript.Status = ProcessingStatus.Processing;
                await _dataAccessService.UpdateTranscriptAsync(transcript);

                // Step 2: Process with AI
                log.LogInformation($"Processing transcript {transcript.Id} with AI");
                var aiInsights = await _aiProcessingService.ProcessTranscriptAsync(transcript.Content);
                
                // Update transcript with AI insights
                transcript.AiInsights = aiInsights;
                transcript.ProcessedDate = DateTime.UtcNow;
                transcript.Status = ProcessingStatus.Completed;

                // Step 3: Save to database
                await _dataAccessService.UpdateTranscriptAsync(transcript);
                log.LogInformation($"Updated transcript {transcript.Id} with AI insights");

                // Step 4: Index in search service (if enabled)
                if (await IsSearchEnabledAsync())
                {
                    await _searchService.IndexTranscriptAsync(transcript);
                    log.LogInformation($"Indexed transcript {transcript.Id} in search service");
                }

                // Step 5: Send to Fabric (if enabled)
                if (await IsFabricEnabledAsync())
                {
                    await _fabricService.SendToFabricAsync(transcript);
                    log.LogInformation($"Sent transcript {transcript.Id} to Microsoft Fabric");
                }
            }
            catch (Exception ex)
            {
                log.LogError(ex, $"Error processing transcript {transcript.Id}");
                
                // Update status to failed
                transcript.Status = ProcessingStatus.Failed;
                await _dataAccessService.UpdateTranscriptAsync(transcript);
                
                throw;
            }
        }

        private async Task<bool> IsSearchEnabledAsync()
        {
            // Check if Azure Search is configured and enabled
            return await Task.FromResult(false); // Placeholder
        }

        private async Task<bool> IsFabricEnabledAsync()
        {
            // Check if Microsoft Fabric integration is enabled
            return await Task.FromResult(false); // Placeholder
        }
    }
}