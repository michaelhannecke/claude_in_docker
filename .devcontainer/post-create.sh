#!/bin/bash
################################################################################
# POST-CREATE SETUP SCRIPT
################################################################################
# This script runs ONCE after the DevContainer is created (not on every start)
#
# WHEN DOES THIS RUN?
# - First time opening project in container
# - After manually rebuilding the container (Cmd+Shift+P → Rebuild Container)
# - After changing devcontainer.json settings and rebuilding
#
# WHAT DOES THIS SCRIPT DO?
# 1. Install system packages (browser dependencies, libraries)
# 2. Install Python packages with pinned versions
# 3. Install Node.js packages globally (Claude Code)
# 4. Verify Docker access (Docker-outside-of-Docker setup)
# 5. Create web-ui-optimizer project with Playwright tools
# 6. Download and install Chromium browser binaries
# 7. Set up Xvfb (virtual display for headless browser automation)
# 8. Generate utility scripts (verification, optimization tools)
# 9. Create comprehensive documentation (README.md)
#
# EXECUTION CONTEXT:
# - Runs as 'vscode' user (non-root)
# - Has sudo access for system package installation
# - Working directory: /workspaces/<project-name>
# - Takes 5-10 minutes on first run (browser downloads)
#
# TROUBLESHOOTING:
# - Check logs in VS Code: View → Output → Dev Containers
# - If script fails, container won't start properly
# - Can run manually: bash .devcontainer/post-create.sh
# - Common issues: Network connectivity, disk space, permissions
#
# SECURITY NOTES:
# - Package versions are pinned to prevent supply chain attacks
# - Uses --no-sandbox for Chromium (acceptable in dev containers)
# - Docker socket mounted for testing (see devcontainer.json)
# - No secrets or credentials stored in this script
################################################################################

# ==============================================================================
# BASH ERROR HANDLING
# ==============================================================================
# Exit immediately if any command fails (non-zero exit code)
# Prevents cascade failures and makes debugging easier
# Without this, script would continue even if critical commands fail
set -e

echo "🚀 Starting Playwright + Claude Code setup..."

# ==============================================================================
# COLORED OUTPUT HELPERS
# ==============================================================================
# ANSI escape codes for terminal colors
# Makes output easier to read and identify success/warning/info messages
# These work in most terminals (bash, zsh, terminal emulators)
GREEN='\033[0;32m'    # For success messages
BLUE='\033[0;34m'     # For status/info messages
YELLOW='\033[1;33m'   # For warning messages
NC='\033[0m'          # No Color (reset to default)

# ------------------------------------------------------------------------------
# Print status message in blue
# Usage: print_status "Installing packages..."
# ------------------------------------------------------------------------------
print_status() {
    echo -e "${BLUE}==>${NC} $1"
}

# ------------------------------------------------------------------------------
# Print success message in green with checkmark
# Usage: print_success "Installation complete"
# ------------------------------------------------------------------------------
print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

# ------------------------------------------------------------------------------
# Print warning message in yellow with warning emoji
# Usage: print_warning "Package not found, skipping..."
# ------------------------------------------------------------------------------
print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

# ==============================================================================
# SECTION 1: SYSTEM DEPENDENCIES FOR CHROMIUM/PLAYWRIGHT
# ==============================================================================
# Install native libraries required by Chromium browser
#
# WHY SO MANY PACKAGES?
# Chromium is a complex application that requires many system libraries:
# - Graphics libraries (GTK, Cairo, Pango, Vulkan)
# - Audio/Video libraries (GStreamer, ALSA)
# - Font rendering (libharfbuzz, ICU)
# - X11/Display libraries (libxkbcommon, libxrandr, libxdamage)
# - Security libraries (libnss3, libsecret)
# - Accessibility libraries (libatspi, libatk)
#
# XVFB (X Virtual Framebuffer):
# - Provides virtual display server for headless browser automation
# - Allows Chromium to run without physical display
# - Required for taking screenshots and rendering pages
#
# OPTIONS EXPLAINED:
# - sudo: Needed for system package installation
# - apt-get update: Refresh package lists from repositories
# - install -y: Auto-approve installation (non-interactive)
# - --no-install-recommends: Only install required packages, not suggested ones
#   (Reduces image size, faster installation)
#
# ERROR HANDLING:
# - || print_warning: If installation fails, show warning but continue
# - Some packages may not exist in all Debian versions
# - Script won't fail if optional packages are missing
#
# PACKAGE SIZE: ~200-300MB of libraries
# TIME: 2-3 minutes on first install
# ==============================================================================
print_status "Installing system dependencies for browsers..."
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 \
    libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 \
    libgbm1 libasound2 libatspi2.0-0 libgtk-3-0 libpango-1.0-0 \
    libcairo2 libgdk-pixbuf-2.0-0 xvfb fonts-liberation \
    fonts-noto-color-emoji libvulkan1 libxshmfence1 \
    libgstreamer1.0-0 libgstreamer-plugins-base1.0-0 libgstreamer-gl1.0-0 \
    libenchant-2-2 libsecret-1-0 libhyphen0 libmanette-0.2-0 \
    libgles2 gstreamer1.0-libav libx264-dev \
    libgtk-4-1 libwoff1 libopus0 libvpx7 libevent-2.1-7 \
    libharfbuzz-icu0 libicu70 || print_warning "Some packages may not be available, continuing..."

