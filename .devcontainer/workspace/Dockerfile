# ============================================================================
# WORKSPACE CONTAINER DOCKERFILE
# ============================================================================
# This is the main development container for the DevContainer environment
#
# Responsibilities:
# - Python development (3.12)
# - Jupyter notebooks
# - Code editing and debugging
# - Git operations
# - Docker CLI (Docker-outside-of-Docker)
# - Playwright client library (NOT browsers)
#
# What's NOT included (moved to playwright service):
# - ❌ Chromium browser
# - ❌ Browser system dependencies
# - ❌ Xvfb virtual display
# - ❌ Playwright browser binaries
#
# Benefits:
# - Smaller image size
# - Faster rebuilds
# - Cleaner development environment
# - Better separation of concerns
# ============================================================================

# ============================================================================
# BASE IMAGE
# ============================================================================
# Official Microsoft DevContainer Python image
# - Python 3.12 pre-installed
# - Common build tools included
# - Non-root vscode user configured
# - Debian Bookworm (Debian 12) base
# ============================================================================
FROM mcr.microsoft.com/devcontainers/python:3.12-bookworm

# ============================================================================
# METADATA
# ============================================================================
LABEL maintainer="Claude Code DevContainer"
LABEL description="Development workspace for Claude Code with Python, Jupyter, and Docker CLI"
LABEL version="1.0.0"

# ============================================================================
# INSTALL SYSTEM DEPENDENCIES
# ============================================================================
# Install minimal system packages needed for development
# Note: No browser dependencies! Those are in the playwright service
# ============================================================================
RUN apt-get update && apt-get install -y \
    # Network utilities (needed for Node.js install script)
    curl \
    wget \
    # Version control
    git \
    # Build tools (already in base, but ensuring they're present)
    build-essential \
    # Process management
    procps \
    # Network diagnostics (for testing connectivity to playwright service)
    iputils-ping \
    dnsutils \
    # Clean up
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# INSTALL NODE.JS (REQUIRED FOR CLAUDE CODE CLI)
# ============================================================================
# Install Node.js 22 LTS from NodeSource repository
# This is more reliable than using DevContainer features in Docker Compose mode
# ============================================================================
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# ============================================================================
# INSTALL UV (FAST PYTHON PACKAGE MANAGER)
# ============================================================================
# uv is a fast Python package manager written in Rust
# Faster alternative to pip for installing packages
# https://github.com/astral-sh/uv
# ============================================================================
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Add uv to PATH for all users
ENV PATH="/root/.cargo/bin:/home/vscode/.cargo/bin:$PATH"

# ============================================================================
# CREATE WORKSPACE DIRECTORY
# ============================================================================
# This will be the working directory for development
# Matches the docker-compose volume mount path
# ============================================================================
WORKDIR /workspaces/claude_in_devcontainer

# ============================================================================
# USER CONFIGURATION
# ============================================================================
# Switch to non-root vscode user (already created by base image)
# This is a security best practice
# The user has sudo access if needed
# ============================================================================
USER vscode

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================
# Set environment variables for the vscode user
# These can be overridden by docker-compose
# ============================================================================
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# ============================================================================
# SETUP WILL CONTINUE IN POST-CREATE SCRIPT
# ============================================================================
# The post-create.sh script will:
# - Create Python virtual environment
# - Install Python packages
# - Configure shell
# - Create utility scripts
#
# This keeps the Dockerfile minimal and rebuild times fast
# Heavy setup work is done in post-create (only runs once)
# ============================================================================

# Note: CMD is not needed - docker-compose specifies "sleep infinity"
