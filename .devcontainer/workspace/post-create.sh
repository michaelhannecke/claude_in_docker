#!/bin/bash
################################################################################
# WORKSPACE POST-CREATE SETUP SCRIPT
################################################################################
# This script runs ONCE after the workspace container is created
#
# Key Difference from Original:
# ✅ No browser dependencies (Chromium, Xvfb, system libs)
# ✅ No Playwright browser installation
# ✅ Much faster execution (~1 min vs ~5 min)
# ✅ Smaller container footprint
#
# What This Script Does:
# 1. Install uv (if not already present)
# 2. Create Python virtual environment
# 3. Install Python packages (no browser binaries!)
# 4. Configure shell
# 5. Create Playwright client utilities
# 6. Verify connectivity to Playwright service
#
# Playwright Service:
# - Runs in separate container
# - Accessed via http://playwright:3000
# - Browser automation happens there
################################################################################

set -e  # Exit on error

# ============================================================================
# COLOR OUTPUT
# ============================================================================
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

# ============================================================================
# ENVIRONMENT SETUP
# ============================================================================
# Node.js is installed globally in the Dockerfile
# So npm should be available in PATH by default
# Add common NVM paths as fallback for compatibility
export PATH="/usr/local/share/nvm/current/bin:$PATH"

# ============================================================================
# HEADER
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🚀 Workspace Setup (Multi-Container Mode)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================================================
# SECTION 1: INSTALL UV (FAST PYTHON PACKAGE MANAGER)
# ============================================================================
print_status "Installing uv package manager..."

# Check if uv is already installed
if command -v uv &> /dev/null; then
    print_success "uv already installed: $(uv --version)"
else
    # Install uv
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Add uv to PATH (installs to ~/.local/bin)
    export PATH="$HOME/.local/bin:$PATH"
    print_success "uv installed: $(uv --version)"
fi

# ============================================================================
# SECTION 2: FIX UV CACHE PERMISSIONS
# ============================================================================
print_status "Ensuring proper permissions for uv cache..."

# The uv cache directory can sometimes be created with wrong ownership
# (e.g., by root during previous container runs). Fix this proactively.
UV_CACHE_DIR="$HOME/.cache/uv"

if [ -d "$UV_CACHE_DIR" ]; then
    # Check if we can write to the cache directory
    if [ ! -w "$UV_CACHE_DIR" ]; then
        print_warning "UV cache has incorrect permissions"
        # Try to remove it, but don't fail if it's busy/mounted
        rm -rf "$UV_CACHE_DIR" 2>/dev/null || {
            # If removal fails (e.g., device busy), try to fix ownership instead
            print_warning "Cannot remove cache (device busy), attempting to fix ownership..."
            sudo chown -R vscode:vscode "$UV_CACHE_DIR" 2>/dev/null || true
        }
    fi
fi

# Ensure cache directory exists with correct ownership
mkdir -p "$UV_CACHE_DIR" 2>/dev/null || true
print_success "UV cache directory ready"

# ============================================================================
# SECTION 3: CREATE PYTHON VIRTUAL ENVIRONMENT
# ============================================================================
print_status "Creating Python virtual environment..."

# Use venv directory that's mounted as a Docker volume for persistence
VENV_PATH="$HOME/.venv"

# Fix permissions on venv directory (Docker volume may be created with wrong ownership)
if [ -d "$VENV_PATH" ]; then
    # Check if we can write to the venv directory
    if [ ! -w "$VENV_PATH" ]; then
        print_warning "VENV directory has incorrect permissions, fixing..."
        sudo chown -R vscode:vscode "$VENV_PATH" 2>/dev/null || true
        print_success "VENV permissions fixed"
    fi
fi