# ==============================================================================
# SECTION 2: NPM GLOBAL PACKAGES
# ==============================================================================
# Install Claude Code CLI globally for AI-assisted development
#
# WHAT IS CLAUDE CODE?
# - AI coding assistant by Anthropic
# - Command-line interface for Claude AI
# - Helps with code generation, debugging, refactoring
# - Available globally after installation: run with 'claude-code' command
#
# SECURITY: Version Pinning
# - @1.0.0: Specific version pinned to prevent supply chain attacks
# - Without version pinning, 'npm install' would get latest version
# - Latest version could be compromised or contain breaking changes
# - IMPORTANT: Update this version intentionally after testing
#
# GLOBAL INSTALLATION:
# - -g flag: Install globally (available system-wide)
# - Installed to: /usr/local/lib/node_modules/
# - Binary linked to: /usr/local/bin/claude-code
#
# TIME: 30-60 seconds
# SIZE: ~10-50MB (depends on dependencies)
# ==============================================================================
print_status "Installing Claude Code globally..."
# SECURITY: Pin to specific version to prevent supply chain attacks
# Update this version number as needed after testing new releases
npm install -g @anthropic-ai/claude-code@2.0.32

# ==============================================================================
# SECTION 3: PYTHON PACKAGES
# ==============================================================================
# Install Python packages for Playwright automation and data science
#
# UPGRADE PIP FIRST:
# - Ensures we have latest pip features and security fixes
# - Older pip versions may have installation issues
#
# SECURITY: All Versions Pinned
# - playwright==1.48.0: Browser automation framework
# - pytest==7.4.3: Testing framework
# - pytest-playwright==0.4.3: Pytest plugin for Playwright
# - black==23.12.1: Code formatter (PEP 8 compliant)
# - pylint==3.0.3: Code linter (style and error checking)
# - ipython==8.18.1: Interactive Python shell (better REPL)
# - numpy==1.26.2: Numerical computing library
# - pandas==2.1.4: Data manipulation and analysis
#
# WHY PIN VERSIONS?
# 1. Supply Chain Security: Prevent malicious updates from auto-installing
# 2. Reproducibility: Same versions across all team members
# 3. Stability: Avoid breaking changes from automatic updates
# 4. Compliance: Auditable dependency versions
#
# MAINTENANCE:
# - To update: Change version numbers and test thoroughly
# - Check for vulnerabilities: pip-audit or safety
# - Review changelogs before updating
#
# TIME: 2-3 minutes
# SIZE: ~200-300MB (numpy/pandas are large)
# ==============================================================================
print_status "Installing Python packages..."
pip install --upgrade pip
# SECURITY: Pin versions to prevent supply chain attacks
pip install \
    playwright==1.55.0 \
    pytest==7.4.3 \
    pytest-playwright==0.7.1 \
    black==23.12.1 \
    pylint==3.0.3 \
    ipython==8.18.1 \
    numpy==1.26.2 \
    pandas==2.3.3

# ==============================================================================
# SECTION 4: DOCKER VERIFICATION
# ==============================================================================
# Verify Docker-outside-of-Docker (DooD) setup is working
#
# HOW DOOD WORKS:
# 1. Docker CLI installed in container (by devcontainer feature)
# 2. Host Docker socket mounted into container (/var/run/docker.sock)
# 3. CLI commands talk to host Docker daemon via socket
# 4. Containers created are siblings to devcontainer, not children
#
# WHAT WE'RE CHECKING:
# 1. Is Docker CLI installed? (command -v docker)
# 2. Can we connect to Docker daemon? (docker ps)
# 3. What versions are installed? (docker --version)
# 4. Is Docker Compose available? (docker compose version)
#
# POSSIBLE OUTCOMES:
# ✅ Success: Docker CLI works, can communicate with daemon
# ⚠️  Warning: CLI found but can't connect (socket not mounted)
# ⚠️  Warning: CLI not found (feature not installed yet)
#
# WHY WARNINGS INSTEAD OF ERRORS?
# - Docker is optional for this dev environment
# - Main focus is Playwright/Python development
# - Script continues even if Docker isn't available
#
# TROUBLESHOOTING:
# - If connection fails, rebuild container (feature might not have run yet)
# - Check devcontainer.json has docker-outside-of-docker feature
# - Verify /var/run/docker.sock exists on host
# ==============================================================================
print_status "Verifying Docker access..."
if command -v docker &> /dev/null; then
    # Docker CLI is installed, test if we can connect to daemon
    if docker ps &> /dev/null; then
        print_success "Docker is available and working"
        docker --version
        docker compose version 2>/dev/null || echo "Docker Compose: Not available (optional)"
    else
        print_warning "Docker CLI installed but cannot access Docker daemon"
        print_warning "The devcontainer may need to be rebuilt for Docker socket mount"
    fi
