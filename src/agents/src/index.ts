import express from 'express';
import { config } from 'dotenv';
import { TeamsActivityHandler } from './teamsActivityHandler';
import { TranscriptService } from './services/transcriptService';
import { AiService } from './services/aiService';

// Load environment variables
config();

const app = express();
const port = process.env.PORT || 3978;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Initialize services
const transcriptService = new TranscriptService();
const aiService = new AiService();
const teamsHandler = new TeamsActivityHandler(transcriptService, aiService);

// Health check endpoint
app.get('/health', (req, res) => {
    res.status(200).json({ 
        status: 'healthy', 
        timestamp: new Date().toISOString(),
        version: process.env.npm_package_version || '1.0.0'
    });
});

// Teams bot endpoint
app.post('/api/messages', async (req, res) => {
    try {
        await teamsHandler.processActivity(req, res);
    } catch (error) {
        console.error('Error processing Teams activity:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// API endpoints for transcript operations
app.get('/api/transcripts/search', async (req, res) => {
    try {
        const query = req.query.q as string;
        if (!query) {
            return res.status(400).json({ error: 'Query parameter "q" is required' });
        }
        
        const results = await transcriptService.searchTranscripts(query);
        res.json(results);
    } catch (error) {
        console.error('Error searching transcripts:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

app.get('/api/transcripts/themes', async (req, res) => {
    try {
        const themes = await transcriptService.getThemes();
        res.json(themes);
    } catch (error) {
        console.error('Error getting themes:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

app.get('/api/transcripts/insights', async (req, res) => {
    try {
        const insights = await aiService.getInsightsSummary();
        res.json(insights);
    } catch (error) {
        console.error('Error getting insights:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Error handling middleware
app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
    console.error('Unhandled error:', err);
    res.status(500).json({ error: 'Internal server error' });
});

// Start server
app.listen(port, () => {
    console.log(`Marketing Insights Agent listening on port ${port}`);
    console.log(`Health check available at: http://localhost:${port}/health`);
});

export default app;