# Multi-Container Architecture Migration Plan

## Executive Summary

**Goal**: Transform the monolithic DevContainer into a modular multi-container setup with Playwright/browser automation in a separate service container, orchestrated via Docker Compose.

**Benefits**:
- ✅ **Separation of concerns** - Browser automation isolated from development environment
- ✅ **Faster rebuilds** - DevContainer smaller, Playwright service can be updated independently
- ✅ **Better resource management** - Can limit browser container resources separately
- ✅ **Scalability** - Can run multiple Playwright instances if needed
- ✅ **Cleaner development environment** - No browser dependencies in main container
- ✅ **Reusability** - Playwright service can be shared across multiple projects

---

## Current Architecture

```
┌─────────────────────────────────────────────────────────┐
│ DevContainer (Single Container)                         │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Python 3.12  │  │  Node.js 22  │  │   Jupyter    │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Playwright   │  │  Chromium    │  │   Xvfb :99   │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐                     │
│  │  Docker CLI  │  │  GitHub CLI  │                     │
│  └──────────────┘  └──────────────┘                     │
│                                                          │
│  Volume Mounts:                                          │
│  - /var/run/docker.sock (host Docker)                   │
│  - node_modules (volume)                                 │
│  - playwright-cache (volume)                             │
└─────────────────────────────────────────────────────────┘
```

---

## Proposed Architecture

```
Docker Compose Stack
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │ DevContainer Service (workspace)                           │   │
│  │                                                             │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │   │
│  │  │ Python 3.12  │  │  Node.js 22  │  │   Jupyter    │     │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘     │   │
│  │                                                             │   │
│  │  ┌──────────────┐  ┌──────────────┐                        │   │
│  │  │  Docker CLI  │  │  GitHub CLI  │                        │   │
│  │  └──────────────┘  └──────────────┘                        │   │
│  │                                                             │   │
│  │  ┌──────────────┐  ┌──────────────┐                        │   │
│  │  │ Playwright   │  │ Test Scripts │                        │   │
│  │  │ Client Lib   │  │              │                        │   │
│  │  └──────────────┘  └──────────────┘                        │   │
│  │                                                             │   │
│  │  Network: playwright-network                               │   │
│  │  Connects to: playwright:3000                              │   │
│  └────────────────────────────────────────────────────────────┘   │
│                                ↕                                    │
│                    playwright-network (bridge)                     │
│                                ↕                                    │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │ Playwright Service (playwright)                            │   │
│  │                                                             │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │   │
│  │  │ Playwright   │  │  Chromium    │  │   Xvfb :99   │     │   │
│  │  │   Server     │  │   Browser    │  │   Display    │     │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘     │   │
│  │                                                             │   │
│  │  ┌──────────────────────────────────────────────────┐     │   │
│  │  │ HTTP/WebSocket API (Port 3000)                   │     │   │
│  │  │ - Browser automation endpoints                   │     │   │
│  │  │ - Health check endpoint                          │     │   │
│  │  └──────────────────────────────────────────────────┘     │   │
│  │                                                             │   │
│  │  Network: playwright-network                               │   │
│  │  Exposed: 3000 (internal only)                             │   │
│  └────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Shared Volumes:                                                   │
│  - playwright-screenshots (test artifacts)                         │
│  - playwright-videos (test recordings)                             │
│  - playwright-traces (debugging data)                              │
│                                                                     │
│  Host Mounts:                                                      │
│  - /var/run/docker.sock → workspace container (DooD)              │
│  - ./project → workspace container                                 │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Detailed Component Design

### 1. DevContainer Service (`workspace`)

**Responsibilities**:
- Primary development environment
- Code editing, debugging
- Running Jupyter notebooks
- Running Python applications
- Git operations
- Docker operations (via DooD)
- Playwright client library (connects to remote service)

**Base Image**: `mcr.microsoft.com/devcontainers/python:3.12-bookworm`

**Installed Tools**:
- Python 3.12 + pip/uv
- Node.js 22
- Jupyter, JupyterLab, IPython
- GitHub CLI
- Docker CLI (DooD)
- Playwright client library (Python/Node)
- Development tools (black, pylint, pytest)

**NOT Installed** (moved to playwright service):
- ❌ Chromium browser
- ❌ Browser system dependencies
- ❌ Xvfb
- ❌ Playwright browsers

**Network Configuration**:
- Connected to `playwright-network`
- Can reach `playwright:3000`
- Environment variable: `PLAYWRIGHT_SERVICE_URL=http://playwright:3000`