else
    print_warning "Docker CLI not found - Docker feature may not be installed yet"
fi

# ==============================================================================
# SECTION 5: WEB-UI-OPTIMIZER PROJECT CREATION
# ==============================================================================
# Create a standalone Playwright project for UI testing and optimization
#
# PROJECT PURPOSE:
# - Provides ready-to-use Playwright automation tools
# - Example scripts for screenshot capture, accessibility testing
# - Documentation and examples for learning
# - Can be used independently or extended
#
# PROJECT STRUCTURE:
# ~/web-ui-optimizer/
# ├── package.json          - Node.js project configuration
# ├── ui-optimizer.js       - Node.js implementation
# ├── ui_optimizer.py       - Python implementation
# ├── verify_setup.sh       - Installation verification script
# └── README.md             - Documentation
#
# WHY $HOME/web-ui-optimizer?
# - Lives in user home directory (persists across container rebuilds)
# - Not part of workspace (won't clutter project repo)
# - Easy to access: cd ~/web-ui-optimizer
# - Optional: Can delete if not needed
# ==============================================================================
print_status "Creating web-ui-optimizer project..."
PROJECT_DIR="$HOME/web-ui-optimizer"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# ==============================================================================
# SECTION 6: PACKAGE.JSON GENERATION
# ==============================================================================
# Create package.json for the web-ui-optimizer project
#
# WHAT IS package.json?
# - Node.js project configuration file
# - Defines project metadata, scripts, and dependencies
# - Required for npm to manage packages
#
# KEY SECTIONS:
# 1. scripts: Convenient commands (npm run test, npm run optimize)
# 2. dependencies: Required packages with EXACT versions (no ^ or ~)
#
# NPM SCRIPTS EXPLAINED:
# - "test": Run Playwright tests
# - "test:ui": Run tests with interactive UI
# - "optimize": Run the Node.js optimizer tool
# - "optimize:py": Run the Python optimizer tool
# - "install-browsers": Manually install Chromium if needed
#
# VERSION PINNING:
# - "playwright": "1.48.1" (no ^ caret, exact version only)
# - Prevents automatic minor/patch updates
# - Ensures reproducible builds across team
#
# HEREDOC (<<'EOF'):
# - Multi-line string in bash
# - Single quotes prevent variable expansion
# - Content written exactly as-is to file
# ==============================================================================
print_status "Setting up Node.js project with Playwright..."
cat > "$PROJECT_DIR/package.json" << 'EOF'
{
  "name": "web-ui-optimizer",
  "version": "1.0.0",
  "description": "Web UI optimization toolkit with Playwright for Claude Code",
  "main": "ui-optimizer.js",
  "scripts": {
    "test": "npx playwright test",
    "test:ui": "npx playwright test --ui",
    "optimize": "node ui-optimizer.js",
    "optimize:py": "python ui_optimizer.py",
    "install-browsers": "npx playwright install chromium --with-deps"
  },
  "keywords": [
    "playwright",
    "testing",
    "ui",
    "optimization",
    "claude-code"
  ],
  "author": "",
  "license": "MIT",
  "dependencies": {
    "playwright": "1.56.1",
    "@playwright/test": "1.56.1"
  }
}
EOF

# ==============================================================================
# SECTION 7: PLAYWRIGHT PACKAGE INSTALLATION
# ==============================================================================
# Install Playwright packages from package.json
#
# WHAT HAPPENS:
# - Reads package.json dependencies
# - Downloads playwright and @playwright/test packages
# - Creates node_modules directory
# - Generates package-lock.json for reproducibility
#
# NOTE: node_modules is in a Docker volume
# - Mounted from Docker volume (see devcontainer.json mounts)
# - Much faster on macOS/Windows than bind mount
# - Not visible on host filesystem, but accessible in container
#
# TIME: 30-60 seconds
# SIZE: ~50MB (Playwright packages without browsers)
# ==============================================================================
print_status "Installing Playwright npm packages..."
npm install

# ==============================================================================
# SECTION 8: BROWSER BINARY INSTALLATION
# ==============================================================================
# Download and install Chromium browser binaries
#
# TWO INSTALLATIONS (Node.js AND Python):
# - Playwright has separate versions for Node.js and Python
# - Both need their own browser binaries
# - Browsers stored in: ~/.cache/ms-playwright/ (Docker volume)
# - Volume persists across container rebuilds (saves time)
#
# CHROMIUM ONLY (not Firefox or WebKit):
# - Chromium: ~150MB download
# - Firefox would add ~80MB
# - WebKit would add ~60MB
# - Using only Chromium saves time and space
#
# OPTIONS EXPLAINED:
# - --with-deps: Also install system dependencies (already done above)
# - chromium: Only install Chromium browser (not firefox/webkit)
#
# WHY TWO SEPARATE INSTALLS?
# - npx playwright install: For Node.js Playwright
# - python -m playwright install: For Python Playwright
# - They manage browsers separately
# - Both use same cache directory (no duplication)
#
# TIME: 2-5 minutes on first install (cached after that)
# SIZE: ~150MB per browser
# ==============================================================================
print_status "Installing Playwright browsers (Chromium only)..."
# Install Chromium for Node.js Playwright
npx playwright install chromium --with-deps

