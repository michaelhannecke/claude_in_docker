# Multi-Container Architecture - Implementation Steps

Quick reference guide for implementing the multi-container architecture. See `ARCHITECTURE_PLAN.md` for detailed design decisions.

## Quick Start

```bash
# 1. Create feature branch
git checkout -b feature/multi-container-architecture

# 2. Create directory structure
mkdir -p .devcontainer/workspace
mkdir -p .devcontainer/playwright
mkdir -p tests/playwright

# 3. Follow steps below in order
```

---

## Step-by-Step Implementation

### Step 1: Create Playwright Service Files

**1.1 Create `.devcontainer/playwright/Dockerfile`**
- Base image: `mcr.microsoft.com/playwright:v1.55.0-jammy`
- Install: xvfb, curl, Node.js dependencies
- Copy server scripts
- Expose port 3000

**1.2 Create `.devcontainer/playwright/playwright-server.js`**
- Express HTTP server
- Endpoints: /health, /browser/new, /navigate, /screenshot, /browser/:id/close
- Manage browser contexts
- Save artifacts to /artifacts/

**1.3 Create `.devcontainer/playwright/start-xvfb.sh`**
- Start Xvfb on display :99
- Start Playwright server
- Wait for both processes

**1.4 Create `.devcontainer/playwright/healthcheck.sh`**
- Curl http://localhost:3000/health
- Exit 0 if healthy, 1 otherwise

---

### Step 2: Create Docker Compose Configuration

**2.1 Create `.devcontainer/docker-compose.yml`**

```yaml
version: '3.8'

services:
  workspace:
    build:
      context: .
      dockerfile: workspace/Dockerfile
    volumes:
      - ..:/workspaces/claude_in_devcontainer:cached
      - /var/run/docker.sock:/var/run/docker.sock
      - node_modules:/workspaces/claude_in_devcontainer/node_modules
      - playwright_screenshots:/artifacts/screenshots
    environment:
      - PLAYWRIGHT_SERVICE_URL=http://playwright:3000
    networks:
      - playwright-network
    depends_on:
      playwright:
        condition: service_healthy
    command: sleep infinity

  playwright:
    build:
      context: playwright
      dockerfile: Dockerfile
    volumes:
      - playwright_browsers:/ms-playwright
      - playwright_screenshots:/artifacts/screenshots
    environment:
      - DISPLAY=:99
    networks:
      - playwright-network
    expose:
      - "3000"
    healthcheck:
      test: ["CMD", "/app/healthcheck.sh"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    shm_size: '2gb'

networks:
  playwright-network:
    driver: bridge

volumes:
  node_modules:
  playwright_browsers:
  playwright_screenshots:
```

---

### Step 3: Update DevContainer Configuration

**3.1 Create `.devcontainer/workspace/Dockerfile`**
- Base: `mcr.microsoft.com/devcontainers/python:3.12-bookworm`
- Install: curl, wget, git, uv
- NO browser dependencies!

**3.2 Update `.devcontainer/devcontainer.json`**

Key changes:
```json
{
  "dockerComposeFile": "docker-compose.yml",
  "service": "workspace",
  "workspaceFolder": "/workspaces/claude_in_devcontainer",
  // Remove browser-related runArgs
  // Keep features: node, github-cli, docker-outside-of-docker
  "overrideCommand": true
}
```

**3.3 Update `.devcontainer/workspace/post-create.sh`**
- Remove browser installation steps
- Remove Xvfb setup
- Keep: Python packages, Jupyter, development tools
- Add: Remote Playwright client setup

---

### Step 4: Create Playwright Client Library

**4.1 Create `web-ui-optimizer/remote_playwright.py`**

```python
import requests

class RemotePlaywright:
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
        self.context_id = response.json()["contextId"]
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
        response = requests.post(
            f"{self.service_url}/browser/{self.context_id}/close"
        )
        return response.json()
```

**4.2 Create `web-ui-optimizer/connection.py`**

```python
import requests
import time
import os

def wait_for_playwright_service(max_retries=30, delay=2):
    service_url = os.environ.get('PLAYWRIGHT_SERVICE_URL', 'http://playwright:3000')

    for i in range(max_retries):
        try:
            response = requests.get(f"{service_url}/health", timeout=5)
            if response.status_code == 200:
                print(f"✅ Playwright service ready")
                return True
        except:
            print(f"⏳ Waiting for Playwright ({i+1}/{max_retries})...")
            time.sleep(delay)

    raise Exception("Playwright service not available")
```

---

### Step 5: Update Existing Code

**5.1 Update `web-ui-optimizer/ui_optimizer.py`**

Before:
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    # ...
```

After:
```python
from remote_playwright import RemotePlaywright
from connection import wait_for_playwright_service