**Volumes**:
- Workspace source code (bind mount)
- node_modules (named volume for performance)
- Shared test artifacts from Playwright service

---

### 2. Playwright Service (`playwright`)

**Responsibilities**:
- Running Chromium/Firefox/WebKit browsers
- Headless display management (Xvfb)
- Exposing browser automation API
- Storing test artifacts (screenshots, videos, traces)
- Health monitoring

**Base Image**: `mcr.microsoft.com/playwright:v1.55.0-jammy` (official Playwright image)

**Installed Tools**:
- Playwright with all browsers
- Chromium (primary)
- Xvfb virtual display
- Lightweight HTTP server for Playwright API
- Health check utilities

**Exposed API** (HTTP/WebSocket on port 3000):
```
GET  /health              - Health check
POST /browser/new         - Create new browser context
POST /browser/:id/close   - Close browser context
POST /navigate            - Navigate to URL
POST /screenshot          - Take screenshot
POST /evaluate            - Execute JavaScript
POST /accessibility       - Run accessibility tests
```

**Environment Variables**:
- `DISPLAY=:99`
- `PLAYWRIGHT_BROWSERS_PATH=/ms-playwright`
- `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=0`

**Volumes**:
- Browser cache (named volume, persists across restarts)
- Screenshots (shared with workspace)
- Videos (shared with workspace)
- Traces (shared with workspace)

**Resource Limits**:
```yaml
resources:
  limits:
    cpus: '2.0'
    memory: 2G
  reservations:
    cpus: '1.0'
    memory: 1G
```

**Health Check**:
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

---

### 3. Docker Compose Configuration

**File Structure**:
```
.devcontainer/
├── docker-compose.yml          # Main compose file
├── devcontainer.json           # Updated for compose
├── workspace/
│   ├── Dockerfile              # DevContainer image (minimal)
│   └── post-create.sh          # Setup script (no browser deps)
└── playwright/
    ├── Dockerfile              # Playwright service image
    ├── start-xvfb.sh           # Xvfb startup script
    ├── playwright-server.js    # HTTP API server
    └── healthcheck.sh          # Health check script
```

**Network Configuration**:
- Network name: `playwright-network`
- Driver: bridge
- Internal DNS: Containers can reach each other by service name

**Volume Strategy**:
```yaml
volumes:
  # Performance volumes (not visible on host)
  node_modules:
  playwright_browsers:

  # Shared data volumes
  playwright_screenshots:
  playwright_videos:
  playwright_traces:

  # Cache volumes
  uv_cache:
```

---

## Migration Path & Implementation Steps

### Phase 1: Planning & Setup (Preparation)

**Step 1.1: Create new directory structure**
```bash
mkdir -p .devcontainer/workspace
mkdir -p .devcontainer/playwright
mkdir -p tests/playwright
mkdir -p docs/architecture
```

**Step 1.2: Backup current configuration**
```bash
cp .devcontainer/devcontainer.json .devcontainer/devcontainer.json.backup
cp .devcontainer/post-create.sh .devcontainer/post-create.sh.backup
```

**Step 1.3: Create feature branch**
```bash
git checkout -b feature/multi-container-architecture
```

---

### Phase 2: Playwright Service Container

**Step 2.1: Create Playwright Dockerfile** (`.devcontainer/playwright/Dockerfile`)

```dockerfile
FROM mcr.microsoft.com/playwright:v1.55.0-jammy

# Install additional tools
RUN apt-get update && apt-get install -y \
    xvfb \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create directories for artifacts
RUN mkdir -p /artifacts/screenshots \
    /artifacts/videos \
    /artifacts/traces

# Copy server and startup scripts
COPY playwright-server.js /app/playwright-server.js
COPY start-xvfb.sh /app/start-xvfb.sh
COPY healthcheck.sh /app/healthcheck.sh

RUN chmod +x /app/start-xvfb.sh /app/healthcheck.sh

# Install server dependencies
WORKDIR /app
RUN npm init -y && \
    npm install express playwright cors

# Expose API port
EXPOSE 3000

# Set environment variables
ENV DISPLAY=:99
ENV PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# Start Xvfb and Playwright server
CMD ["/app/start-xvfb.sh"]
```