print_status "Installing Python Playwright browsers..."
# Install Chromium for Python Playwright
python -m playwright install chromium

# ==============================================================================
# SECTION 9: XVFB SETUP (VIRTUAL DISPLAY)
# ==============================================================================
# Start Xvfb (X Virtual Frame Buffer) for headless browser automation
#
# WHAT IS XVFB?
# - Virtual X11 display server that runs in memory
# - Allows GUI applications (browsers) to run without physical display
# - Chromium thinks it has a real display, but it's virtual
#
# WHY DO WE NEED IT?
# - Playwright/Chromium needs a display to render pages
# - Containers don't have physical displays
# - Xvfb provides virtual display so browsers can run headless
# - Required for screenshots, PDF generation, visual testing
#
# COMMAND OPTIONS EXPLAINED:
# - Xvfb: The X virtual framebuffer command
# - :99: Display number (arbitrary, 99 chosen to avoid conflicts)
# - -screen 0: Screen number within the display
# - 1920x1080x24: Resolution (width x height x color depth)
#   * 1920x1080: Full HD resolution
#   * 24: 24-bit color depth (16.7 million colors)
# - -nolisten tcp: Disable TCP connections (security)
# - -nolisten unix: Disable Unix socket connections (security)
# - &: Run in background (allows script to continue)
#
# DISPLAY ENVIRONMENT VARIABLE:
# - DISPLAY=:99: Tells applications which display to use
# - Export: Makes variable available to all processes
# - Added to ~/.bashrc: Persists across terminal sessions
#
# SECURITY NOTE:
# - -nolisten flags prevent remote connections to Xvfb
# - Only local processes in container can access display
# - No authentication configured (acceptable for dev containers)
#
# PERSISTENCE:
# - Xvfb starts on container creation
# - Runs continuously in background
# - If it crashes, need to restart manually: Xvfb :99 ... &
# ==============================================================================
print_status "Setting up Xvfb for headless display..."
# Start Xvfb in background for virtual display
Xvfb :99 -screen 0 1920x1080x24 -nolisten tcp -nolisten unix &
export DISPLAY=:99
echo "export DISPLAY=:99" >> ~/.bashrc

# ==============================================================================
# SECTION 10: GENERATE UI OPTIMIZER SCRIPTS
# ==============================================================================
# Create ready-to-use Playwright automation scripts in both Node.js and Python
#
# WHAT THESE SCRIPTS DO:
# - Capture responsive screenshots at different viewport sizes
# - Analyze color palettes used on webpages
# - Check accessibility issues (missing alt text, labels, etc.)
# - Measure page performance metrics
# - Compare before/after screenshots with CSS changes
# - Extract text content from pages
#
# TWO IMPLEMENTATIONS:
# 1. ui-optimizer.js: Node.js/JavaScript version
# 2. ui_optimizer.py: Python version
# - Same functionality in both languages
# - Choose based on your preference or project needs
#
# USAGE:
# - Node.js: node ui-optimizer.js https://example.com
# - Python: python ui_optimizer.py https://example.com
# - Both: Accept URL as command-line argument
# - Both: Generate screenshots, reports, and analysis
#
# SECURITY NOTES:
# - --no-sandbox flag used for Chromium (acceptable in dev containers)
# - Scripts accept URLs from command line (no validation yet)
# - Use only with trusted URLs in development environment
#
# FILES GENERATED:
# - Screenshots in ./screenshots/ directory
# - Comparison images in ./comparisons/ directory
# - Console output with analysis results
# ==============================================================================

# ------------------------------------------------------------------------------
# Node.js Implementation: ui-optimizer.js
# ------------------------------------------------------------------------------
# Full-featured Playwright automation class with multiple analysis methods
cat > "$PROJECT_DIR/ui-optimizer.js" << 'EOF'
const { chromium } = require('playwright');
const fs = require('fs').promises;
const path = require('path');

class UIOptimizer {
    constructor(options = {}) {
        this.browser = null;
        this.context = null;
        this.page = null;
        this.options = {
            headless: true,
            slowMo: options.slowMo || 0,
            ...options
        };
    }

    async initialize() {
        try {
            this.browser = await chromium.launch({
                headless: this.options.headless,
                args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage'],
                slowMo: this.options.slowMo
            });
            this.context = await this.browser.newContext({
                viewport: { width: 1920, height: 1080 }
            });
            this.page = await this.context.newPage();
            
            // Enable console logging from the page
            this.page.on('console', msg => console.log('PAGE LOG:', msg.text()));
        } catch (error) {
            console.error('Failed to initialize browser:', error);
            throw error;
        }
    }

