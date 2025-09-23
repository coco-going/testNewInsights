using Xunit;
using Moq;
using MarketingInsights.Shared.Models;
using MarketingInsights.Shared.Services;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MarketingInsights.Tests.Models
{
    public class TranscriptTests
    {
        [Fact]
        public void Transcript_DefaultConstructor_InitializesProperties()
        {
            // Arrange & Act
            var transcript = new Transcript();

            // Assert
            Assert.Equal(string.Empty, transcript.Id);
            Assert.Equal(string.Empty, transcript.MeetingId);
            Assert.Equal(string.Empty, transcript.Title);
            Assert.Equal(string.Empty, transcript.Content);
            Assert.NotNull(transcript.Participants);
            Assert.Empty(transcript.Participants);
            Assert.Equal(ProcessingStatus.Pending, transcript.Status);
        }

        [Fact]
        public void Transcript_SetProperties_ReturnsCorrectValues()
        {
            // Arrange
            var transcript = new Transcript();
            var testId = Guid.NewGuid().ToString();
            var testTitle = "Test Meeting";
            var testContent = "This is test content";
            var testDate = DateTime.UtcNow;

            // Act
            transcript.Id = testId;
            transcript.Title = testTitle;
            transcript.Content = testContent;
            transcript.CreatedDate = testDate;
            transcript.Status = ProcessingStatus.Completed;

            // Assert
            Assert.Equal(testId, transcript.Id);
            Assert.Equal(testTitle, transcript.Title);
            Assert.Equal(testContent, transcript.Content);
            Assert.Equal(testDate, transcript.CreatedDate);
            Assert.Equal(ProcessingStatus.Completed, transcript.Status);
        }

        [Fact]
        public void AiInsights_DefaultConstructor_InitializesCollections()
        {
            // Arrange & Act
            var insights = new AiInsights();

            // Assert
            Assert.NotNull(insights.Sentiment);
            Assert.NotNull(insights.Themes);
            Assert.NotNull(insights.KeyPoints);
            Assert.NotNull(insights.ActionItems);
            Assert.Equal(string.Empty, insights.Summary);
            Assert.Equal(0.0, insights.Confidence);
        }

        [Fact]
        public void Theme_Properties_SetCorrectly()
        {
            // Arrange
            var theme = new Theme();
            var testName = "User Experience";
            var testCategory = "Product";
            var testRelevance = 0.85;
            var testMentions = 5;

            // Act
            theme.Name = testName;
            theme.Category = testCategory;
            theme.Relevance = testRelevance;
            theme.Mentions = testMentions;

            // Assert
            Assert.Equal(testName, theme.Name);
            Assert.Equal(testCategory, theme.Category);
            Assert.Equal(testRelevance, theme.Relevance);
            Assert.Equal(testMentions, theme.Mentions);
        }

        [Fact]
        public void ActionItem_DefaultPriority_IsMedium()
        {
            // Arrange & Act
            var actionItem = new ActionItem();

            // Assert
            Assert.Equal(Priority.Medium, actionItem.Priority);
            Assert.Equal(ActionItemStatus.Open, actionItem.Status);
        }

        [Theory]
        [InlineData(ProcessingStatus.Pending)]
        [InlineData(ProcessingStatus.Processing)]
        [InlineData(ProcessingStatus.Completed)]
        [InlineData(ProcessingStatus.Failed)]
        [InlineData(ProcessingStatus.Retry)]
        public void ProcessingStatus_AllValues_AreValid(ProcessingStatus status)
        {
            // Arrange
            var transcript = new Transcript();

            // Act
            transcript.Status = status;

            // Assert
            Assert.Equal(status, transcript.Status);
        }
    }
}