**Step 2.2: Create Xvfb startup script** (`.devcontainer/playwright/start-xvfb.sh`)

```bash
#!/bin/bash
set -e

echo "Starting Xvfb on display :99..."
Xvfb :99 -screen 0 1920x1080x24 -nolisten tcp -nolisten unix &
XVFB_PID=$!

# Wait for Xvfb to start
sleep 2

echo "Xvfb started (PID: $XVFB_PID)"
echo "Starting Playwright server..."

# Start Playwright server
node /app/playwright-server.js &
SERVER_PID=$!

# Wait for both processes
wait $XVFB_PID $SERVER_PID
```

**Step 2.3: Create Playwright HTTP server** (`.devcontainer/playwright/playwright-server.js`)

```javascript
const express = require('express');
const { chromium } = require('playwright');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

let browser = null;
const contexts = new Map();

// Initialize browser on startup
async function initBrowser() {
  browser = await chromium.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-dev-shm-usage']
  });
  console.log('Browser initialized');
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    browser: browser ? 'running' : 'stopped',
    contexts: contexts.size,
    timestamp: new Date().toISOString()
  });
});

// Create new browser context
app.post('/browser/new', async (req, res) => {
  try {
    const context = await browser.newContext(req.body.options || {});
    const page = await context.newPage();
    const contextId = Date.now().toString();
    contexts.set(contextId, { context, page });
    res.json({ contextId, status: 'created' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Navigate to URL
app.post('/navigate', async (req, res) => {
  const { contextId, url } = req.body;
  try {
    const { page } = contexts.get(contextId);
    await page.goto(url);
    res.json({ status: 'success', url });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Take screenshot
app.post('/screenshot', async (req, res) => {
  const { contextId, path, fullPage } = req.body;
  try {
    const { page } = contexts.get(contextId);
    const screenshot = await page.screenshot({
      path: `/artifacts/screenshots/${path}`,
      fullPage: fullPage || false
    });
    res.json({ status: 'success', path });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Close browser context
app.post('/browser/:id/close', async (req, res) => {
  const contextId = req.params.id;
  try {
    const { context } = contexts.get(contextId);
    await context.close();
    contexts.delete(contextId);
    res.json({ status: 'closed' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Start server
const PORT = 3000;
initBrowser().then(() => {
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Playwright server listening on port ${PORT}`);
  });
});