    async captureResponsive(url, outputDir = './screenshots') {
        await fs.mkdir(outputDir, { recursive: true });
        
        const viewports = [
            { width: 375, height: 667, device: 'iPhone-SE' },
            { width: 768, height: 1024, device: 'iPad' },
            { width: 1366, height: 768, device: 'laptop' },
            { width: 1920, height: 1080, device: 'desktop' }
        ];

        const screenshots = [];
        
        for (const viewport of viewports) {
            await this.page.setViewportSize(viewport);
            await this.page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
            
            const filename = `${viewport.device}-${viewport.width}x${viewport.height}.png`;
            const filepath = path.join(outputDir, filename);
            
            await this.page.screenshot({ 
                path: filepath,
                fullPage: true 
            });
            
            screenshots.push({
                device: viewport.device,
                dimensions: `${viewport.width}x${viewport.height}`,
                path: filepath
            });
            
            console.log(`✅ Captured ${viewport.device} view`);
        }
        
        return screenshots;
    }

    async analyzeColors() {
        return await this.page.evaluate(() => {
            const elements = document.querySelectorAll('*');
            const colors = new Map();
            
            elements.forEach(el => {
                const style = window.getComputedStyle(el);
                if (style.color && style.color !== 'rgba(0, 0, 0, 0)') {
                    colors.set(style.color, (colors.get(style.color) || 0) + 1);
                }
                if (style.backgroundColor && style.backgroundColor !== 'rgba(0, 0, 0, 0)') {
                    colors.set(style.backgroundColor, (colors.get(style.backgroundColor) || 0) + 1);
                }
            });
            
            // Sort by frequency
            return Array.from(colors.entries())
                .sort((a, b) => b[1] - a[1])
                .map(([color, count]) => ({ color, count }));
        });
    }

    async checkAccessibility() {
        // Basic accessibility checks
        const results = await this.page.evaluate(() => {
            const checks = {
                imagesWithoutAlt: [],
                lowContrastElements: [],
                missingLabels: [],
                headingStructure: []
            };
            
            // Check images without alt text
            document.querySelectorAll('img').forEach(img => {
                if (!img.alt) {
                    checks.imagesWithoutAlt.push(img.src);
                }
            });
            
            // Check form inputs without labels
            document.querySelectorAll('input, select, textarea').forEach(input => {
                const id = input.id;
                if (id) {
                    const label = document.querySelector(`label[for="${id}"]`);
                    if (!label) {
                        checks.missingLabels.push({
                            type: input.type,
                            name: input.name || 'unnamed',
                            id: id
                        });
                    }
                }
            });
            
            // Check heading structure
            const headings = Array.from(document.querySelectorAll('h1, h2, h3, h4, h5, h6'));
            checks.headingStructure = headings.map(h => ({
                level: h.tagName,
                text: h.textContent.substring(0, 50)
            }));
            
            return checks;
        });
        
        return results;
    }

    async measurePerformance(url) {
        await this.page.goto(url, { waitUntil: 'networkidle' });
        
        const metrics = await this.page.evaluate(() => {
            const perfData = performance.getEntriesByType('navigation')[0];
            return {
                domContentLoaded: perfData.domContentLoadedEventEnd - perfData.domContentLoadedEventStart,
                loadComplete: perfData.loadEventEnd - perfData.loadEventStart,
                domInteractive: perfData.domInteractive,
                firstPaint: performance.getEntriesByType('paint')[0]?.startTime
            };
        });
        
        return metrics;
    }

    async injectCSS(css) {
        await this.page.addStyleTag({ content: css });
    }

    async compareBeforeAfter(url, cssChanges, outputDir = './comparisons') {
        await fs.mkdir(outputDir, { recursive: true });
        
        // Capture before
        await this.page.goto(url, { waitUntil: 'networkidle' });
        await this.page.screenshot({ 
            path: path.join(outputDir, 'before.png'),
            fullPage: true 
        });
        
        // Apply CSS and capture after
        await this.injectCSS(cssChanges);
        
        // Wait a moment for styles to apply
        await this.page.waitForTimeout(500);
        
        await this.page.screenshot({ 
            path: path.join(outputDir, 'after.png'),
            fullPage: true 
        });
        
        console.log('✅ Before/After comparison saved');
        
        return {
            before: path.join(outputDir, 'before.png'),
            after: path.join(outputDir, 'after.png')
        };
    }

    async extractText() {
        return await this.page.evaluate(() => {
            return document.body.innerText;
        });
    }

    async cleanup() {
        if (this.browser) {
            await this.browser.close();
        }
    }
}

// Export for use in other scripts
module.exports = UIOptimizer;

