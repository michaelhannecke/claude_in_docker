# Claude Code in Docker - Multi-Container DevContainer

A production-ready VS Code DevContainer specifically designed for **Claude Code integration**, using a **modular multi-container architecture** with Docker Compose. Provides a fully-configured development environment with Python, Jupyter, Docker support, and remote browser automation capabilities.

[![Claude Code](https://img.shields.io/badge/Claude%20Code-Integrated-blueviolet?logo=anthropic)](https://claude.com/claude-code)
[![DevContainer](https://img.shields.io/badge/Dev%20Container-Ready-blue?logo=docker)](https://containers.dev/)
[![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)](https://www.python.org/)
[![Jupyter](https://img.shields.io/badge/Jupyter-Enabled-orange?logo=jupyter)](https://jupyter.org/)
[![Security](https://img.shields.io/badge/Security-Hardened-success?logo=security)](https://github.com/anthropics/claude-code/security)

---

## 📚 Table of Contents

- [Overview](#-overview)
- [Why Claude Code in Docker?](#-why-claude-code-in-docker)
- [Features](#-features)
- [Quick Start](#-quick-start)
- [Starting Your Own Project](#-starting-your-own-project)
- [What's Included](#-whats-included)
- [Security Features](#-security-features)
- [Usage Examples](#-usage-examples)
- [Project Structure](#-project-structure)
- [Configuration](#-configuration)
- [Troubleshooting](#-troubleshooting)
- [Performance Tips](#-performance-tips)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 Overview

This repository demonstrates **how to run Claude Code in a multi-container Docker environment**, providing you with:

- 🤖 **Claude Code Ready** - Pre-configured and ready to use with all dependencies
- 🏗️ **Multi-Container Architecture** - Docker Compose orchestrating workspace + browser automation services
- 🐳 **Complete Docker Integration** - Docker-outside-of-Docker (DooD) for container workflows
- 🐍 **Python Development** - Python 3.12 with data science tools (numpy, pandas)
- 📓 **Jupyter Notebooks** - Full JupyterLab, Jupyter Notebook, and IPython kernel support
- 🎭 **Remote Browser Automation** - Playwright service in separate container with HTTP API
- 🔒 **Security Hardened** - Service isolation, no privileged containers, pinned dependencies
- 📖 **Extensively Documented** - Comprehensive documentation explaining the architecture

### Why Use Claude Code in a Multi-Container DevContainer?

✅ **Service Isolation** - Workspace and browser automation in separate containers
✅ **Cleaner Workspace** - No browser binaries or display servers in development environment
✅ **Scalable Architecture** - Each service can be updated or scaled independently
✅ **Reproducible Setup** - Docker Compose ensures consistent multi-service orchestration
✅ **Pre-configured Tools** - Python, Jupyter, Docker, and remote Playwright ready to use
✅ **Security Focused** - Service boundaries, hardened configuration, minimal attack surface
✅ **Cross-Platform** - Works identically on Windows, macOS, and Linux
✅ **One-Click Setup** - Docker Compose starts all services automatically

---

## 🚀 Why Claude Code in Docker?

### The Problem

Setting up Claude Code with a complete development environment can be challenging:

- **Dependency Hell** - Python versions, Node.js, system libraries all need to align
- **Configuration Complexity** - Jupyter, Docker, Playwright each require specific setup
- **Platform Differences** - What works on macOS might break on Windows or Linux
- **Team Inconsistency** - Each developer's environment is slightly different
- **Host System Pollution** - Installing tools globally clutters your system

### The Solution: This DevContainer

This repository provides a **complete, ready-to-use DevContainer** for Claude Code that:

✅ **Works Immediately** - Open in VS Code, click "Reopen in Container", and start using Claude Code
✅ **Fully Integrated** - Claude Code has access to Python, Jupyter, Docker, Playwright, and all tools
✅ **Reproducible** - Share this repository, and everyone gets the identical environment
✅ **Isolated** - All dependencies stay in the container, not on your host system
✅ **Secure** - Hardened configuration with dangerous capabilities removed
✅ **Cross-Platform** - Works identically on Windows, macOS, and Linux

### What Makes This Special?

This isn't just a basic Python container with Claude Code installed. It's a **complete multi-container AI development environment** that includes:

- **Modular Architecture** - Docker Compose orchestrating workspace + Playwright services
- **Service Separation** - Browser automation isolated from development environment
- **HTTP API Communication** - Workspace communicates with Playwright via REST API
- **Full Docker Support** - Docker-outside-of-Docker (DooD) in workspace only
- **Jupyter Integration** - Claude Code can create and modify Jupyter notebooks
- **Remote Browser Automation** - Playwright HTTP API for web testing and UI work
- **Security Hardening** - Service isolation, removed `SYS_ADMIN` and `ipc=host` flags
- **Extensive Documentation** - Complete architecture documentation and examples
- **Production Ready** - Pinned versions, locked dependencies, ready for real work

### Use Cases

Perfect for:

- 🤖 **AI-Assisted Development** - Let Claude Code help with Python, Docker, and Jupyter projects
- 📓 **Data Science** - Analyze data in Jupyter notebooks with Claude Code's assistance
- 🐳 **DevOps Work** - Build and test Docker containers with AI guidance
- 🎭 **Web Automation** - Create Playwright scripts with Claude Code
- 👥 **Team Projects** - Everyone uses the same environment, no "works on my machine"
- 🎓 **Learning** - Study how to properly configure DevContainers for AI tools

---

## ✨ Features

### Multi-Container Architecture

```
┌─────────────────────────────────────────┐
│ Docker Compose Stack                    │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │ Workspace Service                │  │
│  │ • Python 3.12 + Jupyter          │  │
│  │ • Docker CLI (DooD)              │  │
│  │ • Playwright CLIENT library      │  │
│  │ • NO browsers (clean env)        │  │
│  └──────────────────────────────────┘  │
│              ↕ HTTP API                 │
│  ┌──────────────────────────────────┐  │
│  │ Playwright Service               │  │
│  │ • Chromium browser + Xvfb        │  │
│  │ • HTTP API server (port 3000)    │  │
│  │ • Isolated browser automation    │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### Claude Code Integration

- **🤖 Anthropic Claude Code** - Pre-installed AI coding assistant in workspace
- **🔌 Full VS Code Extension** - Seamless integration with the IDE
- **🐳 Multi-Container Environment** - Workspace and browser services isolated
- **📦 All Dependencies Included** - Python, Node.js, Git, remote Playwright client
- **⚡ Ready to Use** - Services auto-start via Docker Compose

### Supporting Development Tools

**Workspace Service:**
- **Python 3.12** - With pip, ipython, black, pylint for code quality
- **Jupyter Ecosystem** - JupyterLab, Jupyter Notebook, IPython kernel, ipywidgets
- **Node.js 22 LTS** - For JavaScript/TypeScript development and tooling
- **GitHub CLI** - Manage PRs, issues, and repos directly from terminal
- **Docker CLI** - Build and test containers with Docker-outside-of-Docker (DooD)
- **Remote Playwright Client** - HTTP client library for browser automation

**Playwright Service:**
- **Chromium Browser** - Latest version from official Playwright image
- **Xvfb Display Server** - Virtual display for headless automation (:99)
- **HTTP API Server** - Express.js REST API (Node.js, port 3000)
- **Playwright Library** - Browser automation engine

### Pre-configured VS Code Extensions

- 🤖 **Anthropic Claude Code** - The star of the show
- 🐍 **Python** - Full language support with Pylance, debugpy, and black formatter
- 📓 **Jupyter** - Interactive notebooks with inline execution and debugging
- 💅 **Prettier & ESLint** - Code formatting and linting for multiple languages
- 💖 **GitLens** - Enhanced Git visualization and history
- 🐳 **Docker** - Container management and Dockerfile support
- 🎭 **Playwright** - Browser automation testing framework
- ✨ **And 10+ more** - Quality-of-life extensions for productive development

### Remote Playwright Client & UI Optimizer

Pre-configured client library and tools for remote browser automation:

- 🔌 **RemotePlaywright Client** - HTTP API wrapper for seamless automation
- 🌐 **HTTP Communication** - Workspace → Playwright service (port 3000)
- 📱 **Responsive Screenshots** - Multi-viewport capture via API
- 🎨 **Color Analysis** - Palette extraction from remote browser
- ♿ **Accessibility Checks** - A11y audits via remote service
- ⚡ **Performance Metrics** - Remote performance measurement
- 📦 **UIOptimizer Class** - High-level toolkit using remote Playwright

### Security Features

- 🚫 **No Privileged Containers** - Removed `SYS_ADMIN` and `ipc=host`
- 📌 **Pinned Package Versions** - Protected against supply chain attacks
- 🛡️ **Minimal Attack Surface** - Only necessary packages installed
- 👤 **Non-root User** - Runs as `vscode` user, not root
- 🔍 **Fully Auditable** - All dependencies version-controlled

---

## 🚀 Quick Start

### Prerequisites

1. **Docker Desktop** installed and running

   - [Install Docker Desktop](https://www.docker.com/products/docker-desktop/)
   - Minimum: 2 CPUs, 4GB RAM, 32GB disk space
   - Recommended: 4 CPUs, 8GB RAM, 50GB disk space

2. **Visual Studio Code** with Dev Containers extension

   - [Install VS Code](https://code.visualstudio.com/)
   - Install extension: [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

3. **Git** for cloning the repository
   - [Install Git](https://git-scm.com/downloads)

### Setup Steps

1. **Clone this repository**

   ```bash
   git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
   cd YOUR_REPO
   ```

2. **Open in VS Code**

   ```bash
   code .
   ```

3. **Reopen in Container**

   - VS Code will detect the devcontainer configuration
   - Click "Reopen in Container" when prompted
   - **OR** press `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (Mac)
   - Select: "Dev Containers: Reopen in Container"

4. **Wait for Setup** (5-10 minutes first time)

   - Docker Compose builds both workspace and Playwright services
   - Workspace installs Python packages and dependencies
   - Playwright service downloads Chromium browser (~150MB)
   - Progress shown in VS Code terminal
   - Subsequent starts are instant (cached)

5. **Verify Installation**

   ```bash
   # Check services are running
   docker-compose ps  # Should show both services healthy

   # Check Python
   python --version  # Should show Python 3.12.x

   # Check Jupyter (activate venv first)
   source ~/.venv/bin/activate
   jupyter --version  # Should show Jupyter core packages

   # Check Node.js
   node --version    # Should show v22.x.x

   # Check Docker
   docker --version  # Should show Docker version

   # Check Playwright service
   python examples/01_basic_screenshot.py  # Should take screenshot via remote service
   ```

---

## 🚀 Starting Your Own Project

Use this repository as a **template for your own Claude Code-enabled projects**. This DevContainer setup provides the perfect foundation for any project where you want Claude Code integrated with a complete development environment.

### Method 1: GitHub Template (Recommended)

1. **Use as Template on GitHub**

   - Click the "Use this template" button at the top of this repository
   - Choose "Create a new repository"
   - Name your repository (e.g., `my-ml-project`)
   - Choose visibility (Public/Private)
   - Click "Create repository from template"

2. **Clone Your New Repository**

   ```bash
   git clone https://github.com/YOUR_USERNAME/my-ml-project.git
   cd my-ml-project
   ```

3. **Open in VS Code**

   ```bash
   code .
   ```

4. **Reopen in Container**

   - Click "Reopen in Container" when prompted
   - Wait for initial setup (5-10 minutes first time)

### Method 2: Manual Clone and Customize

1. **Clone This Repository**

   ```bash
   git clone https://github.com/ORIGINAL_OWNER/REPO_NAME.git my-ml-project
   cd my-ml-project
   ```

2. **Remove Git History and Start Fresh**

   ```bash
   # Remove existing git history
   rm -rf .git

   # Initialize new repository
   git init
   git add .
   git commit -m "Initial commit: Set up DevContainer environment"
   ```

3. **Connect to Your Remote Repository**

   ```bash
   # Create a new repository on GitHub, then:
   git remote add origin https://github.com/YOUR_USERNAME/my-ml-project.git
   git branch -M main
   git push -u origin main
   ```

### Customization Steps

Once you have your repository set up, customize it for your project:

#### 1. Update Project Metadata

**Edit `pyproject.toml`:**

```toml
[project]
name = "my-claude-project"       # Your project name
version = "0.1.0"
description = "My project with Claude Code integration"  # Your description
readme = "README.md"
requires-python = ">=3.12"
dependencies = [
    "jupyter>=1.1.1",
    # Add your project-specific dependencies here
    "scikit-learn>=1.3.0",
    "matplotlib>=3.8.0",
]
```

#### 2. Clean Up Example Files

```bash
# Remove example files (optional)
rm test.ipynb                    # Remove example notebook
rm main.py                       # Remove example Python file (if exists)

# Keep these important files:
# - .devcontainer/ (DevContainer configuration)
# - .gitignore
# - pyproject.toml
# - README.md (update it for your project)
```

#### 3. Update README.md

Replace the content of `README.md` with your project-specific documentation:

```markdown
# My ML Project

Brief description of your project.

## Setup

This project uses a DevContainer for development. Simply open in VS Code and click "Reopen in Container".

## Usage

[Your project-specific instructions]

## Development

[Your development workflow]
```

#### 4. Add Your Code

Create your project structure:

```bash
# Activate the virtual environment
source ~/.venv/bin/activate

# Create your project structure
mkdir -p src tests notebooks data

# Example structure:
# my-ml-project/
# ├── src/              # Source code
# │   └── __init__.py
# ├── tests/            # Unit tests
# │   └── test_*.py
# ├── notebooks/        # Jupyter notebooks
# │   └── analysis.ipynb
# ├── data/             # Data files (add to .gitignore if large)
# │   ├── raw/
# │   └── processed/
# └── scripts/          # Utility scripts
```

#### 5. Install Project Dependencies

```bash
# Activate virtual environment
source ~/.venv/bin/activate

# Install your project in editable mode
uv pip install -e .

# Or install additional packages
uv pip install scikit-learn matplotlib seaborn
```

#### 6. Update .gitignore

Add project-specific ignores to `.gitignore`:

```bash
# Add to .gitignore
echo "data/raw/*" >> .gitignore
echo "data/processed/*" >> .gitignore
echo "*.model" >> .gitignore
echo "*.pkl" >> .gitignore
```

### What to Keep vs. What to Modify

**✅ Keep These (Core DevContainer Setup):**

- `.devcontainer/` - DevContainer configuration
- `.gitignore` - Git ignore rules
- `~/.venv/` - Virtual environment (auto-generated, in home directory)
- `pyproject.toml` - Customize for your project
- `uv.lock` - Dependency lock file (auto-generated)

**🔧 Customize These:**

- `README.md` - Replace with your project documentation
- `pyproject.toml` - Add your dependencies and metadata
- Create your own source files in `src/`
- Create your own notebooks in `notebooks/`

**❌ Remove/Replace These (Examples):**

- `test.ipynb` - Example notebook
- `main.py` - Example Python file (if exists)

### Optional: Customize DevContainer

If you need different tools or configurations:

**Add Python packages in workspace post-create script:**

Edit `.devcontainer/workspace/post-create.sh`:

```bash
uv pip install \
    playwright==1.55.0 \
    pytest==7.4.3 \
    # Add your required packages
    tensorflow>=2.15.0 \
    torch>=2.1.0
```

**Add VS Code extensions in `devcontainer.json`:**

Edit `.devcontainer/devcontainer.json`:

```json
"extensions": [
    "anthropic.claude-code",
    "ms-python.python",
    // Add your extensions
    "ms-toolsai.vscode-jupyter-powertoys"
]
```

**Modify Playwright service:**

Edit `.devcontainer/playwright/Dockerfile` or `.devcontainer/playwright/playwright-server.js` to customize browser automation behavior.

### First Commit Checklist

Before making your first commit, verify:

- [ ] Updated `pyproject.toml` with your project name and dependencies
- [ ] Updated `README.md` with your project description
- [ ] Removed or replaced example files (`test.ipynb`, `main.py`)
- [ ] Added your project structure (`src/`, `tests/`, `notebooks/`)
- [ ] Updated `.gitignore` with project-specific patterns
- [ ] Tested that the DevContainer builds successfully
- [ ] Verified Jupyter, Python, and Docker work correctly

### Example Workflow

Here's a complete example of starting a new ML project:

```bash
# 1. Use template on GitHub and clone
git clone https://github.com/YOUR_USERNAME/sentiment-analysis.git
cd sentiment-analysis

# 2. Open in VS Code and reopen in container
code .
# Click "Reopen in Container"

# 3. Once container is ready, customize
source ~/.venv/bin/activate

# 4. Update project files
cat > pyproject.toml << 'EOF'
[project]
name = "sentiment-analysis"
version = "0.1.0"
description = "Sentiment analysis ML project"
requires-python = ">=3.12"
dependencies = [
    "jupyter>=1.1.1",
    "scikit-learn>=1.3.0",
    "pandas>=2.1.0",
    "matplotlib>=3.8.0",
]
EOF

# 5. Install dependencies
uv pip install -e .

# 6. Create project structure
mkdir -p src/sentiment_analysis tests notebooks data/{raw,processed}
touch src/sentiment_analysis/__init__.py

# 7. Create your first notebook
jupyter notebook notebooks/exploratory_analysis.ipynb

# 8. Commit your customizations
git add .
git commit -m "Customize for sentiment analysis project"
git push
```

---

## 📦 What's Included

### Multi-Container Services

| Service | Container | Base Image | Purpose |
| ------- | --------- | ---------- | ------- |
| **workspace** | claude-workspace | Python 3.12 DevContainer | Development environment |
| **playwright** | claude-playwright | Playwright v1.55.0 | Browser automation service |

### Workspace Service Environment

| Tool    | Version  | Purpose                           |
| ------- | -------- | --------------------------------- |
| Python  | 3.12     | Core programming language         |
| Node.js | 22 (LTS) | JavaScript runtime                |
| uv      | Latest   | Fast Python package manager       |
| Docker  | Latest   | Container operations (DooD)       |

### Playwright Service Environment

| Component | Version | Purpose |
| --------- | ------- | ------- |
| Chromium  | Latest  | Browser automation |
| Node.js   | 22      | Runtime for HTTP server |
| Xvfb      | Latest  | Virtual display (:99) |
| Express   | Latest  | HTTP API server |

### Python Packages

**Core Data Science & ML:**

```python
jupyter>=1.1.1            # Jupyter metapackage
jupyterlab==4.4.10        # JupyterLab IDE
notebook==7.4.7           # Jupyter Notebook
ipython==9.6.0            # Interactive Python shell
ipykernel==7.1.0          # IPython kernel for Jupyter
ipywidgets==8.1.8         # Interactive widgets
```

**Remote Browser Automation (Workspace - Pinned Versions):**

```python
playwright==1.55.0        # Playwright client library (no browsers)
requests==2.31.0          # HTTP client for API communication
pytest==7.4.3             # Testing framework
```

**Note:** Browser binaries and automation engine run in the separate Playwright service.

**Code Quality:**

```python
black==23.12.1            # Code formatter
pylint==3.0.3             # Code linter
```

**Data Science Tools:**

```python
numpy==1.26.2             # Numerical computing
pandas==2.3.3             # Data manipulation
```

### System Libraries

**Workspace Service:**
- Minimal system dependencies (build tools, git, curl)
- NO browser dependencies (cleaner environment)
- Docker CLI for container operations

**Playwright Service:**
- Graphics: GTK, Cairo, Pango, Vulkan
- Audio/Video: GStreamer, ALSA
- Fonts: Liberation, Noto Color Emoji
- X11: Xvfb (virtual display :99 for headless automation)

### Docker Support

**Docker-outside-of-Docker (DooD)** in workspace only:

- Docker CLI installed in workspace container
- Host Docker socket mounted to workspace
- Build and test containers securely
- No dangerous `--privileged` flag needed
- Playwright service has NO Docker access (security isolation)

---

## 🔒 Security Features

This DevContainer has been **security hardened** with the following measures:

### 🚫 Removed Dangerous Capabilities

**Before (Insecure):**

```json
"runArgs": ["--ipc=host", "--cap-add=SYS_ADMIN"]
```

**After (Secure):**

```json
"runArgs": ["--shm-size=2gb"]
```

**Why?**

- `SYS_ADMIN` = Near-root privileges, enables container escape
- `ipc=host` = Breaks container isolation, exposes host memory
- Neither is required for Playwright or Docker functionality

### 🔐 Supply Chain Protection

All package versions are pinned to prevent:

- 💀 Malicious package updates
- 🎯 Typosquatting attacks
- 🔓 Compromised maintainer accounts
- 💥 Unexpected breaking changes

**Example:**

```json
"dependencies": {
  "playwright": "1.56.1",  // Exact version, no ^ or ~
  "@playwright/test": "1.56.1"
}
```

### 🛡️ Additional Security Measures

- 👤 Non-root user (`vscode`)
- 📦 Minimal package installation
- 🔒 No secrets in configuration files
- 🖥️ Xvfb with disabled network listeners
- 🐳 Docker socket (better than `--privileged`)

**Security Audit Report:**

- **20 security issues identified** in original configuration
- **5 CRITICAL issues resolved** (SYS_ADMIN, ipc=host, unversioned packages)
- **15 additional issues documented** with recommendations

---

## 💡 Usage Examples

### Example 1: Multi-Container Management

**View running services:**

```bash
# Check service status
docker-compose ps

# View service logs
docker-compose logs workspace
docker-compose logs playwright

# Restart a service
docker-compose restart playwright

# Stop all services
docker-compose down

# Rebuild and restart
docker-compose up --build
```

### Example 2: Jupyter Notebooks

**Start JupyterLab:**

```bash
# Activate the virtual environment
source ~/.venv/bin/activate

# Start JupyterLab (opens in browser)
jupyter lab

# Or start classic Jupyter Notebook
jupyter notebook

# Or run a specific notebook
jupyter notebook test.ipynb
```

**Use in VS Code:**

- Open any `.ipynb` file in VS Code
- The Jupyter extension provides inline execution and debugging
- Select kernel: Python 3.12 (.venv)
- Run cells interactively with integrated outputs

**IPython Interactive Shell:**

```bash
source ~/.venv/bin/activate
ipython
```

### Example 3: Python Data Science

```python
# Create a new Python script or Jupyter notebook
import pandas as pd
import numpy as np

# Your data science code here
data = pd.DataFrame({
    'A': np.random.randn(100),
    'B': np.random.randn(100)
})

print(data.describe())
```

### Example 4: Remote Playwright Browser Automation

**Basic screenshot using remote service:**

```bash
# Run example script
python examples/01_basic_screenshot.py
```

**Python API usage:**

```python
from web_ui_optimizer import RemotePlaywright, wait_for_playwright_service

# Wait for service to be ready
wait_for_playwright_service()

# Use context manager for automatic cleanup
with RemotePlaywright() as pw:
    # Create browser context
    pw.new_context()

    # Navigate and capture screenshot
    pw.navigate("https://example.com")
    pw.screenshot("example.png", full_page=True)

    # Execute JavaScript
    result = pw.evaluate("() => document.title")
    print(f"Page title: {result['result']}")
```

**Full UI analysis with UIOptimizer:**

```bash
# Run comprehensive analysis
python examples/03_ui_optimizer_full.py https://example.com
```

**Features:**

- Remote browser automation via HTTP API
- Responsive screenshots (mobile, tablet, laptop, desktop)
- Color palette analysis
- Accessibility checking
- Performance metrics
- All browser operations isolated in separate container

### Example 5: Docker Container Testing

```bash
# Build a Docker image
docker build -t my-app:latest .

# Run the container
docker run -d -p 8080:8080 my-app:latest

# Test the application
curl http://localhost:8080

# View logs
docker logs $(docker ps -q)

# Clean up
docker stop $(docker ps -q)
docker system prune -f
```

### Example 6: Using Claude Code (Primary Use Case)

**In VS Code:**

- Claude Code is pre-installed as a VS Code extension
- Open the Command Palette (`Ctrl+Shift+P` or `Cmd+Shift+P`)
- Type "Claude" to see all available Claude Code commands
- Use the Claude Code sidebar to interact with the AI assistant
- Claude Code has full access to the containerized environment

**From Terminal:**

```bash
# Start Claude Code CLI
claude-code

# Claude Code can now assist with:
# - Writing Python code and Jupyter notebooks
# - Docker container operations
# - Playwright browser automation
# - Git operations with GitHub CLI
# - Any task within the containerized environment
```

**Why This Matters:**

Running Claude Code in a DevContainer provides:
- **Consistent Context** - Claude Code sees the same environment as your tools
- **Safe Experimentation** - Changes are isolated from your host system
- **Full Toolchain Access** - Python, Docker, Jupyter, Playwright all available to Claude
- **Reproducible Results** - Share the entire environment with teammates

### Example 7: GitHub CLI Operations

```bash
# Authenticate
gh auth login

# Create a pull request
gh pr create --title "Feature: Add new functionality" --body "Description"

# View pull requests
gh pr list

# Clone a repository
gh repo clone username/repo
```

---

## 📁 Project Structure

```
.
├── .devcontainer/
│   ├── docker-compose.yml              # Multi-container orchestration
│   ├── devcontainer.json               # VS Code DevContainer config
│   ├── workspace/                      # Workspace service
│   │   ├── Dockerfile                  # Clean dev environment (no browsers)
│   │   └── post-create.sh              # Setup script (no browser downloads)
│   └── playwright/                     # Playwright service
│       ├── Dockerfile                  # Browser automation container
│       ├── playwright-server.js        # HTTP API server (Express.js)
│       ├── start-xvfb.sh               # Startup script (Xvfb + server)
│       └── healthcheck.sh              # Health check script
├── web-ui-optimizer/
│   ├── __init__.py                     # Package exports
│   ├── remote_playwright.py            # HTTP client library (414 lines)
│   ├── connection.py                   # Connection utilities (213 lines)
│   └── ui_optimizer.py                 # UI testing toolkit (remote)
├── examples/
│   ├── README.md                       # Examples documentation
│   ├── 01_basic_screenshot.py          # Basic usage example
│   ├── 02_context_manager.py           # Context manager pattern
│   └── 03_ui_optimizer_full.py         # Full UI analysis
├── .claude/                            # Claude Code configuration
├── .gitignore                          # Git ignore rules
├── pyproject.toml                      # Python project configuration
├── uv.lock                             # Locked dependencies
├── test.ipynb                          # Example Jupyter notebook
├── CLAUDE.md                           # Architecture guide for Claude Code
└── README.md                           # This file
```

---

## ⚙️ Configuration

### Customizing the Environment

#### Add More Python Packages

**Using pyproject.toml (Recommended):**

Edit `pyproject.toml` to add dependencies:

```toml
[project]
dependencies = [
    "jupyter>=1.1.1",
    "scikit-learn>=1.3.2",
    "tensorflow>=2.15.0",
]
```

Then install with uv:

```bash
source ~/.venv/bin/activate
uv pip install -e .
```

**Or using post-create.sh:**

Edit `.devcontainer/workspace/post-create.sh`:

```bash
uv pip install \
    playwright==1.55.0 \
    pytest==7.4.3 \
    # Add your packages here
    scikit-learn==1.3.2 \
    tensorflow==2.15.0
```

#### Add More VS Code Extensions

Edit `.devcontainer/devcontainer.json` (line 182):

```json
"extensions": [
  "anthropic.claude-code",
  // Add your extensions here
  "ms-toolsai.jupyter",
  "GitHub.copilot"
]
```

#### Adjust Resource Limits

Edit `.devcontainer/docker-compose.yml` to set per-service resources:

```yaml
services:
  workspace:
    deploy:
      resources:
        limits:
          cpus: '4'        # Increase for heavy ML workloads
          memory: 8G       # Increase for large datasets
        reservations:
          cpus: '2'
          memory: 4G

  playwright:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
```

#### Port Forwarding

Edit `.devcontainer/devcontainer.json` (line 375):

```json
"forwardPorts": [3000, 5000, 8000, 8080]  // Add your ports
```

---

## 🔧 Troubleshooting

### Multi-Container Issues

**Services won't start:**

```bash
# Check service status
docker-compose ps

# View logs for specific service
docker-compose logs workspace
docker-compose logs playwright

# Restart specific service
docker-compose restart playwright

# Rebuild and start
docker-compose down
docker-compose up --build
```

**Cannot connect to Playwright service:**

```bash
# Check if Playwright service is healthy
docker-compose ps playwright  # Should show "healthy"

# Check Playwright service logs
docker-compose logs playwright

# Test service manually
docker exec claude-playwright curl http://localhost:3000/health

# Restart Playwright service
docker-compose restart playwright
```

**Workspace can't reach Playwright:**

```bash
# Verify network connectivity from workspace
docker exec claude-workspace ping playwright
docker exec claude-workspace curl http://playwright:3000/health

# Check environment variable
docker exec claude-workspace env | grep PLAYWRIGHT_SERVICE_URL
```

### Container Won't Start

**Check Docker Desktop:**

```bash
docker info  # Should show server information
```

**Solutions:**

- Ensure Docker Desktop is running
- Restart Docker Desktop
- Check disk space: `df -h`
- Check Docker resources in Settings → Resources (need 4+ CPUs, 8+ GB RAM)

### Playwright Browser Not Working

**Note:** Browsers run in the Playwright service, not the workspace.

**Check Playwright service:**

```bash
# View Playwright service logs
docker-compose logs playwright

# Check if Xvfb is running in Playwright container
docker exec claude-playwright ps aux | grep Xvfb

# Check if HTTP server is running
docker exec claude-playwright curl http://localhost:3000/health

# Rebuild Playwright service
docker-compose up -d --build playwright
```

### Docker Commands Not Working

**Verify Docker socket:**

```bash
docker ps  # Should show containers
```

**Solutions:**

- Rebuild container: `Cmd+Shift+P` → "Rebuild Container"
- Check devcontainer.json has docker-outside-of-docker feature
- Verify /var/run/docker.sock exists on host

### Python Package Installation Fails

**Check uv:**

```bash
uv --version
```

**Solutions:**

- Check network connectivity
- Reinstall uv: `curl -LsSf https://astral.sh/uv/install.sh | sh`
- Try with `--no-cache`: `uv pip install --no-cache package`
- Check disk space: `df -h`

### Jupyter Not Found

**Activate the virtual environment:**

```bash
source ~/.venv/bin/activate  # Note: ~/.venv not .venv
jupyter --version
```

**Solutions:**

- Ensure you've activated the venv: `source ~/.venv/bin/activate`
- Check virtual environment location: `ls -la ~/.venv`
- Reinstall Jupyter: `uv pip install jupyter jupyterlab`
- Check if installed: `pip list | grep jupyter`
- In VS Code, select the correct kernel (~/.venv) when opening notebooks

### Display Issues (Xvfb)

**Note:** Xvfb runs in the Playwright service, not the workspace.

**Check Xvfb in Playwright service:**

```bash
# Check if Xvfb is running in Playwright container
docker exec claude-playwright ps aux | grep Xvfb

# Check display variable in Playwright container
docker exec claude-playwright env | grep DISPLAY  # Should show :99

# Restart Playwright service (restarts Xvfb)
docker-compose restart playwright
```

### Out of Disk Space

**Clean Docker:**

```bash
# Stop services first
docker-compose down

# Clean Docker system
docker system prune -a --volumes  # WARNING: Removes all unused data

# Restart services
docker-compose up -d
```

**Check disk usage:**

```bash
df -h

# Check Docker volumes
docker volume ls
docker system df

# Check workspace usage
du -sh ~/.venv
du -sh /workspaces/claude_in_devcontainer/node_modules

# Check Playwright container usage (browsers stored in Docker volume)
docker exec claude-playwright du -sh /ms-playwright
```

### Screenshot Files Not Accessible

**Screenshots are saved in Playwright container:**

```bash
# List screenshots in Playwright container
docker exec claude-playwright ls -lh /artifacts/screenshots/

# Copy screenshot to workspace
docker cp claude-playwright:/artifacts/screenshots/example.png ./

# Or access via shared volume (if configured in docker-compose.yml)
ls /artifacts/screenshots/
```

---

## ⚡ Performance Tips

### macOS/Windows Performance

1. **Use WSL2 on Windows**

   - Docker Desktop → Settings → General → Use WSL2
   - 10x faster than Hyper-V

2. **Increase Docker Resources**

   - Docker Desktop → Settings → Resources
   - CPUs: 6-8 cores (4 for workspace + 2 for Playwright)
   - Memory: 12-16GB (8GB for workspace + 4GB for Playwright)
   - Disk: 50GB+

3. **Use Docker Volumes**
   - Already configured in docker-compose.yml
   - node_modules, venv, and browser caches use volumes
   - 10-100x faster than bind mounts

### Faster Container Rebuilds

**Use Docker BuildKit:**

```bash
export DOCKER_BUILDKIT=1
```

**Clear caches selectively:**

```bash
# Clear uv cache
uv cache clean

# Clear npm cache
npm cache clean --force
```

### Reduce Browser Download Time

**Browsers are cached in Playwright service Docker volume:**

- First build: 2-5 minutes (Playwright service downloads Chromium)
- Subsequent starts: Instant (cached in Docker volume)
- Volume: `playwright_browsers` mounted at `/ms-playwright`
- Check size: `docker volume inspect playwright_browsers`

### Optimize Multi-Container Startup

**Parallel builds:**

```bash
# Build both services in parallel
docker-compose build --parallel

# Or use BuildKit for faster builds
DOCKER_BUILDKIT=1 docker-compose build
```

**Service-specific operations:**

```bash
# Rebuild only workspace (faster than full rebuild)
docker-compose up -d --build workspace

# Restart only Playwright (if browser issues)
docker-compose restart playwright
```

---

## 📚 Documentation

### Inline Documentation

This repository contains **700+ lines of detailed documentation** in configuration files:

- **devcontainer.json** (570 lines) - Every configuration option explained
- **workspace/post-create.sh** (1100+ lines) - Step-by-step setup documentation

### Project Documentation

- **CLAUDE.md** - Architecture guide for Claude Code instances
- **examples/README.md** - Remote Playwright usage examples

### Learning Resources

- [DevContainers Documentation](https://containers.dev/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Playwright Documentation](https://playwright.dev/)
- [Docker Documentation](https://docs.docker.com/)
- [Claude Code Documentation](https://docs.claude.com/claude-code)

---

## 🤝 Contributing

### How to Contribute

1. Fork this repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Test thoroughly in the devcontainer
5. Commit with descriptive messages: `git commit -m 'Add: Amazing feature'`
6. Push to your fork: `git push origin feature/amazing-feature`
7. Open a Pull Request

### Contribution Guidelines

- 📝 Update documentation for new features
- ✅ Test in devcontainer before submitting
- 📌 Pin new package versions
- 🔒 Add security considerations
- 📖 Update README.md if needed

### Reporting Issues

Found a bug? Have a suggestion?

1. Check [existing issues](https://github.com/YOUR_USERNAME/YOUR_REPO/issues)
2. Create a new issue with:
   - Clear description
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (OS, Docker version)

---

## 📝 Changelog

### Version 3.0 (Current) - Multi-Container Architecture

**Major Architecture Change:**

- 🏗️ **Multi-Container Setup** - Migrated from monolithic to modular architecture
- 🐳 **Docker Compose** - Orchestrating workspace + Playwright services
- 🔌 **HTTP API** - Remote browser automation via Express.js REST API
- 🌐 **Service Isolation** - Workspace and browser automation in separate containers
- 📦 **RemotePlaywright Client** - Python HTTP client library (414 lines)
- 🛠️ **Connection Utilities** - Health checking and service readiness (213 lines)
- ✨ **Updated UIOptimizer** - Rewritten to use remote Playwright service
- 📚 **Example Scripts** - Complete usage examples and documentation

**Benefits:**

- ✅ Cleaner workspace (no browser binaries, ~450MB saved)
- ✅ Independent service updates and scaling
- ✅ Better security (service boundaries)
- ✅ Faster development container rebuilds
- ✅ Clear separation of concerns

**Files Changed:**

- New: `.devcontainer/docker-compose.yml` (multi-container orchestration)
- New: `.devcontainer/playwright/` (service directory with 4 files)
- New: `.devcontainer/workspace/` (workspace-specific config)
- New: `web-ui-optimizer/remote_playwright.py` (HTTP client)
- New: `web-ui-optimizer/connection.py` (utilities)
- Updated: `.devcontainer/devcontainer.json` (Docker Compose mode)
- Updated: `web-ui-optimizer/ui_optimizer.py` (remote service)
- New: `examples/` (3 example scripts + README)

### Version 2.0

**Security Improvements:**

- 🚫 Removed `SYS_ADMIN` capability (CRITICAL)
- 🚫 Removed `ipc=host` flag (CRITICAL)
- 📌 Pinned all package versions
- 📖 Added comprehensive security documentation

**Features:**

- 🐳 Docker-outside-of-Docker support
- 🎭 Playwright web automation tools
- 🤖 Claude Code AI assistant
- 🔧 GitHub CLI integration

**Documentation:**

- 📝 700+ lines of inline comments
- 📖 Comprehensive README
- 🔒 Security audit report
- 🔧 Troubleshooting guide

### Version 1.0

- Initial DevContainer setup
- Basic Python/Node.js environment
- Playwright support

---

## 🙏 Acknowledgments

This repository exists primarily to showcase and enable **Claude Code integration in Docker environments**.

Special thanks to:

- **Anthropic** - For creating Claude Code, the AI-powered coding assistant that is the centerpiece of this repository
- **Microsoft** - For DevContainers and VS Code, which make this integration seamless
- **Playwright Team** - For browser automation capabilities that complement Claude Code
- **Docker** - For containerization technology that makes this environment reproducible

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🔗 Quick Links

- 📚 [DevContainers Documentation](https://containers.dev/)
- 🐳 [Docker Compose Documentation](https://docs.docker.com/compose/)
- 🎭 [Playwright Documentation](https://playwright.dev/)
- 🐋 [Docker Documentation](https://docs.docker.com/)
- 🤖 [Claude Code](https://claude.com/claude-code)
- 🔧 [GitHub CLI](https://cli.github.com/)

## 🏗️ Architecture Documentation

For detailed information about the multi-container architecture:

- **Quick Start**: See [Quick Start](#-quick-start) section above
- **Examples**: Check `examples/README.md` for remote Playwright usage
- **Claude Guide**: Read `CLAUDE.md` for architecture overview for AI assistants

---

## 💬 Support

Need help? Here's how to get support:

1. **Check Documentation**

   - Read this README
   - Review inline comments in config files
   - Check troubleshooting section

2. **Search Issues**

   - [Existing Issues](https://github.com/YOUR_USERNAME/YOUR_REPO/issues)
   - Someone may have had the same problem

3. **Create an Issue**

   - Provide detailed information
   - Include error messages
   - Share environment details

4. **Community Resources**
   - [DevContainers Community](https://github.com/microsoft/vscode-dev-containers/discussions)
   - [Playwright Discord](https://aka.ms/playwright/discord)
   - [Docker Community](https://www.docker.com/community/)

---

<div align="center">

**⭐ Star this repository if you find it useful!**

Made with ❤️ for developers who want to use **Claude Code in a fully-featured, isolated Docker environment**.

---

### 🤖 Ready to Use Claude Code with Multi-Container Architecture?

1. Clone this repository
2. Open in VS Code
3. Click "Reopen in Container"
4. Docker Compose starts both workspace and Playwright services automatically
5. Start using Claude Code with full Python, Jupyter, Docker, and remote Playwright support!

**This is the complete Claude Code multi-container DevContainer you've been looking for.**

**What makes this special:**
- ✨ Modular architecture with service separation
- 🧹 Clean workspace without browser dependencies
- 🔌 Remote Playwright automation via HTTP API
- 🚀 Production-ready and fully documented

</div>
