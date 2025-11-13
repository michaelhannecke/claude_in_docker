# ============================================================================
# PLAYWRIGHT SERVICE DOCKERFILE
# ============================================================================
# This container runs Playwright browser automation as a service
# It exposes an HTTP API for remote browser control
#
# Architecture:
# - Xvfb virtual display for headless browser rendering
# - Chromium browser via Playwright
# - Express.js HTTP server for API
# - Health check endpoint for orchestration
#
# Usage:
# - Part of multi-container DevContainer setup
# - Called by workspace container via HTTP API
# - Isolated from development environment
# ============================================================================

FROM mcr.microsoft.com/playwright:v1.55.0-jammy

# ============================================================================
# METADATA
# ============================================================================
LABEL maintainer="Claude Code DevContainer"
LABEL description="Playwright browser automation service with HTTP API"
LABEL version="1.0.0"

# ============================================================================
# INSTALL SYSTEM DEPENDENCIES
# ============================================================================
# Install additional tools required for the service
# - xvfb: Virtual framebuffer for headless display
# - curl: For health checks and debugging
# - procps: For process management (ps, kill)
# ============================================================================
RUN apt-get update && apt-get install -y \
    xvfb \
    curl \
    procps \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# CREATE DIRECTORY STRUCTURE
# ============================================================================
# /app: Application code (server, scripts)
# /artifacts: Browser automation outputs
#   - screenshots: Screenshot captures
#   - videos: Screen recordings
#   - traces: Playwright trace files for debugging
# ============================================================================
RUN mkdir -p /app \
    /artifacts/screenshots \
    /artifacts/videos \
    /artifacts/traces

# ============================================================================
# COPY APPLICATION FILES
# ============================================================================
# Copy all service files to /app directory
# These files will be created in subsequent steps
# ============================================================================
COPY playwright-server.js /app/playwright-server.js
COPY start-xvfb.sh /app/start-xvfb.sh
COPY healthcheck.sh /app/healthcheck.sh

# Make scripts executable
RUN chmod +x /app/start-xvfb.sh /app/healthcheck.sh

# ============================================================================
# INSTALL NODE.JS DEPENDENCIES
# ============================================================================
# Create minimal package.json and install required npm packages
# - express: HTTP server framework
# - playwright: Browser automation library
# - cors: Cross-Origin Resource Sharing support
# ============================================================================
WORKDIR /app

# Create package.json and install dependencies
RUN npm init -y && \
    npm install express cors playwright@1.55.0

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================
# DISPLAY: X11 display number for Xvfb
# PLAYWRIGHT_BROWSERS_PATH: Where Playwright stores browsers
# PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD: Don't skip (browsers already in base image)
# NODE_ENV: Production mode for Express
# ============================================================================
ENV DISPLAY=:99
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
ENV PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=0
ENV NODE_ENV=production

# ============================================================================
# EXPOSE PORT
# ============================================================================
# Port 3000: HTTP API for browser automation
# This port is only exposed to the internal Docker network
# Not accessible from host (security by design)
# ============================================================================
EXPOSE 3000

# ============================================================================
# HEALTH CHECK
# ============================================================================
# Docker will periodically run this command to check container health
# - Uses the healthcheck.sh script
# - Interval: Check every 30 seconds
# - Timeout: Wait up to 10 seconds for response
# - Retries: 3 consecutive failures before marking unhealthy
# - Start period: Wait 40 seconds before first check (startup time)
# ============================================================================
HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=40s \
    CMD ["/app/healthcheck.sh"]

# ============================================================================
# STARTUP COMMAND
# ============================================================================
# Execute the startup script which:
# 1. Starts Xvfb virtual display on :99
# 2. Starts Playwright HTTP server on port 3000
# 3. Keeps both processes running
# ============================================================================
CMD ["/app/start-xvfb.sh"]
