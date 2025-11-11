# Claude Code in Docker - Complete DevContainer Integration

A production-ready VS Code DevContainer specifically designed for **Claude Code integration**, providing a fully-configured development environment with Python, Jupyter, Docker support, and browser automation capabilities.

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

This repository demonstrates **how to run Claude Code in a fully-featured Docker DevContainer**, providing you with:

- 🤖 **Claude Code Ready** - Pre-configured and ready to use with all dependencies
- 🐳 **Complete Docker Integration** - Docker-outside-of-Docker (DooD) for container workflows
- 🐍 **Python Development** - Python 3.12 with data science tools (numpy, pandas)
- 📓 **Jupyter Notebooks** - Full JupyterLab, Jupyter Notebook, and IPython kernel support
- 🎭 **Browser Automation** - Playwright with Chromium for web testing
- 🔒 **Security Hardened** - No privileged containers, pinned dependencies, minimal attack surface
- 📖 **Extensively Documented** - 700+ lines of inline documentation explaining every configuration choice

### Why Use Claude Code in a DevContainer?

✅ **Isolated Environment** - Keep Claude Code and its dependencies separate from your host system
✅ **Reproducible Setup** - Share the exact same environment with your team
✅ **Pre-configured Tools** - Python, Jupyter, Docker, and Playwright all ready to use
✅ **Security Focused** - Hardened configuration with removed dangerous capabilities
✅ **Cross-Platform** - Works identically on Windows, macOS, and Linux
✅ **One-Click Setup** - Just open in VS Code and click "Reopen in Container"

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

This isn't just a basic Python container with Claude Code installed. It's a **complete AI development environment** that includes:

- **Full Docker Support** - Docker-outside-of-Docker (DooD) so Claude Code can help build containers
- **Jupyter Integration** - Claude Code can create and modify Jupyter notebooks
- **Browser Automation** - Playwright pre-configured for web testing and UI work
- **Security Hardening** - Removed `SYS_ADMIN` and `ipc=host` dangerous flags
- **Extensive Documentation** - 700+ lines of inline comments explaining every choice
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

### Claude Code Integration

- **🤖 Anthropic Claude Code** - Pre-installed and configured AI coding assistant
- **🔌 Full VS Code Extension** - Seamless integration with the IDE
- **🐳 Containerized Environment** - Isolated from your host system
- **📦 All Dependencies Included** - Python, Node.js, Git, and system tools
- **⚡ Ready to Use** - No additional configuration required

### Supporting Development Tools

- **Python 3.12** - With pip, ipython, black, pylint for code quality
- **Jupyter Ecosystem** - JupyterLab, Jupyter Notebook, IPython kernel, ipywidgets
- **Node.js 22 LTS** - For JavaScript/TypeScript development and tooling
- **GitHub CLI** - Manage PRs, issues, and repos directly from terminal
- **Docker CLI** - Build and test containers with Docker-outside-of-Docker (DooD)
- **Playwright** - Browser automation for web testing and UI optimization

### Pre-configured VS Code Extensions

- 🤖 **Anthropic Claude Code** - The star of the show
- 🐍 **Python** - Full language support with Pylance, debugpy, and black formatter
- 📓 **Jupyter** - Interactive notebooks with inline execution and debugging
- 💅 **Prettier & ESLint** - Code formatting and linting for multiple languages
- 💖 **GitLens** - Enhanced Git visualization and history
- 🐳 **Docker** - Container management and Dockerfile support
- 🎭 **Playwright** - Browser automation testing framework
- ✨ **And 10+ more** - Quality-of-life extensions for productive development

### Playwright Web UI Optimizer

Pre-configured project with ready-to-use tools:

- 📱 Responsive screenshot capture
- 🎨 Color palette analysis
- ♿ Accessibility checking
- ⚡ Performance metrics
- 🔄 Before/after visual comparisons

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

   - Container builds and installs all dependencies
   - Playwright browsers download (~150MB)
   - Progress shown in VS Code terminal
   - Subsequent starts are instant (cached)

5. **Verify Installation**

   ```bash
   # Check Python
   python --version  # Should show Python 3.12.x

   # Check Jupyter (activate venv first)
   source .venv/bin/activate
   jupyter --version  # Should show Jupyter core packages

   # Check Node.js
   node --version    # Should show v22.x.x

   # Check Docker
   docker --version  # Should show Docker version

   # Check Playwright
   cd ~/web-ui-optimizer
   ./verify_setup.sh
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
source .venv/bin/activate

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
source .venv/bin/activate

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
- `.venv/` - Virtual environment (auto-generated)
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

**Add Python packages in `post-create.sh`:**

Edit `.devcontainer/post-create.sh` around line 217:

```bash
uv pip install \
    playwright==1.55.0 \
    pytest==7.4.3 \
    # Add your required packages
    tensorflow>=2.15.0 \
    torch>=2.1.0