// CLI usage
if (require.main === module) {
    (async () => {
        const optimizer = new UIOptimizer();
        
        try {
            await optimizer.initialize();
            
            const url = process.argv[2] || 'https://example.com';
            console.log(`🔍 Analyzing ${url}...`);
            
            // Capture screenshots
            const screenshots = await optimizer.captureResponsive(url);
            console.log('\n📸 Screenshots captured:');
            screenshots.forEach(s => console.log(`  - ${s.device}: ${s.path}`));
            
            // Navigate to the page for analysis
            await optimizer.page.goto(url, { waitUntil: 'networkidle' });
            
            // Analyze colors
            const colors = await optimizer.analyzeColors();
            console.log('\n🎨 Top 5 colors found:');
            colors.slice(0, 5).forEach(({ color, count }) => 
                console.log(`  - ${color}: used ${count} times`)
            );
            
            // Check accessibility
            const accessibility = await optimizer.checkAccessibility();
            console.log('\n♿ Accessibility check:');
            console.log(`  - Images without alt text: ${accessibility.imagesWithoutAlt.length}`);
            console.log(`  - Form inputs without labels: ${accessibility.missingLabels.length}`);
            console.log(`  - Heading elements found: ${accessibility.headingStructure.length}`);
            
        } catch (error) {
            console.error('Error:', error.message);
            console.error('Stack:', error.stack);
        } finally {
            await optimizer.cleanup();
            console.log('\n✨ Analysis complete!');
        }
    })();
}
EOF

# Create Python version
cat > "$PROJECT_DIR/ui_optimizer.py" << 'EOF'
from playwright.sync_api import sync_playwright, Page
import os
import json
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from datetime import datetime


