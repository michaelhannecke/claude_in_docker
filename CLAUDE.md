# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **multi-container DevContainer environment** specifically designed for Claude Code integration with full Python, Jupyter, Docker, and Playwright support. The repository provides a production-ready, security-hardened development environment using Docker Compose to orchestrate separate services for development and browser automation.

**Key Architecture Decision**: This project uses a **modular multi-container architecture** with:
- **Workspace service**: Python development environment (no browsers)
- **Playwright service**: Dedicated browser automation service (Chromium + HTTP API)
- **Docker Compose**: Orchestrates both services
- **Docker-outside-of-Docker (DooD)**: Access to host Docker without privileged mode

## Essential Commands

### Multi-Container Management

```bash
# View all services status
docker-compose ps

# View service logs
docker-compose logs -f workspace
docker-compose logs -f playwright

# Restart a service
docker-compose restart playwright

# Rebuild a service
docker-compose build workspace
docker-compose build playwright

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### Python Development

```bash
# Activate the virtual environment (REQUIRED for Python work)
source ~/.venv/bin/activate

# Run Python scripts
python main.py

# Install new Python packages
uv pip install package-name

# Install project in editable mode
uv pip install -e .

# Code formatting
black filename.py

# Code linting
pylint filename.py
```

### Jupyter Notebooks

```bash
# Activate venv first
source ~/.venv/bin/activate

# Start JupyterLab (opens in browser)
jupyter lab

# Start classic Jupyter Notebook
jupyter notebook

# Run IPython interactive shell
ipython
```

**Important**: In VS Code, when opening `.ipynb` files, select the Python kernel from `~/.venv/bin/python` (not the system Python).

### Docker Operations

```bash
# Build Docker images
docker build -t image-name .

# Run containers
docker run -d -p 8080:8080 image-name

# View running containers
docker ps

# View logs
docker logs container-id

# Clean up
docker system prune -f
```

**Note**: Docker commands control the HOST Docker daemon (Docker-outside-of-Docker setup). Containers you create are siblings to the devcontainer services, not children.

### Claude Code CLI

```bash
# Check Claude Code version
claude --version

# Start interactive Claude Code session
claude

# Get help
claude --help

# Run Claude Code with a specific prompt
claude "explain this code"

# Use Claude Code for code review
claude review
```

**Note**: The Claude Code CLI is installed globally via npm during the post-create script and is available immediately in the workspace container.

### Playwright Browser Automation (Remote Service)

```bash
# Check Playwright service status
docker-compose ps playwright
docker exec claude-playwright curl http://localhost:3000/health

# Test connectivity from workspace
curl http://playwright:3000/health
ping -c 2 playwright

# Run UI optimizer (uses remote service)
cd /workspaces/claude_in_devcontainer
python web-ui-optimizer/ui_optimizer.py https://example.com

# Run example scripts
python examples/01_basic_screenshot.py
python examples/02_context_manager.py
python examples/03_ui_optimizer_full.py https://example.com

# Test connection
python web-ui-optimizer/connection.py
```

**Environment Variables**:
- `PLAYWRIGHT_SERVICE_URL=http://playwright:3000` - Playwright service endpoint
- `DISPLAY=:99` - Virtual display (in playwright service, not workspace)

**Python Usage**:
```python
from web_ui_optimizer import RemotePlaywright

# Basic usage
with RemotePlaywright() as pw:
    pw.new_context()
    pw.navigate("https://example.com")
    pw.screenshot("output.png", full_page=True)

# UI Optimizer (high-level)
from web_ui_optimizer import UIOptimizer

with UIOptimizer() as optimizer:
    screenshots = optimizer.capture_responsive("https://example.com")
    colors = optimizer.analyze_colors()
    accessibility = optimizer.check_accessibility()
```

### Testing

```bash
# Run pytest tests
pytest

# Run tests with Playwright
pytest --headed  # Show browser (not supported in remote mode)
pytest --browser chromium  # Specific browser
```

### Package Management

```bash
# uv (fast Python package manager) is the primary tool
uv pip install package-name
uv pip list
uv pip freeze

# Update pyproject.toml dependencies, then:
uv pip install -e .
```

## Architecture & Structure

### Multi-Container Architecture

This project uses Docker Compose to run two separate services:

