using System;
using System.Collections.Generic;
using Newtonsoft.Json;

namespace MarketingInsights.Shared.Models
{
    public class Transcript
    {
        [JsonProperty("id")]
        public string Id { get; set; } = string.Empty;
        
        [JsonProperty("meetingId")]
        public string MeetingId { get; set; } = string.Empty;
        
        [JsonProperty("title")]
        public string Title { get; set; } = string.Empty;
        
        [JsonProperty("content")]
        public string Content { get; set; } = string.Empty;
        
        [JsonProperty("participants")]
        public List<Participant> Participants { get; set; } = new();
        
        [JsonProperty("createdDate")]
        public DateTime CreatedDate { get; set; }
        
        [JsonProperty("duration")]
        public TimeSpan Duration { get; set; }
        
        [JsonProperty("organizer")]
        public string Organizer { get; set; } = string.Empty;
        
        [JsonProperty("processedDate")]
        public DateTime? ProcessedDate { get; set; }
        
        [JsonProperty("status")]
        public ProcessingStatus Status { get; set; } = ProcessingStatus.Pending;
        
        [JsonProperty("aiInsights")]
        public AiInsights? AiInsights { get; set; }
    }
    
    public class Participant
    {
        [JsonProperty("id")]
        public string Id { get; set; } = string.Empty;
        
        [JsonProperty("displayName")]
        public string DisplayName { get; set; } = string.Empty;
        
        [JsonProperty("email")]
        public string Email { get; set; } = string.Empty;
        
        [JsonProperty("role")]
        public string Role { get; set; } = string.Empty;
    }
    
    public class AiInsights
    {
        [JsonProperty("sentiment")]
        public SentimentAnalysis Sentiment { get; set; } = new();
        
        [JsonProperty("themes")]
        public List<Theme> Themes { get; set; } = new();
        
        [JsonProperty("keyPoints")]
        public List<string> KeyPoints { get; set; } = new();
        
        [JsonProperty("actionItems")]
        public List<ActionItem> ActionItems { get; set; } = new();
        
        [JsonProperty("summary")]
        public string Summary { get; set; } = string.Empty;
        
        [JsonProperty("confidence")]
        public double Confidence { get; set; }
        
        [JsonProperty("processedDate")]
        public DateTime ProcessedDate { get; set; }
    }
    
    public class SentimentAnalysis
    {
        [JsonProperty("overall")]
        public string Overall { get; set; } = string.Empty;
        
        [JsonProperty("score")]
        public double Score { get; set; }
        
        [JsonProperty("confidence")]
        public double Confidence { get; set; }
        
        [JsonProperty("detailed")]
        public Dictionary<string, double> Detailed { get; set; } = new();
    }
    
    public class Theme
    {
        [JsonProperty("name")]
        public string Name { get; set; } = string.Empty;
        
        [JsonProperty("category")]
        public string Category { get; set; } = string.Empty;
        
        [JsonProperty("relevance")]
        public double Relevance { get; set; }
        
        [JsonProperty("mentions")]
        public int Mentions { get; set; }
        
        [JsonProperty("quotes")]
        public List<string> Quotes { get; set; } = new();
    }
    
    public class ActionItem
    {
        [JsonProperty("description")]
        public string Description { get; set; } = string.Empty;
        
        [JsonProperty("assignedTo")]
        public string AssignedTo { get; set; } = string.Empty;
        
        [JsonProperty("priority")]
        public Priority Priority { get; set; } = Priority.Medium;
        
        [JsonProperty("dueDate")]
        public DateTime? DueDate { get; set; }
        
        [JsonProperty("status")]
        public ActionItemStatus Status { get; set; } = ActionItemStatus.Open;
    }
    
    public enum ProcessingStatus
    {
        Pending,
        Processing,
        Completed,
        Failed,
        Retry
    }
    
    public enum Priority
    {
        Low,
        Medium,
        High,
        Critical
    }
    
    public enum ActionItemStatus
    {
        Open,
        InProgress,
        Completed,
        Cancelled
    }
}