# Check if venv exists and is valid
if [ -d "$VENV_PATH" ] && [ -f "$VENV_PATH/bin/activate" ] && [ -x "$VENV_PATH/bin/python3" ]; then
    # Verify the Python interpreter is not a broken symlink
    if "$VENV_PATH/bin/python3" --version &> /dev/null; then
        print_warning "Virtual environment already exists at $VENV_PATH"
    else
        # Python interpreter is broken - recreate venv
        print_warning "Virtual environment has broken Python symlink, recreating..."
        sudo chown -R vscode:vscode "$VENV_PATH" 2>/dev/null || true
        rm -rf "$VENV_PATH"/* "$VENV_PATH"/.[!.]* 2>/dev/null || true
        uv venv "$VENV_PATH"
        print_success "Virtual environment recreated at $VENV_PATH"
    fi
elif [ -d "$VENV_PATH" ]; then
    # Directory exists but is corrupted - clear contents and recreate
    # NOTE: $VENV_PATH is a Docker volume mount point, so we can't remove the directory itself
    print_warning "Clearing corrupted virtual environment at $VENV_PATH"
    # Ensure we have write permissions first
    sudo chown -R vscode:vscode "$VENV_PATH" 2>/dev/null || true
    rm -rf "$VENV_PATH"/* "$VENV_PATH"/.[!.]* 2>/dev/null || true
    uv venv "$VENV_PATH"
    print_success "Virtual environment created at $VENV_PATH"
else
    # Create new venv directory with correct permissions
    mkdir -p "$VENV_PATH"
    sudo chown -R vscode:vscode "$VENV_PATH" 2>/dev/null || true
    uv venv "$VENV_PATH"
    print_success "Virtual environment created at $VENV_PATH"
fi

# Activate virtual environment
source "$VENV_PATH/bin/activate"

# ============================================================================
# SECTION 4: INSTALL PYTHON PACKAGES
# ============================================================================
print_status "Installing Python packages..."

# IMPORTANT: No Playwright browser binaries!
# - We install the playwright Python library (for client code)
# - But we DON'T install browsers (they're in the playwright service)
# - Set PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 to skip browser download

export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1

# Suppress uv hardlink warning in Docker environments
# (cache and venv are often on different filesystems)
export UV_LINK_MODE=copy

# Install packages with pinned versions (security)
uv pip install \
    playwright==1.55.0 \
    pytest==7.4.3 \
    pytest-playwright==0.7.1 \
    black==23.12.1 \
    pylint==3.0.3 \
    numpy==1.26.2 \
    pandas==2.3.3 \
    requests==2.31.0 \
    ipython==8.18.1

# Install Jupyter from pyproject.toml
print_status "Installing project dependencies..."
cd /workspaces/claude_in_devcontainer
uv pip install -e .

print_success "Python packages installed"

# ============================================================================
# SECTION 5: INSTALL CLAUDE CODE CLI
# ============================================================================
print_status "Installing Claude Code CLI..."

# Check if npm is available
if ! command -v npm &> /dev/null; then
    print_error "npm not found in PATH"
    print_warning "Skipping Claude Code CLI installation"
    print_warning "After container starts, you can install manually with:"
    print_warning "  sudo npm install -g @anthropic-ai/claude-code"
else
    print_success "npm is available: $(npm --version)"

    # Check if claude is already installed
    if command -v claude &> /dev/null; then
        print_success "Claude Code already installed: $(claude --version)"
    else
        # Install Claude Code globally via npm
        print_status "Installing @anthropic-ai/claude-code via npm..."
        sudo npm install -g @anthropic-ai/claude-code

        if command -v claude &> /dev/null; then
            print_success "Claude Code installed: $(claude --version)"
        else
            print_warning "Claude Code installation completed but 'claude' command not found"
        fi
    fi
fi

# ============================================================================
# SECTION 6: CONFIGURE SHELL
# ============================================================================
print_status "Configuring shell..."

# Add virtual environment activation to .bashrc
if ! grep -q "source $VENV_PATH/bin/activate" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Auto-activate Python virtual environment" >> ~/.bashrc
    echo "source $VENV_PATH/bin/activate" >> ~/.bashrc
    print_success "Added venv activation to .bashrc"
fi

# Add Playwright service URL to .bashrc
if ! grep -q "PLAYWRIGHT_SERVICE_URL" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Playwright service URL" >> ~/.bashrc
    echo "export PLAYWRIGHT_SERVICE_URL=http://playwright:3000" >> ~/.bashrc
    print_success "Added PLAYWRIGHT_SERVICE_URL to environment"
fi

# Add UV_LINK_MODE to .bashrc
if ! grep -q "UV_LINK_MODE" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Suppress uv hardlink warning (Docker/different filesystems)" >> ~/.bashrc
    echo "export UV_LINK_MODE=copy" >> ~/.bashrc
    print_success "Added UV_LINK_MODE to environment"
fi

# ============================================================================
# SECTION 7: CREATE PLAYWRIGHT CLIENT UTILITIES
# ============================================================================
print_status "Creating Playwright client utilities..."

# Create web-ui-optimizer directory if it doesn't exist
mkdir -p /workspaces/claude_in_devcontainer/web-ui-optimizer

# Create remote Playwright client library
cat > /workspaces/claude_in_devcontainer/web-ui-optimizer/remote_playwright.py << 'EOF'
"""
Remote Playwright Client
========================
Client library for interacting with the Playwright service container.

The Playwright service runs in a separate Docker container and exposes
an HTTP API for browser automation. This client provides a Python interface
to that API.

Usage:
    from remote_playwright import RemotePlaywright

    pw = RemotePlaywright()
    print(pw.health_check())

    pw.new_context()
    pw.navigate("https://example.com")
    pw.screenshot("output.png", full_page=True)
    pw.close()
"""

import os
import requests
from typing import Optional, Dict, Any


class RemotePlaywright:
    """Client for remote Playwright service"""

    def __init__(self, service_url: Optional[str] = None):
        """
        Initialize Playwright client

        Args:
            service_url: URL of Playwright service (default: from env or http://playwright:3000)
        """
        self.service_url = service_url or os.environ.get(
            'PLAYWRIGHT_SERVICE_URL',
            'http://playwright:3000'
        )
        self.context_id: Optional[str] = None

    def health_check(self) -> Dict[str, Any]:
        """
        Check service health

        Returns:
            Health status dictionary
        """
        response = requests.get(f"{self.service_url}/health")
        response.raise_for_status()
        return response.json()

    def new_context(self, options: Optional[Dict[str, Any]] = None) -> str:
        """
        Create new browser context

        Args:
            options: Browser context options (viewport, userAgent, etc.)

        Returns:
            Context ID
        """
        response = requests.post(
            f"{self.service_url}/browser/new",
            json={"options": options or {}}
        )
        response.raise_for_status()
        data = response.json()
        self.context_id = data["contextId"]
        return self.context_id

    def navigate(self, url: str, wait_until: str = "networkidle") -> Dict[str, Any]:
        """
        Navigate to URL

        Args:
            url: URL to navigate to
            wait_until: When to consider navigation complete

        Returns:
            Navigation result
        """
        if not self.context_id:
            raise ValueError("No active context. Call new_context() first.")

        response = requests.post(
            f"{self.service_url}/navigate",
            json={
                "contextId": self.context_id,
                "url": url,
                "waitUntil": wait_until
            }
        )
        response.raise_for_status()
        return response.json()

    def screenshot(
        self,
        path: str,
        full_page: bool = False,
        type: str = "png"
    ) -> Dict[str, Any]:
        """
        Take screenshot

        Args:
            path: Filename for screenshot
            full_page: Capture full scrollable page
            type: Image type (png, jpeg)

        Returns:
            Screenshot result
        """
        if not self.context_id:
            raise ValueError("No active context. Call new_context() first.")

        response = requests.post(
            f"{self.service_url}/screenshot",
            json={
                "contextId": self.context_id,
                "path": path,
                "fullPage": full_page,
                "type": type
            }
        )
        response.raise_for_status()
        return response.json()

    def evaluate(self, script: str) -> Dict[str, Any]:
        """
        Execute JavaScript in page context

        Args:
            script: JavaScript code to execute

        Returns:
            Evaluation result
        """
        if not self.context_id:
            raise ValueError("No active context. Call new_context() first.")

        response = requests.post(
            f"{self.service_url}/evaluate",
            json={
                "contextId": self.context_id,
                "script": script
            }
        )
        response.raise_for_status()
        return response.json()

    def close(self) -> Dict[str, Any]:
        """
        Close browser context

        Returns:
            Close result
        """
        if not self.context_id:
            raise ValueError("No active context to close.")

        response = requests.post(
            f"{self.service_url}/browser/{self.context_id}/close"
        )
        response.raise_for_status()
        result = response.json()

        self.context_id = None
        return result


if __name__ == "__main__":
    # Example usage
    pw = RemotePlaywright()
    print("Health check:", pw.health_check())
    print("\nTo use:")
    print("  pw = RemotePlaywright()")
    print("  pw.new_context()")
    print("  pw.navigate('https://example.com')")
    print("  pw.screenshot('example.png', full_page=True)")
    print("  pw.close()")
EOF

chmod +x /workspaces/claude_in_devcontainer/web-ui-optimizer/remote_playwright.py
print_success "Created remote_playwright.py"

# Create connection utilities
cat > /workspaces/claude_in_devcontainer/web-ui-optimizer/connection.py << 'EOF'
"""
Playwright Service Connection Utilities
=======================================
Helper functions for connecting to the Playwright service.
"""

import os
import time
import requests
from typing import Optional


def wait_for_playwright_service(
    max_retries: int = 30,
    delay: int = 2,
    service_url: Optional[str] = None
) -> bool:
    """
    Wait for Playwright service to be ready

    Args:
        max_retries: Maximum number of retry attempts
        delay: Seconds to wait between retries
        service_url: URL of service (default: from env)

    Returns:
        True if service is ready, raises Exception otherwise
    """
    url = service_url or os.environ.get(
        'PLAYWRIGHT_SERVICE_URL',
        'http://playwright:3000'
    )

    print(f"Waiting for Playwright service at {url}...")

    for i in range(max_retries):
        try:
            response = requests.get(f"{url}/health", timeout=5)
            if response.status_code == 200:
                data = response.json()
                print(f"✅ Playwright service ready!")
                print(f"   Status: {data.get('status')}")
                print(f"   Browser: {data.get('browser', {}).get('version')}")
                return True
        except requests.exceptions.RequestException as e:
            print(f"⏳ Waiting for Playwright service... ({i+1}/{max_retries})")
            time.sleep(delay)

    raise Exception(f"Playwright service not available after {max_retries} attempts")


if __name__ == "__main__":
    wait_for_playwright_service()
EOF

chmod +x /workspaces/claude_in_devcontainer/web-ui-optimizer/connection.py
print_success "Created connection.py"

# ============================================================================
# SECTION 8: VERIFY PLAYWRIGHT SERVICE CONNECTIVITY
# ============================================================================
print_status "Verifying Playwright service connectivity..."

# Wait a moment for playwright service to be ready
sleep 5

# Try to connect to Playwright service
if curl -sf http://playwright:3000/health > /dev/null 2>&1; then
    print_success "Successfully connected to Playwright service!"
    curl -s http://playwright:3000/health | python3 -m json.tool
else
    print_warning "Playwright service not yet ready (this is OK during initial setup)"
    print_warning "The service will be available once both containers are running"
fi

# ============================================================================
# SECTION 9: SUMMARY
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "Workspace Setup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
print_status "Environment:"
echo "  • Python: $(python --version)"
echo "  • Node.js: $(node --version 2>/dev/null || echo 'not found')"
echo "  • npm: $(npm --version 2>/dev/null || echo 'not found')"
echo "  • Claude Code: $(claude --version 2>/dev/null || echo 'not installed')"
echo "  • Virtual env: $VENV_PATH"
echo "  • Playwright service: \$PLAYWRIGHT_SERVICE_URL"
echo ""
print_status "Next steps:"
echo "  1. Test connectivity: curl http://playwright:3000/health"
echo "  2. Try client: python web-ui-optimizer/remote_playwright.py"
echo "  3. Start developing!"
echo ""
print_status "Key differences from monolithic setup:"
echo "  ✅ No browser dependencies in this container"
echo "  ✅ Faster rebuilds (~1 min vs ~5 min)"
echo "  ✅ Browser automation via http://playwright:3000"
echo "  ✅ Cleaner development environment"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