```
┌─────────────────────────────────────────────────────────┐
│ Docker Compose Stack                                    │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │ Workspace Service (claude-workspace)           │    │
│  │                                                 │    │
│  │ • Python 3.12, Jupyter, Node.js 22             │    │
│  │ • Claude Code CLI, Docker CLI, GitHub CLI      │    │
│  │ • Playwright CLIENT library                    │    │
│  │ • NO browsers (clean environment)              │    │
│  │ • Resources: 2-4 CPUs, 4-8GB RAM              │    │
│  │                                                 │    │
│  │ VS Code connects here ←                        │    │
│  └────────────────────────────────────────────────┘    │
│                         ↕                               │
│             playwright-network (bridge)                 │
│                         ↕                               │
│  ┌────────────────────────────────────────────────┐    │
│  │ Playwright Service (claude-playwright)         │    │
│  │                                                 │    │
│  │ • Chromium browser + Xvfb (:99)                │    │
│  │ • HTTP API server (port 3000)                  │    │
│  │ • Health checks every 30s                      │    │
│  │ • Resources: 1-2 CPUs, 1-2GB RAM              │    │
│  │                                                 │    │
│  │ http://playwright:3000 →                       │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
│  Shared Volumes:                                        │
│  • playwright_screenshots, _videos, _traces             │
└─────────────────────────────────────────────────────────┘
```

**Benefits**:
- **Separation of concerns**: Browser isolation from development
- **Faster rebuilds**: Workspace rebuilds ~1 min (vs ~5 min before)
- **Better resource management**: Independent resource limits
- **Modularity**: Update browsers without affecting workspace
- **Cleaner workspace**: No browser dependencies (-450MB)

### DevContainer Configuration

**Location**: `.devcontainer/`

**Key Files**:
- **`docker-compose.yml`**: Orchestrates both services
  - Defines `workspace` and `playwright` services
  - Configures networking (`playwright-network`)
  - Manages volumes and resource limits
  - Sets up health checks and dependencies

- **`devcontainer.json`**: VS Code configuration
  - Points to `docker-compose.yml` (not single image)
  - Connects to `workspace` service
  - Features: Node.js 22, GitHub CLI, Docker-outside-of-Docker
  - VS Code extensions: Claude Code, Python, Jupyter, Playwright, Docker, GitLens, etc.
  - Security: Non-root `vscode` user, no `SYS_ADMIN`, no `ipc=host`

- **`workspace/Dockerfile`**: Development environment image
  - Base: `mcr.microsoft.com/devcontainers/python:3.12-bookworm`
  - Minimal dependencies (NO browser packages)
  - ~2GB image (vs ~3GB with browsers)

- **`workspace/post-create.sh`**: Setup script
  - Creates Python virtual environment at `~/.venv`
  - Installs Python packages (NO browser binaries)
  - Creates Playwright client utilities
  - Execution time: ~1 min (vs ~5 min before)

- **`playwright/Dockerfile`**: Browser service image
  - Base: `mcr.microsoft.com/playwright:v1.55.0-jammy`
  - Includes Chromium, Xvfb, HTTP API server
  - ~1.5GB image

- **`playwright/playwright-server.js`**: HTTP API server
  - Exposes browser automation via REST API
  - Port 3000 (internal network only)
  - Endpoints: /health, /browser/new, /navigate, /screenshot, etc.

### Virtual Environment

**Critical**: This project uses a Python virtual environment at `~/.venv` (NOT `.venv` in project root).

- Location: `/home/vscode/.venv/`
- Activation: `source ~/.venv/bin/activate`
- The virtual environment is automatically activated in new bash sessions via `.bashrc`
- All Python packages (Jupyter, Playwright client, pytest, etc.) are installed in this venv

### Docker Integration (DooD)

**Docker-outside-of-Docker Setup** (workspace service only):
1. Docker CLI installed in workspace container
2. Host Docker socket mounted at `/var/run/docker.sock`
3. Containers created are siblings to devcontainer services, not children
4. No `--privileged` flag required (safer than Docker-in-Docker)

**Security Implications**:
- Access to Docker socket = root-equivalent access to host
- Acceptable for development, not for production
- Better alternative than privileged containers or mounting host directories

### Playwright & Browser Automation (Separate Service)

**Architecture**:
- Runs in dedicated `playwright` service container
- Chromium browser + Xvfb virtual display (`:99`)
- HTTP API server on port 3000 (internal network)
- Workspace communicates via HTTP: `http://playwright:3000`
- Shared memory: 2GB (configured in docker-compose.yml)

**Remote Playwright Client**:
- Located: `/workspaces/claude_in_devcontainer/web-ui-optimizer/`
- **`remote_playwright.py`**: HTTP client for Playwright API
- **`connection.py`**: Connection utilities and health checks
- **`ui_optimizer.py`**: High-level UI testing toolkit
- **`__init__.py`**: Package interface