wait_for_playwright_service()
pw = RemotePlaywright()
pw.new_context()
pw.navigate("https://example.com")
pw.screenshot("output.png", fullPage=True)
pw.close()
```

---

### Step 6: Testing

**6.1 Create `tests/verify_multi_container.sh`**

```bash
#!/bin/bash
set -e

echo "🔍 Verifying setup..."

# Check services running
docker-compose ps

# Check network
docker exec claude-workspace ping -c 2 playwright

# Check Playwright health
docker exec claude-workspace curl -f http://playwright:3000/health

# Test automation
docker exec claude-workspace python3 /workspaces/claude_in_devcontainer/tests/test_remote_playwright.py

echo "✅ All checks passed!"
```

**6.2 Create `tests/test_remote_playwright.py`**

```python
from web_ui_optimizer.remote_playwright import RemotePlaywright
from web_ui_optimizer.connection import wait_for_playwright_service

def test_playwright_service():
    wait_for_playwright_service()

    pw = RemotePlaywright()

    # Health check
    health = pw.health_check()
    assert health['status'] == 'healthy'

    # Create context
    context_id = pw.new_context()
    assert context_id is not None

    # Navigate
    result = pw.navigate("https://example.com")
    assert result['status'] == 'success'

    # Screenshot
    result = pw.screenshot("test.png", fullPage=True)
    assert result['status'] == 'success'

    # Close
    result = pw.close()
    assert result['status'] == 'closed'

    print("✅ All Playwright tests passed!")

if __name__ == "__main__":
    test_playwright_service()
```

---

### Step 7: Build and Start

**7.1 Build containers**
```bash
cd .devcontainer
docker-compose build
```

**7.2 Start services**
```bash
docker-compose up -d
```

**7.3 Check status**
```bash
docker-compose ps
docker-compose logs playwright
docker-compose logs workspace
```

**7.4 Open in VS Code**
- Command Palette: "Dev Containers: Reopen in Container"
- VS Code will detect docker-compose.yml
- Select "workspace" service

---

### Step 8: Verification

**Inside workspace container:**

```bash
# Check environment
echo $PLAYWRIGHT_SERVICE_URL

# Check connectivity
ping -c 2 playwright
curl http://playwright:3000/health

# Test Python client
cd /workspaces/claude_in_devcontainer
python tests/test_remote_playwright.py

# Run verification script
bash tests/verify_multi_container.sh
```

---

## Common Issues & Solutions

### Issue: Containers won't start
```bash
# Check logs
docker-compose logs

# Rebuild
docker-compose down
docker-compose build --no-cache
docker-compose up
```

### Issue: Network connectivity fails
```bash
# Check network
docker network ls
docker network inspect playwright-network

# Check DNS
docker exec claude-workspace nslookup playwright
```

### Issue: Playwright service unhealthy
```bash
# Check logs
docker-compose logs playwright

# Check Xvfb
docker exec claude-playwright ps aux | grep Xvfb

# Manual health check
docker exec claude-playwright curl http://localhost:3000/health
```

### Issue: DevContainer won't connect
- Ensure docker-compose.yml is in `.devcontainer/`
- Check `dockerComposeFile` path in devcontainer.json
- Try: "Dev Containers: Rebuild Container"

---

## File Checklist

Before testing, ensure these files exist:

```
.devcontainer/
├── docker-compose.yml              ✓
├── devcontainer.json               ✓ (updated)
├── workspace/
│   ├── Dockerfile                  ✓
│   └── post-create.sh              ✓ (updated)
└── playwright/
    ├── Dockerfile                  ✓
    ├── playwright-server.js        ✓
    ├── start-xvfb.sh               ✓
    └── healthcheck.sh              ✓

web-ui-optimizer/
├── remote_playwright.py            ✓
├── connection.py                   ✓
└── ui_optimizer.py                 ✓ (updated)

tests/
├── verify_multi_container.sh       ✓
└── test_remote_playwright.py       ✓
```

---

## Rollback Instructions

If you need to revert:

```bash
# Stop new containers
cd .devcontainer
docker-compose down

# Restore backup files
cp devcontainer.json.backup devcontainer.json
cp post-create.sh.backup post-create.sh

# Return to main branch
git checkout main

# Rebuild original container
# In VS Code: "Dev Containers: Rebuild Container"
```

---

## Performance Optimization

**After successful migration:**

1. **Adjust resource limits** in docker-compose.yml
2. **Monitor container stats**: `docker stats`
3. **Optimize Playwright service**: Add caching, connection pooling
4. **Use Docker BuildKit**: `export DOCKER_BUILDKIT=1`
5. **Pre-pull images**: `docker-compose pull`

---

## Next Steps After Implementation

1. **Update CLAUDE.md** with new architecture
2. **Update README.md** with Docker Compose instructions
3. **Create migration guide** for team members
4. **Add CI/CD integration** for multi-container testing
5. **Monitor and optimize** based on usage patterns
6. **Document learnings** for future improvements