// Cleanup on exit
process.on('SIGTERM', async () => {
  console.log('Shutting down...');
  if (browser) await browser.close();
  process.exit(0);
});
```

**Step 2.4: Create health check script** (`.devcontainer/playwright/healthcheck.sh`)

```bash
#!/bin/bash
response=$(curl -sf http://localhost:3000/health)
if [ $? -eq 0 ]; then
  echo "Healthy: $response"
  exit 0
else
  echo "Unhealthy"
  exit 1
fi
```

---

### Phase 3: Docker Compose Configuration

**Step 3.1: Create docker-compose.yml** (`.devcontainer/docker-compose.yml`)

```yaml
version: '3.8'

services:
  # Main development workspace
  workspace:
    build:
      context: .
      dockerfile: workspace/Dockerfile

    container_name: claude-workspace

    volumes:
      # Bind mount for source code
      - ..:/workspaces/claude_in_devcontainer:cached

      # Docker socket for DooD
      - /var/run/docker.sock:/var/run/docker.sock

      # Performance volumes
      - node_modules:/workspaces/claude_in_devcontainer/node_modules
      - uv_cache:/home/vscode/.cache/uv

      # Shared volumes with playwright service
      - playwright_screenshots:/artifacts/screenshots
      - playwright_videos:/artifacts/videos
      - playwright_traces:/artifacts/traces

    environment:
      - PLAYWRIGHT_SERVICE_URL=http://playwright:3000
      - DISPLAY=:99

    networks:
      - playwright-network

    depends_on:
      playwright:
        condition: service_healthy

    # Keep container running
    command: sleep infinity

    # Resource requirements
    deploy:
      resources:
        limits:
          cpus: '4.0'
          memory: 8G
        reservations:
          cpus: '2.0'
          memory: 4G

  # Playwright browser automation service
  playwright:
    build:
      context: playwright
      dockerfile: Dockerfile

    container_name: claude-playwright

    volumes:
      # Browser cache (persists across restarts)
      - playwright_browsers:/ms-playwright

      # Shared artifact volumes
      - playwright_screenshots:/artifacts/screenshots
      - playwright_videos:/artifacts/videos
      - playwright_traces:/artifacts/traces

    environment:
      - DISPLAY=:99
      - PLAYWRIGHT_BROWSERS_PATH=/ms-playwright
      - PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=0

    networks:
      - playwright-network

    # Expose port only to internal network
    expose:
      - "3000"

    # Health check
    healthcheck:
      test: ["CMD", "/app/healthcheck.sh"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

    # Resource limits
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
        reservations:
          cpus: '1.0'
          memory: 1G

    # Shared memory for Chromium
    shm_size: '2gb'

networks:
  playwright-network:
    driver: bridge
    name: playwright-network

volumes:
  node_modules:
    name: claude-node-modules

  uv_cache:
    name: claude-uv-cache

  playwright_browsers:
    name: claude-playwright-browsers

  playwright_screenshots:
    name: claude-playwright-screenshots

  playwright_videos:
    name: claude-playwright-videos

  playwright_traces:
    name: claude-playwright-traces
```

---

### Phase 4: Update DevContainer Configuration

**Step 4.1: Create workspace Dockerfile** (`.devcontainer/workspace/Dockerfile`)

```dockerfile
FROM mcr.microsoft.com/devcontainers/python:3.12-bookworm

# Install Node.js is handled by devcontainer features
# Install minimal system dependencies (no browser dependencies!)
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:$PATH"

# Set working directory
WORKDIR /workspaces/claude_in_devcontainer

# Copy and run post-create script will happen via devcontainer.json
```

**Step 4.2: Update devcontainer.json** (`.devcontainer/devcontainer.json`)

```json
{
  "name": "Claude Code Multi-Container Environment",

  // Use docker-compose instead of single image
  "dockerComposeFile": "docker-compose.yml",

  // Which service to use as the development container
  "service": "workspace",

  // Workspace folder inside the container
  "workspaceFolder": "/workspaces/claude_in_devcontainer",

  // Features (Node.js, GitHub CLI, etc.)
  "features": {
    "ghcr.io/devcontainers/features/node:1": {
      "version": "22"
    },
    "ghcr.io/devcontainers/features/github-cli:1": {
      "version": "2.51.0"
    },
    "ghcr.io/devcontainers/features/docker-outside-of-docker:1": {}
  },

  // Post-create command
  "postCreateCommand": "bash .devcontainer/workspace/post-create.sh",

  // VS Code customizations
  "customizations": {
    "vscode": {
      "extensions": [
        "anthropic.claude-code",
        "ms-python.python",
        "ms-python.vscode-pylance",
        "ms-python.debugpy",
        "ms-toolsai.jupyter",
        "esbenp.prettier-vscode",
        "dbaeumer.vscode-eslint",
        "eamodio.gitlens",
        "usernamehw.errorlens",
        "ms-azuretools.vscode-docker",
        "streetsidesoftware.code-spell-checker",
        "christian-kohler.path-intellisense",
        "wayou.vscode-todo-highlight",
        "pkief.material-icon-theme",
        "ms-playwright.playwright"
      ],
      "settings": {
        "editor.formatOnSave": true,
        "editor.defaultFormatter": "esbenp.prettier-vscode",
        "[python]": {
          "editor.defaultFormatter": "ms-python.black-formatter"
        },
        "python.defaultInterpreterPath": "/home/vscode/.venv/bin/python",
        "python.linting.enabled": true,
        "python.linting.pylintEnabled": true
      }
    }
  },

  // User
  "remoteUser": "vscode",

  // Forward ports
  "forwardPorts": [3000, 3001, 4000, 5000, 8000, 8080],

  // Override command to keep container running
  "overrideCommand": true
}
```

**Step 4.3: Update post-create script** (`.devcontainer/workspace/post-create.sh`)

```bash
#!/bin/bash
set -e

echo "🚀 Setting up workspace (without browser dependencies)..."

# Install Python packages (no Playwright browsers!)
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.cargo/bin:$PATH"

# Create virtual environment
uv venv ~/.venv
source ~/.venv/bin/activate

# Install Python packages
uv pip install \
    playwright==1.55.0 \
    pytest==7.4.3 \
    black==23.12.1 \
    pylint==3.0.3 \
    jupyter>=1.1.1 \
    numpy==1.26.2 \
    pandas==2.3.3

# Activate venv on login
echo 'source ~/.venv/bin/activate' >> ~/.bashrc

# Create remote Playwright client wrapper
mkdir -p ~/web-ui-optimizer
cat > ~/web-ui-optimizer/remote_playwright.py << 'EOF'
import requests
import json

class RemotePlaywright:
    """Client for remote Playwright service"""

    def __init__(self, service_url="http://playwright:3000"):
        self.service_url = service_url
        self.context_id = None

    def health_check(self):
        response = requests.get(f"{self.service_url}/health")
        return response.json()

    def new_context(self, options=None):
        response = requests.post(
            f"{self.service_url}/browser/new",
            json={"options": options or {}}
        )
        data = response.json()
        self.context_id = data["contextId"]
        return self.context_id

    def navigate(self, url):
        response = requests.post(
            f"{self.service_url}/navigate",
            json={"contextId": self.context_id, "url": url}
        )
        return response.json()

    def screenshot(self, path, fullPage=False):
        response = requests.post(
            f"{self.service_url}/screenshot",
            json={
                "contextId": self.context_id,
                "path": path,
                "fullPage": fullPage
            }
        )
        return response.json()

    def close(self):
        if self.context_id:
            response = requests.post(
                f"{self.service_url}/browser/{self.context_id}/close"
            )
            return response.json()

# Example usage
if __name__ == "__main__":
    pw = RemotePlaywright()
    print("Health:", pw.health_check())
EOF

echo "✅ Workspace setup complete!"
echo "Playwright service available at: $PLAYWRIGHT_SERVICE_URL"
```

---

### Phase 5: Update Application Code

**Step 5.1: Create new Playwright client library** (`web-ui-optimizer/playwright_client.py`)

This is the wrapper that talks to the remote Playwright service.

**Step 5.2: Update existing ui_optimizer.py**

Modify to use remote service instead of local Playwright.

**Step 5.3: Create connection utilities** (`web-ui-optimizer/connection.py`)

```python
import requests
import time
import os

def wait_for_playwright_service(max_retries=30, delay=2):
    """Wait for Playwright service to be ready"""
    service_url = os.environ.get('PLAYWRIGHT_SERVICE_URL', 'http://playwright:3000')

    for i in range(max_retries):
        try:
            response = requests.get(f"{service_url}/health", timeout=5)
            if response.status_code == 200:
                print(f"✅ Playwright service ready: {response.json()}")
                return True
        except requests.exceptions.RequestException as e:
            print(f"⏳ Waiting for Playwright service... ({i+1}/{max_retries})")
            time.sleep(delay)

    raise Exception("Playwright service not available after max retries")
```

---

### Phase 6: Testing & Verification

**Step 6.1: Create verification script** (`tests/verify_multi_container.sh`)

```bash
#!/bin/bash
set -e

echo "🔍 Verifying multi-container setup..."

# Check Docker Compose services
echo "Checking Docker Compose services..."
docker-compose ps

# Check network
echo "Checking network connectivity..."
docker exec claude-workspace ping -c 2 playwright

# Check Playwright service health
echo "Checking Playwright service..."
docker exec claude-workspace curl -f http://playwright:3000/health

# Test browser automation
echo "Testing browser automation..."
docker exec claude-workspace python3 << 'EOF'
import sys
sys.path.append('/workspaces/claude_in_devcontainer/web-ui-optimizer')
from remote_playwright import RemotePlaywright

pw = RemotePlaywright()
print("Health check:", pw.health_check())
pw.new_context()
pw.navigate("https://example.com")
pw.screenshot("test.png", fullPage=True)
pw.close()
print("✅ Browser automation test passed!")
EOF

echo "✅ All verification checks passed!"
```

**Step 6.2: Create integration tests** (`tests/test_playwright_service.py`)

```python
import pytest
import requests
import os

SERVICE_URL = os.environ.get('PLAYWRIGHT_SERVICE_URL', 'http://playwright:3000')

def test_health_endpoint():
    response = requests.get(f"{SERVICE_URL}/health")
    assert response.status_code == 200
    data = response.json()
    assert data['status'] == 'healthy'

def test_browser_lifecycle():
    # Create context
    response = requests.post(f"{SERVICE_URL}/browser/new")
    assert response.status_code == 200
    context_id = response.json()['contextId']

    # Navigate
    response = requests.post(
        f"{SERVICE_URL}/navigate",
        json={"contextId": context_id, "url": "https://example.com"}
    )
    assert response.status_code == 200

    # Screenshot
    response = requests.post(
        f"{SERVICE_URL}/screenshot",
        json={"contextId": context_id, "path": "test.png", "fullPage": True}
    )
    assert response.status_code == 200

    # Close
    response = requests.post(f"{SERVICE_URL}/browser/{context_id}/close")
    assert response.status_code == 200
```

---

## Implementation Timeline

### Week 1: Foundation
- [ ] Create directory structure
- [ ] Create Playwright Dockerfile and scripts
- [ ] Create Playwright HTTP server
- [ ] Test Playwright service in isolation

### Week 2: Integration
- [ ] Create docker-compose.yml
- [ ] Update devcontainer.json for compose
- [ ] Update workspace Dockerfile
- [ ] Update post-create.sh

### Week 3: Code Migration
- [ ] Create Playwright client library
- [ ] Update ui_optimizer.py
- [ ] Create connection utilities
- [ ] Update all Playwright usage

### Week 4: Testing & Documentation
- [ ] Create verification scripts
- [ ] Write integration tests
- [ ] Update CLAUDE.md
- [ ] Update README.md
- [ ] Create migration guide

---

## Rollback Plan

If issues arise:

1. **Immediate rollback**: `git checkout main`
2. **Keep both**: Maintain old setup in `main`, new in `feature/multi-container`
3. **Hybrid approach**: Keep Playwright local but containerize other services

---

## Migration Checklist

### Pre-Migration
- [ ] Backup current configuration
- [ ] Document current setup
- [ ] Create feature branch
- [ ] Review architecture plan

### During Migration
- [ ] Create Playwright service container
- [ ] Create Docker Compose configuration
- [ ] Update DevContainer configuration
- [ ] Migrate application code
- [ ] Create client libraries

### Post-Migration
- [ ] Test all functionality
- [ ] Verify browser automation works
- [ ] Check resource usage
- [ ] Update documentation
- [ ] Get team approval

### Verification
- [ ] Both containers start successfully
- [ ] Network connectivity works
- [ ] Playwright service is accessible
- [ ] Browser automation tests pass
- [ ] Performance is acceptable
- [ ] Resource limits are respected

---

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| DevContainer doesn't support compose well | High | Test early, have rollback plan |
| Network issues between containers | Medium | Use Docker Compose DNS, test connectivity |
| Performance degradation | Medium | Monitor, adjust resource limits |
| Playwright API incomplete | High | Start with core features, iterate |
| Volume sharing issues | Low | Use Docker volumes, test thoroughly |
| Team adoption resistance | Medium | Document benefits, provide training |

---

## Success Criteria

✅ **Functional**:
- All containers start and communicate
- Browser automation works remotely
- All tests pass
- No functionality lost

✅ **Performance**:
- DevContainer rebuild < 2 minutes
- Playwright service startup < 30 seconds
- Browser automation latency < 500ms overhead

✅ **Operational**:
- Easy to start (`docker-compose up`)
- Easy to debug (clear logs)
- Easy to update individual services
- Clear documentation

---

## Next Steps

1. **Review this plan** - Get stakeholder approval
2. **Create POC** - Build minimal version to validate approach
3. **Iterate** - Refine based on POC learnings
4. **Full implementation** - Follow step-by-step plan
5. **Documentation** - Update all docs
6. **Training** - Help team adopt new architecture