**Security Note**: Browsers run with `--no-sandbox` flag (acceptable in dev containers, required because we don't use `SYS_ADMIN` capability).

### Web UI Optimizer Project

**Location**: `/workspaces/claude_in_devcontainer/web-ui-optimizer/`

Python package for browser automation using remote Playwright service:

**Core Files**:
- `remote_playwright.py` - Low-level HTTP client for Playwright API
- `ui_optimizer.py` - High-level UI testing and optimization toolkit
- `connection.py` - Connection utilities (wait_for_service, verify_connection, etc.)
- `__init__.py` - Package exports

**Features**:
- Responsive screenshot capture (mobile, tablet, desktop)
- Color palette analysis
- Accessibility checking (images, labels, headings, links)
- Performance metrics (DOM load, first paint, etc.)
- Before/after visual comparisons
- Text extraction

**Examples**: See `/workspaces/claude_in_devcontainer/examples/`

## Development Workflow

### Starting New Python Projects

1. Activate virtual environment: `source ~/.venv/bin/activate`
2. Create project structure: `mkdir -p src tests notebooks data`
3. Update `pyproject.toml` with project metadata and dependencies
4. Install project: `uv pip install -e .`
5. Add source files to `src/`
6. Add tests to `tests/`
7. Create notebooks in `notebooks/`

### Working with Jupyter Notebooks

- Always activate venv first: `source ~/.venv/bin/activate`
- In VS Code: Select kernel from `~/.venv/bin/python`
- JupyterLab provides full IDE experience
- Jupyter Notebook provides classic interface
- IPython for interactive Python shell

### Docker Workflow

1. Write Dockerfile
2. Build: `docker build -t app:latest .`
3. Test: `docker run -d -p 8080:8080 app:latest`
4. Verify: `curl http://localhost:8080`
5. Clean up: `docker stop $(docker ps -q) && docker system prune -f`

### Playwright Automation Workflow

**New Multi-Container Workflow**:

1. **Verify service connectivity**:
   ```bash
   curl http://playwright:3000/health
   python web-ui-optimizer/connection.py
   ```

2. **Use Python client**:
   ```python
   from web_ui_optimizer import RemotePlaywright

   with RemotePlaywright() as pw:
       pw.new_context()
       pw.navigate("https://example.com")
       pw.screenshot("output.png", full_page=True)
   ```

3. **Or use high-level UI Optimizer**:
   ```bash
   python web-ui-optimizer/ui_optimizer.py https://example.com
   ```

4. **Access screenshots**:
   - Saved in playwright service: `/artifacts/screenshots/`
   - Shared via Docker volume
   - Copy to workspace: `docker cp claude-playwright:/artifacts/screenshots/ ./output/`

## Security Considerations

### Hardened Configuration

This DevContainer has been security-hardened:

**Removed dangerous capabilities**:
- ❌ `SYS_ADMIN` - Near-root privileges, container escape risk
- ❌ `ipc=host` - Breaks container isolation
- ✅ Replaced with `--shm-size=2gb` for browser rendering (in playwright service)

**Supply chain protection**:
- All package versions pinned (Python, npm, Docker images)
- No `^` or `~` version ranges
- Intentional updates only
- Protected against typosquatting and compromised packages

**Additional measures**:
- Non-root `vscode` user (with sudo access)
- Minimal package installation
- No secrets in configuration files
- Xvfb without network listeners (in playwright service)
- Playwright API only accessible on internal Docker network

### Docker Socket Access

The Docker socket mount (`/var/run/docker.sock`) in the workspace service provides root-equivalent access. This is acceptable for development because:
- Better than `--privileged` flag
- Standard practice for DevContainers
- Host Docker daemon enforces security policies
- More secure than mounting arbitrary host paths

**Never use in production or untrusted environments.**

### Service Isolation

The playwright service is isolated:
- No access to host Docker
- No mounting of host directories (except shared volumes)
- Port 3000 only exposed to internal Docker network
- Cannot be accessed from host machine

## Important Notes for Claude Code

### File Paths

**Workspace Service**:
- Project root: `/workspaces/claude_in_devcontainer/`
- Virtual environment: `/home/vscode/.venv/`
- Web UI optimizer package: `/workspaces/claude_in_devcontainer/web-ui-optimizer/`
- Examples: `/workspaces/claude_in_devcontainer/examples/`

**Playwright Service**:
- Artifacts: `/artifacts/screenshots/`, `/artifacts/videos/`, `/artifacts/traces/`
- Browsers: `/ms-playwright/`
- API endpoint: `http://playwright:3000` (from workspace)

**Important**: Virtual environment is at `~/.venv` (NOT project `.venv`)

### Common Pitfalls

1. **Forgetting to activate venv**: Always run `source ~/.venv/bin/activate` before Python/Jupyter commands
2. **Wrong Python path**: Use `/home/vscode/.venv/bin/python`, not `/usr/local/bin/python`
3. **Trying to run browsers locally**: Browsers are in playwright service, use RemotePlaywright client
4. **Playwright service not ready**: Check `docker-compose ps` and `docker-compose logs playwright`
5. **Network connectivity issues**: Verify `curl http://playwright:3000/health` works
6. **Screenshots not found locally**: They're in playwright service, use `docker cp` to retrieve

### Service Communication

Workspace service communicates with playwright service via:
- **URL**: `http://playwright:3000` (internal Docker DNS)
- **Network**: `playwright-network` (bridge network)
- **Protocol**: HTTP/REST API
- **Environment variable**: `PLAYWRIGHT_SERVICE_URL=http://playwright:3000`

### Port Forwarding

These ports are automatically forwarded by VS Code (workspace service):
- 3001: React, Next.js, Node.js
- 4000: GraphQL servers
- 5000: Flask, Python web apps
- 5173-5174: Vite dev servers
- 8000: FastAPI, Django
- 8080-8081: Alternative HTTP, proxies
- 8888: Jupyter Lab

**Note**: Port 3000 (playwright service) is NOT forwarded to host (internal only)

### VS Code Integration

- Claude Code extension pre-installed
- Python extension with Pylance for IntelliSense
- Jupyter extension for notebook support
- Docker extension for container management
- Playwright extension for test debugging
- GitLens for Git visualization

### Resource Requirements

**Minimum**: 4 CPUs, 6GB RAM, 40GB disk (for both services)
**Recommended**: 6-8 CPUs, 10-16GB RAM, 60GB+ disk for ML/AI workloads

**Service Breakdown**:
- Workspace: 2-4 CPUs, 4-8GB RAM
- Playwright: 1-2 CPUs, 1-2GB RAM

On macOS/Windows, increase Docker Desktop resources in Settings → Resources.

## Package Versions

All packages are pinned for security. Update intentionally:

**Node.js packages** (in `workspace/post-create.sh`):
- @anthropic-ai/claude-code (latest) - Claude Code CLI

**Python packages** (in `workspace/post-create.sh`):
- playwright==1.55.0 (client library only, no browsers)
- pytest==7.4.3
- pytest-playwright==0.7.1
- black==23.12.1
- pylint==3.0.3
- numpy==1.26.2
- pandas==2.3.3
- requests==2.31.0
- ipython==8.18.1

**Project dependencies** (in `pyproject.toml`):
- jupyter>=1.1.1

**Docker Images**:
- Workspace: `mcr.microsoft.com/devcontainers/python:3.12-bookworm`
- Playwright: `mcr.microsoft.com/playwright:v1.55.0-jammy`

## Troubleshooting

### Container won't start
- Check Docker Desktop is running
- Verify disk space: `df -h`
- Check logs: `docker-compose logs`
- Try rebuilding: `docker-compose down && docker-compose build && docker-compose up -d`
- In VS Code: Cmd+Shift+P → "Dev Containers: Rebuild Container"

### Playwright service unhealthy
```bash
# Check status
docker-compose ps playwright

# View logs
docker-compose logs playwright

# Check Xvfb
docker exec claude-playwright ps aux | grep Xvfb

# Manual health check
docker exec claude-playwright curl http://localhost:3000/health

# Restart service
docker-compose restart playwright
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

### Jupyter not found
- Activate venv: `source ~/.venv/bin/activate`
- Verify installation: `jupyter --version`
- Reinstall if needed: `uv pip install jupyter jupyterlab`

### Docker commands fail (from workspace)
- Verify Docker socket: `ls -l /var/run/docker.sock`
- Check Docker access: `docker ps`
- Ensure Docker-outside-of-Docker feature is enabled in `devcontainer.json`

### Screenshots not accessible
```bash
# List screenshots in playwright service
docker exec claude-playwright ls -lh /artifacts/screenshots/

# Copy screenshot to workspace
docker cp claude-playwright:/artifacts/screenshots/example.png ./

# Or access via shared volume (if configured)
ls /artifacts/screenshots/
```

### Out of disk space
```bash
# Clean Docker system
docker system prune -a --volumes

# Clean specific volumes
docker volume prune

# Check usage
docker system df
du -sh ~/.cache/ms-playwright  # (won't exist in workspace anymore)
```

### Service logs
```bash
# Follow all logs
docker-compose logs -f

# Specific service logs
docker-compose logs -f workspace
docker-compose logs -f playwright

# Last N lines
docker-compose logs --tail=50 playwright
```

## Quick Reference

**Most Common Commands**:
```bash
# Claude Code CLI
claude --version
claude "help me with this code"

# Python work
source ~/.venv/bin/activate
python script.py

# Jupyter
jupyter lab

# Playwright automation
python web-ui-optimizer/ui_optimizer.py https://example.com

# Service management
docker-compose ps
docker-compose logs -f playwright

# Health check
curl http://playwright:3000/health
```

**Emergency Reset**:
```bash
# Stop everything
docker-compose down -v

# Rebuild from scratch
docker-compose build --no-cache

# Start fresh
docker-compose up -d

# Or in VS Code: "Dev Containers: Rebuild Container"
```
