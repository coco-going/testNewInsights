using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using MarketingInsights.Shared.Services;
using MarketingInsights.Shared.Models;

namespace MarketingInsights.Functions.Functions
{
    public class TranscriptApiFunction
    {
        private readonly ITranscriptService _transcriptService;

        public TranscriptApiFunction(ITranscriptService transcriptService)
        {
            _transcriptService = transcriptService;
        }

        [FunctionName("GetTranscripts")]
        public async Task<IActionResult> GetTranscripts(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = "transcripts")] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("Getting all transcripts");

            try
            {
                var transcripts = await _transcriptService.GetTranscriptsAsync();
                return new OkObjectResult(transcripts);
            }
            catch (Exception ex)
            {
                log.LogError(ex, "Error getting transcripts");
                return new StatusCodeResult(500);
            }
        }

        [FunctionName("GetTranscript")]
        public async Task<IActionResult> GetTranscript(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = "transcripts/{id}")] HttpRequest req,
            string id,
            ILogger log)
        {
            log.LogInformation($"Getting transcript: {id}");

            try
            {
                var transcript = await _transcriptService.GetTranscriptByIdAsync(id);
                if (transcript == null)
                {
                    return new NotFoundResult();
                }

                return new OkObjectResult(transcript);
            }
            catch (Exception ex)
            {
                log.LogError(ex, $"Error getting transcript {id}");
                return new StatusCodeResult(500);
            }
        }

        [FunctionName("SearchTranscripts")]
        public async Task<IActionResult> SearchTranscripts(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = "transcripts/search")] HttpRequest req,
            ILogger log)
        {
            string query = req.Query["q"];
            if (string.IsNullOrEmpty(query))
            {
                return new BadRequestObjectResult("Query parameter 'q' is required");
            }

            log.LogInformation($"Searching transcripts: {query}");

            try
            {
                var transcripts = await _transcriptService.SearchTranscriptsAsync(query);
                return new OkObjectResult(transcripts);
            }
            catch (Exception ex)
            {
                log.LogError(ex, $"Error searching transcripts with query: {query}");
                return new StatusCodeResult(500);
            }
        }

        [FunctionName("CreateTranscript")]
        public async Task<IActionResult> CreateTranscript(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = "transcripts")] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("Creating new transcript");

            try
            {
                string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
                var transcript = JsonConvert.DeserializeObject<Transcript>(requestBody);

                if (transcript == null)
                {
                    return new BadRequestObjectResult("Invalid transcript data");
                }

                transcript.Id = Guid.NewGuid().ToString();
                transcript.CreatedDate = DateTime.UtcNow;
                transcript.Status = ProcessingStatus.Pending;

                var savedTranscript = await _transcriptService.SaveTranscriptAsync(transcript);
                return new CreatedResult($"/api/transcripts/{savedTranscript.Id}", savedTranscript);
            }
            catch (Exception ex)
            {
                log.LogError(ex, "Error creating transcript");
                return new StatusCodeResult(500);
            }
        }

        [FunctionName("DeleteTranscript")]
        public async Task<IActionResult> DeleteTranscript(
            [HttpTrigger(AuthorizationLevel.Function, "delete", Route = "transcripts/{id}")] HttpRequest req,
            string id,
            ILogger log)
        {
            log.LogInformation($"Deleting transcript: {id}");

            try
            {
                var result = await _transcriptService.DeleteTranscriptAsync(id);
                if (!result)
                {
                    return new NotFoundResult();
                }

                return new NoContentResult();
            }
            catch (Exception ex)
            {
                log.LogError(ex, $"Error deleting transcript {id}");
                return new StatusCodeResult(500);
            }
        }
    }
}