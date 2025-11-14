# Multi-Container DevContainer - Quick Reference

> **v4.0 - Config-Driven Services**: Services are enabled/disabled via `runServices` array in `devcontainer.json`. No `.env` file editing needed.

## Starting the Environment

### In VS Code (Recommended)

```
Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
→ "Dev Containers: Reopen in Container"

VS Code will:
1. Run init-profiles.sh (configure services)
2. Run docker-compose up with configured profiles
3. Connect to workspace service
4. Run post-create script (first time)
5. Ready to code!
```

### Manual Start (From .devcontainer directory)

```bash
# Start all configured services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

## Service Configuration (v4.0 - Config-Driven)

### Enable/Disable Services

**Edit `.devcontainer/devcontainer.json`:**

```json
// Find the runServices property and add/remove services
"runServices": ["workspace", "playwright"],

// Minimal setup (no browser automation)
"runServices": ["workspace"]
```

**Then rebuild container:**
- Cmd+Shift+P (or Ctrl+Shift+P)
- "Dev Containers: Rebuild Container"

**Available Services:**
- `workspace` - Core development (always included)
- `playwright` - Browser automation (optional)

## Container Management

```bash
# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# Rebuild containers
docker-compose build

# Rebuild specific service
docker-compose build workspace
docker-compose build playwright

# Restart service
docker-compose restart playwright
```

## Testing Connectivity

```bash
# Check Playwright service health (only if enabled)
docker exec claude-workspace curl http://playwright:3000/health

# From inside workspace container
curl http://playwright:3000/health
ping -c 2 playwright

# Test Python client
python3 << 'EOF'
from web_ui_optimizer.remote_playwright import RemotePlaywright
pw = RemotePlaywright()
print(pw.health_check())
EOF
```

## Debugging

```bash
# Shell into workspace
docker exec -it claude-workspace bash

# Shell into playwright service
docker exec -it claude-playwright bash

# Check network
docker network inspect playwright-network

# Check volumes
docker volume ls | grep claude

# Check health status
docker inspect claude-playwright --format='{{.State.Health.Status}}'
```

## Service URLs

| Service | Internal URL | Purpose |
|---------|-------------|---------|
| Playwright | http://playwright:3000 | Browser automation API |
| Playwright Health | http://playwright:3000/health | Health check |

## Environment Variables

```bash
# In workspace container
PLAYWRIGHT_SERVICE_URL=http://playwright:3000
DISPLAY=:99
PYTHONUNBUFFERED=1
VIRTUAL_ENV=/home/vscode/.venv
```

## Volume Locations

```bash
# Workspace volumes
node_modules → Docker volume (performance)
uv_cache → /home/vscode/.cache/uv
venv → /home/vscode/.venv

# Playwright volumes
browsers → /ms-playwright
screenshots → /artifacts/screenshots (shared)
videos → /artifacts/videos (shared)
traces → /artifacts/traces (shared)
```

## Common Tasks

### Update Python Packages
```bash
source ~/.venv/bin/activate
uv pip install package-name
```

### Enable/Disable Playwright Service
```bash
# 1. Edit .devcontainer/devcontainer.json
# Change: "runServices": ["workspace", "playwright"]
# To:     "runServices": ["workspace"]

# 2. Rebuild in VS Code:
# Cmd+Shift+P → "Dev Containers: Rebuild Container"
```

### Rebuild Workspace (Fast)
```bash
docker-compose build workspace
docker-compose up -d workspace
# In VS Code: Reload Window
```

### Reset Everything
```bash
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

## Resource Limits

| Service | CPUs | Memory |
|---------|------|--------|
| Workspace | 2-4 | 4-8GB |
| Playwright | 1-2 | 1-2GB |

## Ports Forwarded (Workspace)

- 3001: Node.js, React, Next.js
- 4000: GraphQL servers
- 5000: Flask, Python web apps (mapped to host:5001)
- 5173: Vite dev server
- 8000: FastAPI, Django
- 8080: Alternative HTTP
- 8888: Jupyter Lab

**Note**: Playwright port 3000 is NOT forwarded (internal network only)

## Troubleshooting

### Service not starting
```bash
# Check service is enabled in devcontainer.json
cat .devcontainer/devcontainer.json | grep -A 2 runServices

# Check docker-compose profiles
docker-compose config --profiles

# View all logs
docker-compose logs -f
```

### Playwright service unhealthy
```bash
# Check if service is enabled
docker-compose ps playwright

# View logs
docker-compose logs playwright

# Restart service
docker-compose restart playwright

# Manual health check
docker exec claude-playwright curl http://localhost:3000/health
```

### Workspace can't reach playwright
```bash
# Test network connectivity
docker exec claude-workspace ping playwright

# Test DNS resolution
docker exec claude-workspace nslookup playwright

# Test HTTP connection
docker exec claude-workspace curl http://playwright:3000/health

# Check network
docker network inspect playwright-network
```

### Out of disk space
```bash
docker system df
docker system prune -a --volumes
```

### Rebuild from scratch
```bash
docker-compose down -v
docker volume prune
docker-compose build --no-cache
docker-compose up -d
```
