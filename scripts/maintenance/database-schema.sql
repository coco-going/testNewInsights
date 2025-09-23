-- Marketing Insights Database Schema
-- This script creates the database schema for storing transcripts and AI insights

USE [MarketingInsights]
GO

-- Create schema for organizing objects
CREATE SCHEMA [insights] AUTHORIZATION [dbo]
GO

-- Transcripts table
CREATE TABLE [insights].[Transcripts] (
    [Id] NVARCHAR(50) NOT NULL PRIMARY KEY,
    [MeetingId] NVARCHAR(100) NOT NULL,
    [Title] NVARCHAR(500) NOT NULL,
    [Content] NTEXT NOT NULL,
    [CreatedDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    [Duration] TIME(7) NULL,
    [Organizer] NVARCHAR(255) NULL,
    [ProcessedDate] DATETIME2(7) NULL,
    [Status] INT NOT NULL DEFAULT 0, -- 0=Pending, 1=Processing, 2=Completed, 3=Failed, 4=Retry
    [Participants] NVARCHAR(MAX) NULL, -- JSON array of participants
    [AiInsights] NVARCHAR(MAX) NULL, -- JSON object containing AI analysis
    [CreatedBy] NVARCHAR(100) NULL,
    [ModifiedDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    [ModifiedBy] NVARCHAR(100) NULL,
    [Version] INT NOT NULL DEFAULT 1
)
GO

-- Create indexes for performance
CREATE INDEX [IX_Transcripts_Status] ON [insights].[Transcripts] ([Status])
GO

CREATE INDEX [IX_Transcripts_CreatedDate] ON [insights].[Transcripts] ([CreatedDate])
GO

CREATE INDEX [IX_Transcripts_ProcessedDate] ON [insights].[Transcripts] ([ProcessedDate])
GO

CREATE INDEX [IX_Transcripts_MeetingId] ON [insights].[Transcripts] ([MeetingId])
GO

-- Full-text search index for content
CREATE FULLTEXT CATALOG [MarketingInsightsCatalog] AS DEFAULT
GO

CREATE FULLTEXT INDEX ON [insights].[Transcripts] 
(
    [Title] LANGUAGE 1033,
    [Content] LANGUAGE 1033
)
KEY INDEX [PK__Transcri__3214EC0701234567] -- Replace with actual primary key constraint name
GO

-- Themes table for aggregated theme analysis
CREATE TABLE [insights].[Themes] (
    [Id] INT IDENTITY(1,1) PRIMARY KEY,
    [Name] NVARCHAR(255) NOT NULL,
    [Category] NVARCHAR(100) NULL,
    [Description] NVARCHAR(1000) NULL,
    [FirstSeen] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    [LastSeen] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    [OccurrenceCount] INT NOT NULL DEFAULT 1,
    [TotalRelevanceScore] DECIMAL(10,2) NOT NULL DEFAULT 0,
    [AverageRelevanceScore] AS ([TotalRelevanceScore] / [OccurrenceCount]) PERSISTED,
    [IsActive] BIT NOT NULL DEFAULT 1
)
GO

CREATE UNIQUE INDEX [IX_Themes_Name] ON [insights].[Themes] ([Name])
GO

-- Transcript-Theme junction table
CREATE TABLE [insights].[TranscriptThemes] (
    [TranscriptId] NVARCHAR(50) NOT NULL,
    [ThemeId] INT NOT NULL,
    [RelevanceScore] DECIMAL(5,2) NOT NULL,
    [Mentions] INT NOT NULL DEFAULT 1,
    [Quotes] NVARCHAR(MAX) NULL, -- JSON array of relevant quotes
    [CreatedDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT [PK_TranscriptThemes] PRIMARY KEY ([TranscriptId], [ThemeId]),
    CONSTRAINT [FK_TranscriptThemes_Transcript] FOREIGN KEY ([TranscriptId]) 
        REFERENCES [insights].[Transcripts]([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_TranscriptThemes_Theme] FOREIGN KEY ([ThemeId]) 
        REFERENCES [insights].[Themes]([Id]) ON DELETE CASCADE
)
GO

-- Action Items table
CREATE TABLE [insights].[ActionItems] (
    [Id] INT IDENTITY(1,1) PRIMARY KEY,
    [TranscriptId] NVARCHAR(50) NOT NULL,
    [Description] NVARCHAR(1000) NOT NULL,
    [AssignedTo] NVARCHAR(255) NULL,
    [Priority] INT NOT NULL DEFAULT 1, -- 0=Low, 1=Medium, 2=High, 3=Critical
    [Status] INT NOT NULL DEFAULT 0, -- 0=Open, 1=InProgress, 2=Completed, 3=Cancelled
    [DueDate] DATETIME2(7) NULL,
    [CreatedDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    [CompletedDate] DATETIME2(7) NULL,
    [Notes] NVARCHAR(MAX) NULL,
    
    CONSTRAINT [FK_ActionItems_Transcript] FOREIGN KEY ([TranscriptId]) 
        REFERENCES [insights].[Transcripts]([Id]) ON DELETE CASCADE
)
GO

CREATE INDEX [IX_ActionItems_Status] ON [insights].[ActionItems] ([Status])
GO

CREATE INDEX [IX_ActionItems_Priority] ON [insights].[ActionItems] ([Priority])
GO

-- Processing Log table for audit trail
CREATE TABLE [insights].[ProcessingLog] (
    [Id] INT IDENTITY(1,1) PRIMARY KEY,
    [TranscriptId] NVARCHAR(50) NOT NULL,
    [ProcessingStep] NVARCHAR(100) NOT NULL,
    [Status] NVARCHAR(50) NOT NULL,
    [StartTime] DATETIME2(7) NOT NULL,
    [EndTime] DATETIME2(7) NULL,
    [Duration] AS DATEDIFF(SECOND, [StartTime], [EndTime]) PERSISTED,
    [ErrorMessage] NVARCHAR(MAX) NULL,
    [Details] NVARCHAR(MAX) NULL, -- JSON object with step-specific details
    [CreatedDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    
    CONSTRAINT [FK_ProcessingLog_Transcript] FOREIGN KEY ([TranscriptId]) 
        REFERENCES [insights].[Transcripts]([Id]) ON DELETE CASCADE
)
GO

-- System Configuration table
CREATE TABLE [insights].[SystemConfiguration] (
    [Key] NVARCHAR(100) NOT NULL PRIMARY KEY,
    [Value] NVARCHAR(MAX) NOT NULL,
    [Description] NVARCHAR(500) NULL,
    [Category] NVARCHAR(100) NULL,
    [IsEncrypted] BIT NOT NULL DEFAULT 0,
    [CreatedDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE(),
    [ModifiedDate] DATETIME2(7) NOT NULL DEFAULT GETUTCDATE()
)
GO

-- Insert default configuration values
INSERT INTO [insights].[SystemConfiguration] ([Key], [Value], [Description], [Category])
VALUES 
    ('ProcessingBatchSize', '10', 'Number of transcripts to process in each batch', 'Processing'),
    ('MaxRetryAttempts', '3', 'Maximum number of retry attempts for failed processing', 'Processing'),
    ('SearchResultsLimit', '50', 'Maximum number of search results to return', 'Search'),
    ('ThemeMinimumRelevance', '0.5', 'Minimum relevance score for theme extraction', 'AI'),
    ('SentimentAnalysisEnabled', 'true', 'Enable sentiment analysis processing', 'AI'),
    ('AzureSearchEnabled', 'false', 'Enable Azure Search integration', 'Features'),
    ('FabricIntegrationEnabled', 'false', 'Enable Microsoft Fabric integration', 'Features')
GO

-- Create views for common queries
CREATE VIEW [insights].[vw_TranscriptSummary]
AS
SELECT 
    t.[Id],
    t.[Title],
    t.[CreatedDate],
    t.[Status],
    t.[ProcessedDate],
    JSON_VALUE(t.[AiInsights], '$.sentiment.overall') as [SentimentOverall],
    JSON_VALUE(t.[AiInsights], '$.summary') as [Summary],
    COUNT(ai.[Id]) as [ActionItemCount],
    COUNT(tt.[ThemeId]) as [ThemeCount]
FROM [insights].[Transcripts] t
LEFT JOIN [insights].[ActionItems] ai ON t.[Id] = ai.[TranscriptId]
LEFT JOIN [insights].[TranscriptThemes] tt ON t.[Id] = tt.[TranscriptId]
GROUP BY t.[Id], t.[Title], t.[CreatedDate], t.[Status], t.[ProcessedDate], t.[AiInsights]
GO

-- Create stored procedures for common operations
CREATE PROCEDURE [insights].[sp_GetTranscriptById]
    @TranscriptId NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT * FROM [insights].[Transcripts] 
    WHERE [Id] = @TranscriptId;
END
GO

CREATE PROCEDURE [insights].[sp_SearchTranscripts]
    @SearchTerm NVARCHAR(255),
    @MaxResults INT = 50
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP (@MaxResults)
        t.[Id],
        t.[Title],
        t.[CreatedDate],
        t.[Status],
        JSON_VALUE(t.[AiInsights], '$.summary') as [Summary],
        RANK() OVER (ORDER BY [ft_rank].[RANK] DESC) as [SearchRank]
    FROM [insights].[Transcripts] t
    INNER JOIN CONTAINSTABLE([insights].[Transcripts], ([Title], [Content]), @SearchTerm) as [ft_rank]
        ON t.[Id] = [ft_rank].[KEY]
    ORDER BY [ft_rank].[RANK] DESC;
END
GO

-- Grant permissions (adjust as needed for your security model)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::[insights] TO [MarketingInsightsApp];
-- GRANT EXECUTE ON SCHEMA::[insights] TO [MarketingInsightsApp];

PRINT 'Database schema created successfully';
GO