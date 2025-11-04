# AI/ML Development Environment with Docker & Playwright

A comprehensive, security-hardened VS Code DevContainer configuration for AI/ML development, featuring Docker-outside-of-Docker support and Playwright browser automation.

[![DevContainer](https://img.shields.io/badge/Dev%20Container-Ready-blue?logo=docker)](https://containers.dev/)
[![Python](https://img.shields.io/badge/Python-3.12-blue?logo=python)](https://www.python.org/)
[![Node.js](https://img.shields.io/badge/Node.js-22-green?logo=node.js)](https://nodejs.org/)
[![Security](https://img.shields.io/badge/Security-Hardened-success?logo=security)](https://github.com/anthropics/claude-code/security)

---

## =� Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Quick Start](#-quick-start)
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

## <� Overview

This repository provides a **production-ready DevContainer environment** designed for:

- > **AI/ML Development** - Python 3.12 with numpy, pandas, and data science tools
- =3 **Container Testing** - Docker-outside-of-Docker (DooD) for building and testing Docker images
- <� **Browser Automation** - Playwright with Chromium for web testing and UI optimization
- = **Security First** - Hardened configuration with pinned dependencies and minimal privileges
- =� **Comprehensive Documentation** - Extensively commented configuration files for learning

### Why This DevContainer?

 **Consistent Development Environment** - Same setup across all team members
 **Zero Configuration** - Everything pre-installed and configured
 **Security Hardened** - Dangerous capabilities removed, versions pinned
 **Fast Setup** - One-click setup with VS Code Dev Containers
 **Well Documented** - Learn from 700+ lines of inline documentation

---

## ( Features

### Development Tools

- **Python 3.12** with pip, ipython, black, pylint
- **Node.js 22** with npm and global packages
- **Claude Code** - AI-powered coding assistant
- **GitHub CLI** - Manage PRs, issues, and repos from terminal
- **Docker CLI** - Build and test containers securely

### Pre-configured VS Code Extensions

- > **Anthropic Claude Code** - AI coding assistant
- = **Python** (with Pylance, debugpy, black formatter)
- <� **Prettier & ESLint** - Code formatting and linting
- <3 **GitLens** - Advanced Git visualization
- =3 **Docker** - Container management
- <� **Playwright** - Browser automation and testing
- ( **And 10+ more quality-of-life extensions**

### Playwright Web UI Optimizer

Pre-configured project with ready-to-use tools:
- =� Responsive screenshot capture
- <� Color palette analysis
-  Accessibility checking
- � Performance metrics
- = Before/after visual comparisons

### Security Features

- = **No Privileged Containers** - Removed `SYS_ADMIN` and `ipc=host`
- =� **Pinned Package Versions** - Protected against supply chain attacks
- =� **Minimal Attack Surface** - Only necessary packages installed
- =d **Non-root User** - Runs as `vscode` user, not root
- = **Fully Auditable** - All dependencies version-controlled

---

## =� Quick Start

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

   # Check Node.js
   node --version    # Should show v22.x.x

   # Check Docker
   docker --version  # Should show Docker version

   # Check Playwright
   cd ~/web-ui-optimizer
   ./verify_setup.sh
   ```

---

## =� What's Included

### Base Environment

| Tool | Version | Purpose |
|------|---------|---------|
| Python | 3.12 | Core programming language |
| Node.js | 22 (LTS) | JavaScript runtime for Playwright |
| pip | Latest | Python package manager |
| npm | Latest | Node.js package manager |

### Python Packages (Pinned Versions)

```python
playwright==1.55.0        # Browser automation
pytest==7.4.3             # Testing framework
pytest-playwright==0.7.1  # Pytest + Playwright integration
black==23.12.1            # Code formatter
pylint==3.0.3             # Code linter
ipython==8.18.1           # Interactive shell
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

## = Security Features

This DevContainer has been **security hardened** with the following measures:

### L Removed Dangerous Capabilities

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

### =� Supply Chain Protection

All package versions are pinned to prevent:
- � Malicious package updates
- � Typosquatting attacks
- � Compromised maintainer accounts
- � Unexpected breaking changes

**Example:**
```json
"dependencies": {
  "playwright": "1.56.1",  // Exact version, no ^ or ~
  "@playwright/test": "1.56.1"
}
```

### =� Additional Security Measures

-  Non-root user (`vscode`)
-  Minimal package installation
-  No secrets in configuration files
-  Xvfb with disabled network listeners
-  Docker socket (better than `--privileged`)

**Security Audit Report:**
- **20 security issues identified** in original configuration
- **5 CRITICAL issues resolved** (SYS_ADMIN, ipc=host, unversioned packages)
- **15 additional issues documented** with recommendations

---

## =� Usage Examples

### Example 1: Python Data Science

```python
# Create a new Python script
import pandas as pd
import numpy as np

# Your data science code here
data = pd.DataFrame({
    'A': np.random.randn(100),
    'B': np.random.randn(100)
})

print(data.describe())
```

### Example 2: Playwright Web Automation

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

### Example 3: Docker Container Testing

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

### Example 4: Using Claude Code

```bash
# Start Claude Code
claude-code

# Or use in your terminal for AI assistance
# Claude Code is pre-installed globally
```

### Example 5: GitHub CLI Operations

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

## =� Project Structure

```
.
   .devcontainer/
      devcontainer.json      # DevContainer configuration (570 lines with docs)
      post-create.sh          # Setup script (1100+ lines with docs)
   .claude/                    # Claude Code configuration
   .gitignore                  # Git ignore rules (includes .DS_Store)
   README.md                   # This file
   ~/web-ui-optimizer/         # Playwright tools (created during setup)
       package.json            # Node.js project config
       ui-optimizer.js         # Node.js Playwright tools
       ui_optimizer.py         # Python Playwright tools
       verify_setup.sh         # Installation verification
       README.md               # Usage documentation
```

---

## � Configuration

### Customizing the Environment

#### Add More Python Packages

Edit `.devcontainer/post-create.sh` (line 201):

```bash
pip install \
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

## =' Troubleshooting

### Container Won't Start

**Check Docker Desktop:**
```bash
docker info  # Should show server information
```

**Solutions:**
- Ensure Docker Desktop is running
- Restart Docker Desktop
- Check disk space: `df -h`
- Check Docker resources in Settings � Resources

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
- Rebuild container: `Cmd+Shift+P` � "Rebuild Container"
- Check devcontainer.json has docker-outside-of-docker feature
- Verify /var/run/docker.sock exists on host

### Python Package Installation Fails

**Check pip:**
```bash
pip --version
pip install --upgrade pip
```

**Solutions:**
- Check network connectivity
- Try with `--no-cache-dir`: `pip install --no-cache-dir package`
- Check disk space: `df -h`

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

## =� Performance Tips

### macOS/Windows Performance

1. **Use WSL2 on Windows**
   - Docker Desktop � Settings � General � Use WSL2
   - 10x faster than Hyper-V

2. **Increase Docker Resources**
   - Docker Desktop � Settings � Resources
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
# Clear pip cache
pip cache purge

# Clear npm cache
npm cache clean --force
```

### Reduce Browser Download Time

**Browsers are cached in Docker volume:**
- First install: 2-5 minutes
- Subsequent starts: Instant (cached)
- Volume location: `~/.cache/ms-playwright`

---

## =� Documentation

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

## > Contributing

### How to Contribute

1. Fork this repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Test thoroughly in the devcontainer
5. Commit with descriptive messages: `git commit -m 'Add: Amazing feature'`
6. Push to your fork: `git push origin feature/amazing-feature`
7. Open a Pull Request

### Contribution Guidelines

-  Update documentation for new features
-  Test in devcontainer before submitting
-  Pin new package versions
-  Add security considerations
-  Update README.md if needed

### Reporting Issues

Found a bug? Have a suggestion?

1. Check [existing issues](https://github.com/YOUR_USERNAME/YOUR_REPO/issues)
2. Create a new issue with:
   - Clear description
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (OS, Docker version)

---

## =� Changelog

### Version 2.0 (Current)

**Security Improvements:**
-  Removed `SYS_ADMIN` capability (CRITICAL)
-  Removed `ipc=host` flag (CRITICAL)
-  Pinned all package versions
-  Added comprehensive security documentation

**Features:**
-  Docker-outside-of-Docker support
-  Playwright web automation tools
-  Claude Code AI assistant
-  GitHub CLI integration

**Documentation:**
-  700+ lines of inline comments
-  Comprehensive README
-  Security audit report
-  Troubleshooting guide

### Version 1.0 (Previous)

- Initial DevContainer setup
- Basic Python/Node.js environment
- Playwright support

---

## =O Acknowledgments

- **Anthropic** - For Claude Code AI assistant
- **Microsoft** - For DevContainers and VS Code
- **Playwright Team** - For browser automation framework
- **Docker** - For containerization technology

---

## =� License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## = Quick Links

- =� [DevContainers Documentation](https://containers.dev/)
- <� [Playwright Documentation](https://playwright.dev/)
- =3 [Docker Documentation](https://docs.docker.com/)
- > [Claude Code](https://claude.com/claude-code)
- = [GitHub CLI](https://cli.github.com/)

---

## =� Support

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

**P Star this repository if you find it useful!**

Made with d for developers who value security, documentation, and productivity.

[Report Bug](https://github.com/YOUR_USERNAME/YOUR_REPO/issues) � [Request Feature](https://github.com/YOUR_USERNAME/YOUR_REPO/issues) � [Documentation](https://github.com/YOUR_USERNAME/YOUR_REPO/wiki)

</div>
