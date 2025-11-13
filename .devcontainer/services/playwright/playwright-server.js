// ============================================================================
// PLAYWRIGHT HTTP API SERVER
// ============================================================================
// This Express.js server exposes Playwright browser automation via HTTP API
//
// Architecture:
// - Single shared browser instance (Chromium)
// - Multiple browser contexts (isolated sessions)
// - RESTful HTTP endpoints for automation tasks
// - Artifact storage (screenshots, videos, traces)
//
// Endpoints:
// - GET  /health              - Health check and status
// - POST /browser/new         - Create new browser context
// - POST /browser/:id/close   - Close browser context
// - POST /navigate            - Navigate to URL
// - POST /screenshot          - Take screenshot
// - POST /evaluate            - Execute JavaScript
// - POST /pdf                 - Generate PDF
// - POST /accessibility       - Run accessibility audit
//
// Usage:
// Called by workspace container via: http://playwright:3000
// ============================================================================

const express = require('express');
const { chromium } = require('playwright');
const cors = require('cors');
const fs = require('fs').promises;
const path = require('path');

// ============================================================================
// SERVER CONFIGURATION
// ============================================================================
const app = express();
const PORT = process.env.PORT || 3000;
const HOST = '0.0.0.0'; // Listen on all interfaces (for Docker networking)

// Middleware
app.use(cors()); // Allow cross-origin requests
app.use(express.json({ limit: '10mb' })); // Parse JSON bodies (large for page content)

// ============================================================================
// GLOBAL STATE
// ============================================================================
// browser: Shared Chromium instance
// contexts: Map of contextId -> { context, page, metadata }
// ============================================================================
let browser = null;
const contexts = new Map();

// ============================================================================
// BROWSER INITIALIZATION
// ============================================================================
async function initBrowser() {
    try {
        console.log('🚀 Initializing Chromium browser...');
        browser = await chromium.launch({
            headless: true,
            args: [
                '--no-sandbox',              // Required in Docker
                '--disable-dev-shm-usage',   // Use /tmp instead of /dev/shm
                '--disable-gpu',             // Not needed for headless
                '--disable-software-rasterizer',
                '--disable-extensions',
                '--no-first-run',
                '--no-zygote'
            ]
        });
        console.log('✅ Browser initialized successfully');
        console.log(`   Browser version: ${browser.version()}`);
    } catch (error) {
        console.error('❌ Failed to initialize browser:', error);
        throw error;
    }
}

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

// Generate unique context ID
function generateContextId() {
    return `ctx_${Date.now()}_${Math.random().toString(36).substring(7)}`;
}

// Validate context exists
function validateContext(contextId) {
    if (!contexts.has(contextId)) {
        throw new Error(`Context not found: ${contextId}`);
    }
    return contexts.get(contextId);
}

// Ensure artifact directory exists
async function ensureArtifactDir(subdir) {
    const dir = path.join('/artifacts', subdir);
    await fs.mkdir(dir, { recursive: true });
    return dir;
}

// ============================================================================
// HEALTH CHECK ENDPOINT
// ============================================================================
// GET /health
// Returns service status and metrics
// ============================================================================
app.get('/health', (req, res) => {
    const health = {
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        browser: {
            running: browser !== null,
            version: browser ? browser.version() : 'not initialized',
            contexts: contexts.size
        },
        memory: {
            used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
            total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024),
            unit: 'MB'
        },
        environment: {
            display: process.env.DISPLAY,
            nodeVersion: process.version
        }
    };

    res.json(health);
});

// ============================================================================
// BROWSER CONTEXT MANAGEMENT
// ============================================================================

// POST /browser/new
// Create new browser context (isolated session)
// Body: { options: { viewport, userAgent, etc. } }
// Returns: { contextId, status }
// ============================================================================
app.post('/browser/new', async (req, res) => {
    try {
        const options = req.body.options || {};

        // Create new context with options
        const context = await browser.newContext({
            viewport: options.viewport || { width: 1920, height: 1080 },
            userAgent: options.userAgent,
            locale: options.locale || 'en-US',
            timezoneId: options.timezoneId,
            ...options
        });

        // Create new page in context
        const page = await context.newPage();

        // Generate context ID and store
        const contextId = generateContextId();
        contexts.set(contextId, {
            context,
            page,
            createdAt: new Date().toISOString(),
            metadata: options.metadata || {}
        });

        console.log(`✅ Created browser context: ${contextId}`);

        res.json({
            contextId,
            status: 'created',
            viewport: options.viewport || { width: 1920, height: 1080 }
        });

    } catch (error) {
        console.error('❌ Error creating browser context:', error);
        res.status(500).json({
            error: error.message,
            stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
        });
    }
});

// POST /browser/:id/close
// Close browser context and cleanup
// Returns: { status }
// ============================================================================
app.post('/browser/:id/close', async (req, res) => {
    try {
        const contextId = req.params.id;
        const contextData = validateContext(contextId);

        // Close context
        await contextData.context.close();

        // Remove from map
        contexts.delete(contextId);

        console.log(`✅ Closed browser context: ${contextId}`);

        res.json({ status: 'closed', contextId });

    } catch (error) {
        console.error('❌ Error closing browser context:', error);
        res.status(500).json({ error: error.message });
    }
});

// ============================================================================
// BROWSER AUTOMATION ENDPOINTS
// ============================================================================