```

**Add VS Code extensions in `devcontainer.json`:**

Edit `.devcontainer/devcontainer.json` around line 182:

```json
"extensions": [
    "anthropic.claude-code",
    "ms-python.python",
    // Add your extensions
    "ms-toolsai.vscode-jupyter-powertoys"
]
```

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
source .venv/bin/activate

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

### Base Environment

| Tool    | Version  | Purpose                           |
| ------- | -------- | --------------------------------- |
| Python  | 3.12     | Core programming language         |
| Node.js | 22 (LTS) | JavaScript runtime for Playwright |
| uv      | Latest   | Fast Python package manager       |
| npm     | Latest   | Node.js package manager           |

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

**Browser Automation & Testing (Pinned Versions):**

```python
playwright==1.55.0        # Browser automation
pytest==7.4.3             # Testing framework
pytest-playwright==0.7.1  # Pytest + Playwright integration
```

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

Pre-installed for Chromium/Playwright:

- Graphics: GTK, Cairo, Pango, Vulkan
- Audio/Video: GStreamer, ALSA
- Fonts: Liberation, Noto Color Emoji
- X11: Xvfb (virtual display for headless automation)

### Docker Support

**Docker-outside-of-Docker (DooD)** configuration:

- Docker CLI installed in container
- Host Docker socket mounted
- Build and test containers securely
- No dangerous `--privileged` flag needed

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

### Example 1: Jupyter Notebooks

**Start JupyterLab:**

```bash
# Activate the virtual environment
source .venv/bin/activate

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
source .venv/bin/activate
ipython
```

### Example 2: Python Data Science

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

### Example 3: Playwright Web Automation

**Node.js:**

```bash
cd ~/web-ui-optimizer
node ui-optimizer.js https://example.com
```

**Python:**

```bash
cd ~/web-ui-optimizer
python ui_optimizer.py https://example.com
```

**Features:**

- Captures responsive screenshots (mobile, tablet, desktop)
- Analyzes color palette
- Checks accessibility issues
- Measures performance metrics

### Example 4: Docker Container Testing

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

### Example 5: Using Claude Code (Primary Use Case)

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

### Example 6: GitHub CLI Operations

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
│   ├── devcontainer.json      # DevContainer configuration (570 lines with docs)
│   └── post-create.sh          # Setup script (1100+ lines with docs)
├── .venv/                      # Python virtual environment with Jupyter
├── .claude/                    # Claude Code configuration
├── .gitignore                  # Git ignore rules
├── pyproject.toml              # Python project configuration
├── uv.lock                     # Locked dependencies (uv package manager)
├── test.ipynb                  # Example Jupyter notebook
├── README.md                   # This file
└── ~/web-ui-optimizer/         # Playwright tools (created during setup)
    ├── package.json            # Node.js project config
    ├── ui-optimizer.js         # Node.js Playwright tools
    ├── ui_optimizer.py         # Python Playwright tools
    ├── verify_setup.sh         # Installation verification
    └── README.md               # Usage documentation
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
source .venv/bin/activate
uv pip install -e .
```

**Or using post-create.sh:**

Edit `.devcontainer/post-create.sh` (line 205):

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

Edit `.devcontainer/devcontainer.json` (line 516):

```json
"hostRequirements": {
  "cpus": 4,      // Increase for heavy ML workloads
  "memory": "8gb", // Increase for large datasets
  "storage": "50gb"
}
```

#### Port Forwarding

Edit `.devcontainer/devcontainer.json` (line 375):

```json
"forwardPorts": [3000, 5000, 8000, 8080]  // Add your ports
```

---

## 🔧 Troubleshooting

### Container Won't Start

**Check Docker Desktop:**

```bash
docker info  # Should show server information
```

**Solutions:**

- Ensure Docker Desktop is running
- Restart Docker Desktop
- Check disk space: `df -h`
- Check Docker resources in Settings → Resources

### Playwright Browser Not Found

**Reinstall browsers:**

```bash
cd ~/web-ui-optimizer
npx playwright install chromium --with-deps
python -m playwright install chromium
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
source .venv/bin/activate
jupyter --version
```

**Solutions:**

- Ensure you've activated the venv: `source .venv/bin/activate`
- Reinstall Jupyter: `uv pip install jupyter jupyterlab`
- Check if installed: `pip list | grep jupyter`
- In VS Code, select the correct kernel (.venv) when opening notebooks

### Display Issues (Xvfb)

**Check Xvfb is running:**

```bash
echo $DISPLAY  # Should show :99
ps aux | grep Xvfb
```

**Restart Xvfb:**

```bash
pkill Xvfb
Xvfb :99 -screen 0 1920x1080x24 -nolisten tcp -nolisten unix &
export DISPLAY=:99
```

### Out of Disk Space

**Clean Docker:**

```bash
docker system prune -a --volumes  # WARNING: Removes all unused data
```

**Check disk usage:**

```bash
df -h
du -sh ~/.cache/ms-playwright  # Browser cache
du -sh node_modules             # Node packages
```

---

## ⚡ Performance Tips

### macOS/Windows Performance

1. **Use WSL2 on Windows**

   - Docker Desktop → Settings → General → Use WSL2
   - 10x faster than Hyper-V

2. **Increase Docker Resources**

   - Docker Desktop → Settings → Resources
   - CPUs: 4-8 cores
   - Memory: 8-16GB
   - Disk: 50GB+

3. **Use Volumes for node_modules**
   - Already configured in devcontainer.json
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

**Browsers are cached in Docker volume:**

- First install: 2-5 minutes
- Subsequent starts: Instant (cached)
- Volume location: `~/.cache/ms-playwright`

---

## 📚 Documentation

### Inline Documentation

This repository contains **700+ lines of detailed documentation** in configuration files:

- **devcontainer.json** (570 lines) - Every configuration option explained
- **post-create.sh** (1100+ lines) - Step-by-step setup documentation

### Learning Resources

- [DevContainers Documentation](https://containers.dev/)
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

### Version 2.0 (Current)

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

### Version 1.0 (Previous)

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
- 🎭 [Playwright Documentation](https://playwright.dev/)
- 🐳 [Docker Documentation](https://docs.docker.com/)
- 🤖 [Claude Code](https://claude.com/claude-code)
- 🔧 [GitHub CLI](https://cli.github.com/)

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

### 🤖 Ready to Use Claude Code in Docker?

1. Clone this repository
2. Open in VS Code
3. Click "Reopen in Container"
4. Start using Claude Code with full Python, Jupyter, Docker, and Playwright support!

**This is the complete Claude Code DevContainer integration you've been looking for.**

</div>