class UIOptimizer:
    """Web UI optimization and testing toolkit using Playwright."""
    
    def __init__(self, headless: bool = True):
        self.playwright = None
        self.browser = None
        self.context = None
        self.page = None
        self.headless = headless
    
    def initialize(self):
        """Initialize Playwright and browser."""
        self.playwright = sync_playwright().start()
        self.browser = self.playwright.chromium.launch(
            headless=self.headless,
            args=['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
        )
        self.context = self.browser.new_context(
            viewport={'width': 1920, 'height': 1080}
        )
        self.page = self.context.new_page()
        
        # Enable console logging
        self.page.on("console", lambda msg: print(f"PAGE LOG: {msg.text}"))
    
    def capture_responsive(self, url: str, output_dir: str = './screenshots') -> List[Dict]:
        """Capture screenshots at different viewport sizes."""
        Path(output_dir).mkdir(parents=True, exist_ok=True)
        
        viewports = [
            {'width': 375, 'height': 667, 'device': 'iPhone-SE'},
            {'width': 768, 'height': 1024, 'device': 'iPad'},
            {'width': 1366, 'height': 768, 'device': 'laptop'},
            {'width': 1920, 'height': 1080, 'device': 'desktop'}
        ]
        
        screenshots = []
        
        for viewport in viewports:
            self.page.set_viewport_size(
                width=viewport['width'], 
                height=viewport['height']
            )
            self.page.goto(url, wait_until='networkidle', timeout=30000)
            
            filename = f"{viewport['device']}-{viewport['width']}x{viewport['height']}.png"
            filepath = os.path.join(output_dir, filename)
            
            self.page.screenshot(path=filepath, full_page=True)
            screenshots.append({
                'device': viewport['device'],
                'dimensions': f"{viewport['width']}x{viewport['height']}",
                'path': filepath
            })
            
            print(f"✅ Captured {viewport['device']} view")
        
        return screenshots
    
    def analyze_colors(self) -> List[Dict[str, any]]:
        """Extract and analyze color palette from the current page."""
        colors = self.page.evaluate('''() => {
            const elements = document.querySelectorAll('*');
            const colorMap = new Map();
            
            elements.forEach(el => {
                const style = window.getComputedStyle(el);
                const color = style.color;
                const bgColor = style.backgroundColor;
                
                if (color && color !== 'rgba(0, 0, 0, 0)') {
                    colorMap.set(color, (colorMap.get(color) || 0) + 1);
                }
                if (bgColor && bgColor !== 'rgba(0, 0, 0, 0)') {
                    colorMap.set(bgColor, (colorMap.get(bgColor) || 0) + 1);
                }
            });
            
            return Array.from(colorMap.entries())
                .sort((a, b) => b[1] - a[1])
                .map(([color, count]) => ({ color, count }));
        }''')
        
        return colors
    
    def check_accessibility(self) -> Dict:
        """Perform basic accessibility checks."""
        results = self.page.evaluate('''() => {
            const checks = {
                images_without_alt: [],
                missing_labels: [],
                heading_structure: [],
                links_without_text: []
            };
            
            // Check images
            document.querySelectorAll('img').forEach(img => {
                if (!img.alt) {
                    checks.images_without_alt.push(img.src || 'inline-image');
                }
            });
            
            // Check form inputs
            document.querySelectorAll('input, select, textarea').forEach(input => {
                const id = input.id;
                const ariaLabel = input.getAttribute('aria-label');
                if (id && !document.querySelector(`label[for="${id}"]`) && !ariaLabel) {
                    checks.missing_labels.push({
                        type: input.type,
                        name: input.name || 'unnamed',
                        id: id
                    });
                }
            });
            
            // Check headings
            const headings = document.querySelectorAll('h1, h2, h3, h4, h5, h6');
            checks.heading_structure = Array.from(headings).map(h => ({
                level: h.tagName,
                text: h.textContent.substring(0, 50)
            }));
            
            // Check links
            document.querySelectorAll('a').forEach(link => {
                if (!link.textContent.trim() && !link.querySelector('img')) {
                    checks.links_without_text.push(link.href);
                }
            });
            
            return checks;
        }''')
        
        return results
    
    def measure_performance(self, url: str) -> Dict:
        """Measure page load performance metrics."""
        self.page.goto(url, timeout=30000)
        
        metrics = self.page.evaluate('''() => {
            const perfData = performance.getEntriesByType('navigation')[0];
            const paintEntries = performance.getEntriesByType('paint');
            
            return {
                domContentLoaded: perfData.domContentLoadedEventEnd - perfData.domContentLoadedEventStart,
                loadComplete: perfData.loadEventEnd - perfData.loadEventStart,
                domInteractive: perfData.domInteractive,
                responseTime: perfData.responseEnd - perfData.requestStart,
                firstPaint: paintEntries.find(e => e.name === 'first-paint')?.startTime,
                firstContentfulPaint: paintEntries.find(e => e.name === 'first-contentful-paint')?.startTime
            };
        }''')
        
        return metrics
    
    def compare_before_after(self, url: str, css_changes: str, output_dir: str = './comparisons') -> Dict[str, str]:
        """Capture before/after screenshots with CSS changes."""
        Path(output_dir).mkdir(parents=True, exist_ok=True)
        
        # Capture before
        self.page.goto(url, wait_until='networkidle')
        before_path = os.path.join(output_dir, 'before.png')
        self.page.screenshot(path=before_path, full_page=True)
        
        # Apply CSS changes
        self.page.add_style_tag(content=css_changes)
        self.page.wait_for_timeout(500)  # Wait for styles to apply
        
        # Capture after
        after_path = os.path.join(output_dir, 'after.png')
        self.page.screenshot(path=after_path, full_page=True)
        
        print('✅ Before/After comparison saved')
        
        return {
            'before': before_path,
            'after': after_path
        }
    
    def extract_text(self) -> str:
        """Extract all text content from the current page."""
        return self.page.evaluate('() => document.body.innerText')
    
    def cleanup(self):
        """Clean up resources."""
        if self.browser:
            self.browser.close()
        if self.playwright:
            self.playwright.stop()
    
    def __enter__(self):
        """Context manager entry."""
        self.initialize()
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit."""
        self.cleanup()


# Example usage and CLI interface
if __name__ == "__main__":
    import sys
    
    url = sys.argv[1] if len(sys.argv) > 1 else "https://example.com"
    
    print(f"🔍 Analyzing {url}...")
    
    with UIOptimizer() as optimizer:
        # Navigate to page
        optimizer.page.goto(url)
        
        # Capture screenshots
        screenshots = optimizer.capture_responsive(url)
        print(f"\n📸 Captured {len(screenshots)} responsive screenshots")
        
        # Analyze colors
        colors = optimizer.analyze_colors()
        print("\n🎨 Top 5 colors:")
        for item in colors[:5]:
            print(f"  - {item['color']}: used {item['count']} times")
        
        # Check accessibility
        accessibility = optimizer.check_accessibility()
        print(f"\n♿ Accessibility check:")
        print(f"  - Images without alt: {len(accessibility['images_without_alt'])}")
        print(f"  - Inputs without labels: {len(accessibility['missing_labels'])}")
        print(f"  - Headings found: {len(accessibility['heading_structure'])}")
        print(f"  - Links without text: {len(accessibility['links_without_text'])}")
        
        # Measure performance
        performance = optimizer.measure_performance(url)
        print(f"\n⚡ Performance metrics:")
        print(f"  - DOM Content Loaded: {performance.get('domContentLoaded', 'N/A')}ms")
        print(f"  - Page Load Complete: {performance.get('loadComplete', 'N/A')}ms")
        print(f"  - First Paint: {performance.get('firstPaint', 'N/A')}ms")
    
    print("\n✨ Analysis complete!")
EOF

# Create verification script
cat > "$PROJECT_DIR/verify_setup.sh" << 'EOF'
#!/bin/bash
echo "🔍 Verifying Playwright setup..."

# Check environment
echo "Environment checks:"
echo "  DISPLAY=$DISPLAY"
echo "  PLAYWRIGHT_BROWSERS_PATH=$PLAYWRIGHT_BROWSERS_PATH"
echo "  Node.js: $(node --version)"
echo "  Python: $(python --version)"

# Test Node.js version
echo -e "\n📦 Node.js Playwright test..."
node -e "
const { chromium } = require('playwright'); 
(async () => {
  try {
    const browser = await chromium.launch({ 
      headless: true, 
      args: ['--no-sandbox', '--disable-setuid-sandbox'] 
    });
    const page = await browser.newPage();
    await page.goto('https://example.com');
    const title = await page.title();
    console.log('✅ Node.js Playwright works! Page title:', title);
    await browser.close();
  } catch (error) {
    console.error('❌ Node.js Playwright error:', error.message);
    console.log('Try running: npx playwright install chromium');
  }
})();" || echo "Node.js test failed"

# Test Python version
echo -e "\n🐍 Python Playwright test..."
python -c "
from playwright.sync_api import sync_playwright
try:
    with sync_playwright() as p:
        browser = p.chromium.launch(
            headless=True, 
            args=['--no-sandbox', '--disable-setuid-sandbox']
        )
        page = browser.new_page()
        page.goto('https://example.com')
        title = page.title()
        print(f'✅ Python Playwright works! Page title: {title}')
        browser.close()
except Exception as e:
    print(f'❌ Python Playwright error: {e}')
    print('Try running: python -m playwright install chromium')
" || echo "Python test failed"

echo -e "\n🎭 Installed browsers:"
npx playwright --version
npx playwright show-report || true

echo -e "\n✨ Setup verification complete!"
EOF

chmod +x "$PROJECT_DIR/verify_setup.sh"

# Create usage documentation
cat > "$PROJECT_DIR/README.md" << 'EOF'
# Claude Code + Playwright Setup 🎭

## Quick Start

### 1. Verify Installation
```bash
cd ~/web-ui-optimizer
./verify_setup.sh
```

### 2. Basic Usage

**Node.js:**
```bash
node ui-optimizer.js https://example.com
```

**Python:**
```bash
python ui_optimizer.py https://example.com
```

### 3. With Claude Code

```bash
cd ~/web-ui-optimizer
claude-code
```

Then ask Claude Code to:
- "Test example.com and capture screenshots"
- "Check accessibility issues on my website"
- "Extract the color palette from a webpage"

## Troubleshooting

### Browser not found error

If you get browser not found errors, reinstall:

```bash
# For Node.js
npx playwright install chromium --with-deps

# For Python
python -m playwright install chromium
```

### Display issues

Make sure Xvfb is running:
```bash
export DISPLAY=:99
Xvfb :99 -screen 0 1920x1080x24 &
```

### Permission denied

The scripts already use `--no-sandbox` flag. If issues persist, check container permissions.

## Features

- 📸 Responsive screenshot capture
- 🎨 Color palette extraction
- ♿ Accessibility checking
- ⚡ Performance metrics
- 🔄 Before/after comparisons
- 📝 Text extraction
- 🧪 Form testing

## Examples

### Custom viewport testing
```javascript
const UIOptimizer = require('./ui-optimizer');
const optimizer = new UIOptimizer({ headless: false });
await optimizer.initialize();
// Your custom code here
await optimizer.cleanup();
```

### Python with context manager
```python
from ui_optimizer import UIOptimizer

with UIOptimizer(headless=False) as optimizer:
    optimizer.page.goto("https://example.com")
    # Your analysis here
```

## Docker Support 🐳

This environment includes Docker-outside-of-Docker (DooD) support, allowing you to build and test containers.

### Basic Docker Commands

```bash
# Verify Docker is working
docker --version
docker ps

# Build a Docker image
docker build -t myapp:latest .

# Run a container
docker run -d -p 8080:8080 myapp:latest

# Use Docker Compose
docker compose up
docker compose down

# View logs
docker logs <container-id>

# Execute commands in running container
docker exec -it <container-id> bash
```

### Testing Containerized Applications

```bash
# Build and test a Python app
docker build -f Dockerfile.python -t ml-model .
docker run -p 5000:5000 ml-model

# Build and test a Node.js app
docker build -f Dockerfile.node -t web-app .
docker run -p 3000:3000 web-app
```

### Security Notes

- This uses Docker-outside-of-Docker (DooD), not Docker-in-Docker
- Containers created are siblings to the devcontainer, not children
- The host Docker daemon is shared
- Do not use for untrusted workloads or malicious code testing
- Suitable for development and testing only

### Limitations

- Containers run on the host Docker daemon
- Resource limits apply to the host system
- Network configuration may differ from production environments
EOF

# Final setup message
echo ""
print_success "Setup complete! 🎉"
echo ""
echo "📁 Project location: $PROJECT_DIR"
echo "🧪 To verify: cd $PROJECT_DIR && ./verify_setup.sh"
echo "📖 Documentation: $PROJECT_DIR/README.md"
echo ""
echo "Quick test:"
echo "  cd $PROJECT_DIR"
echo "  node ui-optimizer.js https://example.com"
echo ""

# Run initial verification
print_status "Running initial verification..."
cd "$PROJECT_DIR"
./verify_setup.sh
