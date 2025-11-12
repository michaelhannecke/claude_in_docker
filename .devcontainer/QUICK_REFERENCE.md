# Multi-Container DevContainer - Quick Reference

## Starting the Environment

```bash
# From .devcontainer directory
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

## In VS Code

```
Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
→ "Dev Containers: Reopen in Container"

VS Code will:
1. Run docker-compose up
2. Connect to workspace service
3. Run post-create script (first time)
4. Ready to code!
```

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
# Check Playwright service health
docker exec claude-workspace curl http://playwright:3000/health

# Test Python client
docker exec claude-workspace python3 << 'EOF'
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

## Ports Forwarded

- 3001: Node.js, React
- 4000: GraphQL
- 5000: Flask
- 5173: Vite
- 8000: FastAPI, Django
- 8080: HTTP
- 8888: Jupyter Lab

## Troubleshooting

### Playwright service unhealthy
```bash
docker-compose logs playwright
docker-compose restart playwright
```

### Workspace can't reach playwright
```bash
docker exec claude-workspace ping playwright
docker exec claude-workspace nslookup playwright
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