// POST /navigate
// Navigate to URL
// Body: { contextId, url, waitUntil }
// Returns: { status, url, title }
// ============================================================================
app.post('/navigate', async (req, res) => {
    try {
        const { contextId, url, waitUntil } = req.body;
        const { page } = validateContext(contextId);

        await page.goto(url, {
            waitUntil: waitUntil || 'networkidle',
            timeout: 30000
        });

        const title = await page.title();

        console.log(`✅ Navigated to: ${url}`);

        res.json({
            status: 'success',
            url,
            title
        });

    } catch (error) {
        console.error('❌ Error navigating:', error);
        res.status(500).json({ error: error.message });
    }
});

// POST /screenshot
// Take screenshot
// Body: { contextId, path, fullPage, type }
// Returns: { status, path }
// ============================================================================
app.post('/screenshot', async (req, res) => {
    try {
        const { contextId, path: filename, fullPage, type } = req.body;
        const { page } = validateContext(contextId);

        // Ensure screenshots directory exists
        const screenshotDir = await ensureArtifactDir('screenshots');
        const filepath = path.join(screenshotDir, filename || 'screenshot.png');

        await page.screenshot({
            path: filepath,
            fullPage: fullPage !== undefined ? fullPage : true,
            type: type || 'png'
        });

        console.log(`✅ Screenshot saved: ${filepath}`);

        res.json({
            status: 'success',
            path: filepath,
            filename
        });

    } catch (error) {
        console.error('❌ Error taking screenshot:', error);
        res.status(500).json({ error: error.message });
    }
});

// POST /evaluate
// Execute JavaScript in page context
// Body: { contextId, script }
// Returns: { status, result }
// ============================================================================
app.post('/evaluate', async (req, res) => {
    try {
        const { contextId, script } = req.body;
        const { page } = validateContext(contextId);

        const result = await page.evaluate(script);

        console.log(`✅ Evaluated script in context: ${contextId}`);

        res.json({
            status: 'success',
            result
        });

    } catch (error) {
        console.error('❌ Error evaluating script:', error);
        res.status(500).json({ error: error.message });
    }
});

// POST /pdf
// Generate PDF of page
// Body: { contextId, path, format, landscape }
// Returns: { status, path }
// ============================================================================
app.post('/pdf', async (req, res) => {
    try {
        const { contextId, path: filename, format, landscape } = req.body;
        const { page } = validateContext(contextId);

        const pdfDir = await ensureArtifactDir('pdfs');
        const filepath = path.join(pdfDir, filename || 'page.pdf');

        await page.pdf({
            path: filepath,
            format: format || 'A4',
            landscape: landscape || false
        });

        console.log(`✅ PDF generated: ${filepath}`);

        res.json({
            status: 'success',
            path: filepath
        });

    } catch (error) {
        console.error('❌ Error generating PDF:', error);
        res.status(500).json({ error: error.message });
    }
});

// POST /accessibility
// Run accessibility audit
// Body: { contextId }
// Returns: { status, violations }
// ============================================================================
app.post('/accessibility', async (req, res) => {
    try {
        const { contextId } = req.body;
        const { page } = validateContext(contextId);

        // Use Playwright's accessibility snapshot
        const snapshot = await page.accessibility.snapshot();

        console.log(`✅ Accessibility audit completed for context: ${contextId}`);

        res.json({
            status: 'success',
            snapshot
        });

    } catch (error) {
        console.error('❌ Error running accessibility audit:', error);
        res.status(500).json({ error: error.message });
    }
});

// ============================================================================
// ERROR HANDLING
// ============================================================================

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        error: 'Endpoint not found',
        path: req.path,
        method: req.method
    });
});

// Global error handler
app.use((err, req, res, next) => {
    console.error('❌ Unhandled error:', err);
    res.status(500).json({
        error: 'Internal server error',
        message: err.message
    });
});

// ============================================================================
// CLEANUP HANDLERS
// ============================================================================

// Graceful shutdown
async function cleanup() {
    console.log('🛑 Shutting down gracefully...');

    // Close all contexts
    for (const [contextId, contextData] of contexts.entries()) {
        try {
            await contextData.context.close();
            console.log(`   Closed context: ${contextId}`);
        } catch (error) {
            console.error(`   Error closing context ${contextId}:`, error);
        }
    }
    contexts.clear();

    // Close browser
    if (browser) {
        await browser.close();
        console.log('   Browser closed');
    }

    process.exit(0);
}

// Handle shutdown signals
process.on('SIGTERM', cleanup);
process.on('SIGINT', cleanup);

// Handle uncaught errors
process.on('uncaughtException', (error) => {
    console.error('❌ Uncaught exception:', error);
    cleanup();
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('❌ Unhandled rejection at:', promise, 'reason:', reason);
});

// ============================================================================
// SERVER STARTUP
// ============================================================================
async function startServer() {
    try {
        // Initialize browser
        await initBrowser();

        // Start HTTP server
        app.listen(PORT, HOST, () => {
            console.log('');
            console.log('🎭 Playwright HTTP Server');
            console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            console.log(`   Listening on: http://${HOST}:${PORT}`);
            console.log(`   Health check: http://${HOST}:${PORT}/health`);
            console.log(`   Display: ${process.env.DISPLAY}`);
            console.log(`   Browser: Chromium ${browser.version()}`);
            console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            console.log('');
        });

    } catch (error) {
        console.error('❌ Failed to start server:', error);
        process.exit(1);
    }
}

// Start the server
startServer();
