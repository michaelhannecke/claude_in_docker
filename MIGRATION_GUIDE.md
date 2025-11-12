# Migration Guide: v2.0 → v3.0 Multi-Container Architecture

**Upgrading from single-container to multi-container DevContainer**

---

## 📋 Table of Contents

- [Overview](#-overview)
- [What's Changing](#-whats-changing)
- [Pre-Migration Checklist](#-pre-migration-checklist)
- [Migration Steps](#-migration-steps)
- [Code Migration](#-code-migration)
- [Verification](#-verification)
- [Troubleshooting](#-troubleshooting)
- [Rollback Procedure](#-rollback-procedure)
- [FAQ](#-faq)

---

## 🎯 Overview

This guide helps you migrate from **v2.0 (single-container)** to **v3.0 (multi-container architecture)**.

### What's v2.0?

- Single DevContainer with everything included
- Playwright + browsers installed locally
- Xvfb running in the same container
- Virtual environment at `.venv`

### What's v3.0?

- Multi-container setup with Docker Compose
- Playwright service in separate container
- HTTP API for remote browser automation
- Virtual environment at `~/.venv`
- Cleaner workspace (~450MB smaller)

### Migration Time

- **Estimated time**: 15-30 minutes
- **Difficulty**: Moderate
- **Downtime**: Container rebuild required (~5-10 minutes)

---

## 🔄 What's Changing

### Architecture Changes

| Component | v2.0 (Old) | v3.0 (New) |
|-----------|------------|------------|
| **Container count** | 1 (monolithic) | 2 (workspace + playwright) |
| **Playwright** | Local installation | Remote HTTP service |
| **Browsers** | In workspace | In playwright service |
| **Xvfb** | In workspace | In playwright service |
| **Virtual env** | `.venv` (project) | `~/.venv` (user home) |
| **Container size** | ~1.2GB | ~750MB (workspace) |

### File Structure Changes

**Files Added:**
```
.devcontainer/
├── docker-compose.yml                  # NEW - Multi-container orchestration
├── workspace/                          # NEW - Workspace service config
│   ├── Dockerfile
│   └── post-create.sh
└── playwright/                         # NEW - Playwright service
    ├── Dockerfile
    ├── playwright-server.js
    ├── start-xvfb.sh
    └── healthcheck.sh

web-ui-optimizer/
├── __init__.py                         # NEW - Package exports
├── remote_playwright.py                # NEW - HTTP client library
├── connection.py                       # NEW - Connection utilities
└── ui_optimizer.py                     # MODIFIED - Uses remote service

examples/
├── README.md                           # NEW - Examples documentation
├── 01_basic_screenshot.py              # NEW
├── 02_context_manager.py               # NEW
└── 03_ui_optimizer_full.py             # NEW
```

**Files Modified:**
```
.devcontainer/devcontainer.json         # Updated for Docker Compose
web-ui-optimizer/ui_optimizer.py        # Rewritten for remote service
```

**Files Removed/Deprecated:**
- None (backward compatible)

### Code Changes Required

**If you're using UIOptimizer** → ✅ No changes needed (backward compatible)

**If you're using Playwright directly** → ⚠️ Migration required

---

## ✅ Pre-Migration Checklist

### 1. Requirements Check

Verify you have the required software:

```bash
# Docker Desktop
docker --version        # Should be 20.10+
docker-compose --version # Should be 1.29+

# VS Code
code --version          # Should be 1.80+

# Dev Containers extension
code --list-extensions | grep ms-vscode-remote.remote-containers
```

### 2. System Resources

Ensure sufficient resources:

- **CPUs**: 4+ cores (6-8 recommended)
- **Memory**: 8GB minimum (12-16GB recommended)
- **Disk Space**: 10GB free minimum

```bash
# Check available disk space
df -h

# Check Docker resources
docker system df
```

### 3. Backup Current Work

**Save your work:**

```bash
# 1. Commit any uncommitted changes
git status
git add .
git commit -m "Save work before migration"

# 2. Create a backup branch
git branch backup-v2.0-$(date +%Y%m%d)

# 3. Push to remote (optional but recommended)
git push origin backup-v2.0-$(date +%Y%m%d)
```

**Backup custom Playwright code:**

```bash
# If you have custom Playwright scripts
mkdir -p ~/migration-backup
cp -r web-ui-optimizer ~/migration-backup/
cp -r scripts ~/migration-backup/  # If you have custom scripts
```

### 4. Stop Current Container

```bash
# From VS Code:
# Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
# → "Dev Containers: Reopen Folder Locally"

# OR manually stop container
docker ps  # Find container ID
docker stop <container-id>
```

---

## 🚀 Migration Steps

### Step 1: Pull Latest Changes

```bash
# Ensure you're on main branch
git checkout main

# Pull latest changes
git pull origin main

# You should see new files:
# - .devcontainer/docker-compose.yml
# - .devcontainer/workspace/
# - .devcontainer/playwright/
# - web-ui-optimizer/remote_playwright.py
# - examples/
```

### Step 2: Review Changes (Optional)

```bash
# See what changed
git log --oneline -10

# Review specific changes
git diff HEAD~5 .devcontainer/devcontainer.json
git diff HEAD~5 web-ui-optimizer/ui_optimizer.py
```

### Step 3: Clean Up Old Container

```bash
# Remove old DevContainer
docker ps -a | grep claude
docker rm -f <old-container-name>

# Clean up old volumes (optional - will rebuild from scratch)
docker volume prune
```

### Step 4: Rebuild Multi-Container Environment

**In VS Code:**

1. Open the project folder
2. Command Palette: `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (Mac)
3. Select: **"Dev Containers: Rebuild and Reopen in Container"**
4. Wait 5-10 minutes for first build

**What happens:**
- Docker Compose builds both services
- Workspace service: Installs Python packages
- Playwright service: Downloads Chromium (~150MB)
- Services start in correct order (playwright first, then workspace)

### Step 5: Verify Services

Once container is ready:

```bash
# Check services are running
docker-compose ps

# Should show:
# NAME                  STATUS        PORTS
# claude-workspace      Up
# claude-playwright     Up (healthy)

# Check Playwright service health
docker exec claude-workspace curl http://playwright:3000/health
```

### Step 6: Update Environment Variables

The virtual environment location changed:

```bash
# OLD (v2.0): Project-level venv
source .venv/bin/activate

# NEW (v3.0): User-level venv
source ~/.venv/bin/activate

# This is already set in ~/.bashrc, so new terminals auto-activate
```

### Step 7: Test Installation

```bash
# Activate virtual environment (should auto-activate in new terminal)
source ~/.venv/bin/activate

# Test Python
python --version

# Test Jupyter
jupyter --version

# Test Playwright service connection
python -c "from web_ui_optimizer import wait_for_playwright_service; wait_for_playwright_service()"

# Run example script
python examples/01_basic_screenshot.py
```

---

## 💻 Code Migration

### If You're Using UIOptimizer → No Changes Needed! ✅

The UIOptimizer API is **backward compatible**:

```python
# This code works in both v2.0 and v3.0
from web_ui_optimizer import UIOptimizer

with UIOptimizer() as optimizer:
    screenshots = optimizer.capture_responsive("https://example.com")
    colors = optimizer.analyze_colors()
    a11y = optimizer.check_accessibility()
```

**No migration required!** The implementation changed (local → remote), but the interface stayed the same.

---

### If You're Using Playwright Directly → Migration Required ⚠️

#### Before (v2.0): Local Playwright

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto("https://example.com")
    page.screenshot(path="screenshot.png")
    browser.close()
```

#### After (v3.0): Remote Playwright

```python
from web_ui_optimizer import RemotePlaywright, wait_for_playwright_service

# Wait for service
wait_for_playwright_service()

# Use remote Playwright
with RemotePlaywright() as pw:
    pw.new_context()
    pw.navigate("https://example.com")
    pw.screenshot("screenshot.png", full_page=True)
```

---

### Migration Examples

#### Example 1: Simple Screenshot

**v2.0 (Local):**
```python
from playwright.sync_api import sync_playwright

def take_screenshot(url, output_path):
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        page.goto(url)
        page.screenshot(path=output_path)
        browser.close()

take_screenshot("https://example.com", "output.png")
```

**v3.0 (Remote):**
```python
from web_ui_optimizer import RemotePlaywright, wait_for_playwright_service

def take_screenshot(url, output_path):
    wait_for_playwright_service()

    with RemotePlaywright() as pw:
        pw.new_context()
        pw.navigate(url)
        pw.screenshot(output_path, full_page=True)

take_screenshot("https://example.com", "output.png")
```

---

#### Example 2: Custom Viewport

**v2.0 (Local):**
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch()
    context = browser.new_context(
        viewport={'width': 1920, 'height': 1080}
    )
    page = context.new_page()
    page.goto("https://example.com")
    page.screenshot(path="desktop.png")
    browser.close()
```

**v3.0 (Remote):**
```python
from web_ui_optimizer import RemotePlaywright

with RemotePlaywright() as pw:
    pw.new_context(options={
        "viewport": {"width": 1920, "height": 1080}
    })
    pw.navigate("https://example.com")
    pw.screenshot("desktop.png")
```

---

#### Example 3: JavaScript Evaluation

**v2.0 (Local):**
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    page.goto("https://example.com")

    title = page.evaluate("() => document.title")
    links = page.evaluate("() => document.querySelectorAll('a').length")

    print(f"Title: {title}")
    print(f"Links: {links}")
    browser.close()
```

**v3.0 (Remote):**
```python
from web_ui_optimizer import RemotePlaywright

with RemotePlaywright() as pw:
    pw.new_context()
    pw.navigate("https://example.com")

    title = pw.evaluate("() => document.title")
    links = pw.evaluate("() => document.querySelectorAll('a').length")

    print(f"Title: {title['result']}")
    print(f"Links: {links['result']}")
```

**Note:** Remote Playwright returns `{'result': value}` format.

---

#### Example 4: PDF Generation

**v2.0 (Local):**
```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    page.goto("https://example.com")
    page.pdf(path="output.pdf", format="A4")
    browser.close()
```

**v3.0 (Remote):**
```python
from web_ui_optimizer import RemotePlaywright

with RemotePlaywright() as pw:
    pw.new_context()
    pw.navigate("https://example.com")
    pw.pdf("output.pdf", format="A4")
```

---

### API Mapping Reference

| v2.0 (Local Playwright) | v3.0 (Remote Playwright) |
|-------------------------|--------------------------|
| `p.chromium.launch()` | `RemotePlaywright()` |
| `browser.new_context(options)` | `pw.new_context(options)` |
| `page.goto(url)` | `pw.navigate(url)` |
| `page.screenshot(path)` | `pw.screenshot(path)` |
| `page.evaluate(script)` | `pw.evaluate(script)` |
| `page.pdf(path)` | `pw.pdf(path)` |
| `browser.close()` | `pw.close()` (or use context manager) |

---

### Screenshot File Locations

**Important:** Screenshots are saved in the Playwright container, not the workspace.

**v2.0 (Local):**
```python
# Screenshots saved directly to workspace filesystem
page.screenshot(path="screenshot.png")
# File: /workspaces/claude_in_devcontainer/screenshot.png
```

**v3.0 (Remote):**
```python
# Screenshots saved in Playwright container
pw.screenshot("screenshot.png")
# File: Inside claude-playwright container at /artifacts/screenshots/screenshot.png

# To access from workspace:
# docker cp claude-playwright:/artifacts/screenshots/screenshot.png ./
```

**Alternative:** Configure shared volume in `docker-compose.yml`:

```yaml
services:
  workspace:
    volumes:
      - screenshots:/artifacts/screenshots

  playwright:
    volumes:
      - screenshots:/artifacts/screenshots

volumes:
  screenshots:
```

---

## ✅ Verification

### 1. Service Health Check

```bash
# Check all services running
docker-compose ps

# Expected output:
# NAME                  STATUS        PORTS
# claude-workspace      Up
# claude-playwright     Up (healthy)

# Test Playwright service directly
docker exec claude-workspace curl http://playwright:3000/health
```

### 2. Python Environment

```bash
# Activate venv (should auto-activate)
source ~/.venv/bin/activate

# Verify Python version
python --version  # Should be 3.12.x

# Verify packages installed
pip list | grep playwright
pip list | grep jupyter

# Check virtual environment location
which python  # Should show /home/vscode/.venv/bin/python
```

### 3. Remote Playwright Connection

```bash
# Test connection
python -c "
from web_ui_optimizer import wait_for_playwright_service, check_service_health
wait_for_playwright_service()
health = check_service_health()
print('✅ Playwright service healthy:', health)
"
```

### 4. Run Example Scripts

```bash
# Test basic screenshot
python examples/01_basic_screenshot.py
# Should output: ✅ Screenshot saved: /artifacts/screenshots/example.png

# Test context manager
python examples/02_context_manager.py
# Should output: ✅ Screenshot saved!

# Test full UI optimizer
python examples/03_ui_optimizer_full.py https://example.com
# Should run complete analysis
```

### 5. Test UIOptimizer (Backward Compatibility)

```python
# Run in Python shell
python

from web_ui_optimizer import UIOptimizer

with UIOptimizer() as opt:
    screenshots = opt.capture_responsive("https://example.com")
    print(f"✅ Captured {len(screenshots)} screenshots")

    colors = opt.analyze_colors()
    print(f"✅ Found {len(colors)} colors")

    a11y = opt.check_accessibility()
    print(f"✅ Accessibility check complete")
```

### 6. Docker Operations (DooD)

```bash
# Verify Docker-outside-of-Docker still works
docker ps
docker images
docker --version

# Should work from workspace container
```

### 7. Jupyter Notebooks

```bash
# Activate venv
source ~/.venv/bin/activate

# Start Jupyter
jupyter lab

# Or test in VS Code
code test.ipynb
# Select kernel: Python 3.12 (~/.venv)
```

---

## 🔧 Troubleshooting

### Issue 1: Services Won't Start

**Symptom:**
```
docker-compose ps shows services as "Exited" or "Unhealthy"
```

**Solution:**
```bash
# Check logs
docker-compose logs workspace
docker-compose logs playwright

# Rebuild services
docker-compose down
docker-compose up --build

# Check disk space
df -h
docker system df
```

---

### Issue 2: Cannot Connect to Playwright Service

**Symptom:**
```
PlaywrightConnectionError: Cannot connect to Playwright service
```

**Solution:**
```bash
# Check Playwright service is healthy
docker-compose ps playwright

# Check Playwright logs
docker-compose logs playwright

# Test connectivity from workspace
docker exec claude-workspace ping playwright
docker exec claude-workspace curl http://playwright:3000/health

# Restart Playwright service
docker-compose restart playwright
```

---

### Issue 3: Virtual Environment Not Found

**Symptom:**
```
source .venv/bin/activate
# bash: .venv/bin/activate: No such file or directory
```

**Solution:**
```bash
# Virtual environment moved to ~/.venv
source ~/.venv/bin/activate

# Check if it exists
ls -la ~/.venv

# If missing, rebuild workspace
docker-compose down
docker-compose up --build workspace
```

---

### Issue 4: Import Errors

**Symptom:**
```python
ImportError: cannot import name 'RemotePlaywright' from 'web_ui_optimizer'
```

**Solution:**
```bash
# Ensure latest code is pulled
git pull origin main

# Check file exists
ls -la web-ui-optimizer/remote_playwright.py

# Ensure Python path includes workspace
python -c "import sys; print('\n'.join(sys.path))"

# Should include /workspaces/claude_in_devcontainer
```

---

### Issue 5: Screenshots Not Found

**Symptom:**
```
Screenshots saved but can't find them in workspace
```

**Solution:**
```bash
# Screenshots are in Playwright container
docker exec claude-playwright ls -lh /artifacts/screenshots/

# Copy to workspace
docker cp claude-playwright:/artifacts/screenshots/example.png ./

# Or configure shared volume (see Code Migration section)
```

---

### Issue 6: Xvfb Display Errors

**Symptom:**
```
Error: Could not connect to display :99
```

**Solution:**
```bash
# Xvfb runs in Playwright container, not workspace
# Check Playwright service logs
docker-compose logs playwright | grep Xvfb

# Verify Xvfb is running
docker exec claude-playwright ps aux | grep Xvfb

# Restart Playwright service
docker-compose restart playwright
```

---

### Issue 7: Performance Issues

**Symptom:**
```
Services slow to start or respond
```

**Solution:**
```bash
# Check Docker resources
# Docker Desktop → Settings → Resources
# Increase CPUs to 6-8
# Increase Memory to 12-16GB

# Use BuildKit for faster builds
export DOCKER_BUILDKIT=1
docker-compose build --parallel

# Clean up Docker
docker system prune -a --volumes
```

---

## 🔙 Rollback Procedure

If migration fails or you need to revert:

### Quick Rollback

```bash
# 1. Close VS Code DevContainer
# Command Palette → "Dev Containers: Reopen Folder Locally"

# 2. Checkout backup branch
git checkout backup-v2.0-YYYYMMDD

# 3. Stop multi-container services
docker-compose down

# 4. Rebuild single container
# In VS Code: Command Palette → "Dev Containers: Rebuild Container"
```

### Complete Rollback

```bash
# 1. Stop all services
docker-compose down -v  # Remove volumes too

# 2. Checkout v2.0 tag or backup branch
git checkout backup-v2.0-YYYYMMDD

# 3. Remove multi-container files (optional)
rm -rf .devcontainer/docker-compose.yml
rm -rf .devcontainer/workspace/
rm -rf .devcontainer/playwright/

# 4. Restore old devcontainer.json if needed
git checkout HEAD~5 .devcontainer/devcontainer.json

# 5. Rebuild in VS Code
# Command Palette → "Dev Containers: Rebuild Container"
```

### Restore Custom Code

```bash
# If you backed up custom Playwright code
cp -r ~/migration-backup/web-ui-optimizer/* web-ui-optimizer/
cp -r ~/migration-backup/scripts/* scripts/
```

---

## ❓ FAQ

### Q: Will my existing Jupyter notebooks work?

**A:** Yes! Jupyter notebooks are fully compatible. Just ensure you select the correct kernel (`~/.venv` instead of `.venv`).

---

### Q: Do I need to rewrite all my Playwright code?

**A:** Only if you're using Playwright's sync_api directly. If you're using UIOptimizer, no changes needed.

---

### Q: Can I still use local Playwright if needed?

**A:** Yes, you can install Playwright browsers in the workspace:

```bash
# In workspace container
playwright install chromium
```

However, this defeats the purpose of the multi-container architecture (cleaner workspace).

---

### Q: Are there any performance differences?

**A:** Negligible. HTTP API adds ~10-50ms latency per request, which is minimal compared to browser operations.

---

### Q: Can I run both v2.0 and v3.0 simultaneously?

**A:** No, they use the same devcontainer.json. Use git branches:

```bash
# v2.0
git checkout backup-v2.0

# v3.0
git checkout main
```

---

### Q: What if I need custom browser arguments?

**A:** Edit `.devcontainer/playwright/playwright-server.js` and modify the `chromium.launch()` options:

```javascript
browser = await chromium.launch({
    headless: true,
    args: [
        '--no-sandbox',
        '--disable-dev-shm-usage',
        '--your-custom-arg'  // Add here
    ]
});
```

---

### Q: How do I update just the Playwright service?

**A:** Rebuild only the Playwright service:

```bash
docker-compose up -d --build playwright
```

---

### Q: Can I use Firefox or WebKit instead of Chromium?

**A:** Yes, edit `.devcontainer/playwright/playwright-server.js`:

```javascript
// Change from:
const { chromium } = require('playwright');
browser = await chromium.launch(...);

// To:
const { firefox } = require('playwright');
browser = await firefox.launch(...);
```

Then rebuild: `docker-compose up -d --build playwright`

---

### Q: How do I access screenshots from the Playwright container?

**A:** Three options:

1. **Copy manually:**
   ```bash
   docker cp claude-playwright:/artifacts/screenshots/file.png ./
   ```

2. **Shared volume** (add to docker-compose.yml):
   ```yaml
   volumes:
     - screenshots:/artifacts/screenshots
   ```

3. **Bind mount to workspace:**
   ```yaml
   services:
     playwright:
       volumes:
         - ../screenshots:/artifacts/screenshots
   ```

---

### Q: What happens to my existing .venv?

**A:** The old `.venv` is ignored. New environment is at `~/.venv`. You can delete the old one:

```bash
rm -rf .venv  # Old location
```

---

### Q: How do I customize Docker Compose resource limits?

**A:** Edit `.devcontainer/docker-compose.yml`:

```yaml
services:
  workspace:
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G
```

---

## 📞 Getting Help

If you encounter issues not covered here:

1. **Check logs:**
   ```bash
   docker-compose logs workspace
   docker-compose logs playwright
   ```

2. **Review documentation:**
   - README.md (updated for v3.0)
   - CLAUDE.md (architecture guide)
   - examples/README.md (usage examples)

3. **Create an issue:**
   - Include error messages
   - Include `docker-compose ps` output
   - Include relevant logs

---

## ✅ Migration Complete!

Once verification passes, you've successfully migrated to v3.0!

**Benefits you now have:**

✅ Cleaner workspace (~450MB smaller)
✅ Modular architecture (update services independently)
✅ Better security (service isolation)
✅ Same familiar API (backward compatible)
✅ Faster workspace rebuilds

**Next steps:**

- Delete backup branch if everything works: `git branch -D backup-v2.0-YYYYMMDD`
- Update your team's documentation
- Share migration experience with the community

---

**Migration completed:** `$(date)`
