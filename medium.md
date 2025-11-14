# How I Built a Multi-Container DevContainer for Claude Code (And Why You Should Care)

![Claude Code in DevContainer - A cozy development setup](data/claude-in-devcontainer-cosy.png)

> **🔗 TL;DR**: Want to skip to the solution? Check out the [complete repository on GitHub](https://github.com/michaelhannecke/claude_in_devcontainer) with all the code, documentation, and examples. This article explains the "why" behind the architecture.

> **🤖 Full Disclosure**: This entire project—including the architecture, implementation, and even this blog post—was developed with significant assistance from Claude Code itself. Yes, I used Claude Code to build a better environment for Claude Code. Meta? Absolutely. Effective? You bet. The learning process of working with AI to build AI tooling taught me as much as the technical implementation itself.

## The Problem: When Your Dev Environment Becomes a Monster

Let me tell you a story. It starts, as many developer stories do, with good intentions and ends with me staring at error messages at 2 AM.

I wanted to use Claude Code—Anthropic's incredible AI coding assistant—in a containerized development environment. Simple, right? Just install Claude Code in a Docker container, add Python, maybe Jupyter for some data science work, throw in Playwright for browser automation, and... oh, we'll need Docker-in-Docker for container testing, and...

Three hours later, I had a Dockerfile that looked like it was written by someone having a fever dream. My container image was 3.5GB. The build took 7 minutes. And every time I wanted to update a single Python package, I had to rebuild the entire monolithic beast.

Sound familiar?

## The "Aha!" Moment

The breakthrough came when I was explaining my setup to a colleague (okay, complaining to a colleague), and they asked: "Why does your development environment need browser binaries?"

*Crickets.*

They didn't. At least, not directly. The browsers were only needed for Playwright automation—a completely separate concern from my actual development work. Yet there they sat, taking up 450MB and requiring 5-minute installations every time I rebuilt my container.

That's when I decided to burn it all down and start fresh with a **multi-container architecture**.

## The Solution: Divide and Conquer (Now with Config-Driven Services!)

Here's the core idea: instead of one massive container that does everything, use **Docker Compose to orchestrate specialized services**—and make them **optional and configurable**.

**UPDATE (v4.0)**: The architecture now uses a **config-driven approach** where you can easily enable or disable services by editing a single array in `devcontainer.json`. Want Playwright? Add it to the list. Don't need it? Leave it out. No complex environment files, no manual service management—just simple configuration.

### Service 1: The Workspace Container

This is where the magic happens—where Claude Code lives, where you write code, where you do actual development work. It contains:

- Python 3.12 with a clean virtual environment
- Node.js 22 for JavaScript tooling
- Claude Code CLI (the star of the show)
- Jupyter for notebooks and data science
- Docker CLI for container operations (Docker-outside-of-Docker)
- A Playwright *client* library (but no browser binaries)

**Size**: ~2GB
**Build time**: ~1 minute
**Rebuild time when you change Python code**: ~10 seconds

### Service 2: The Playwright Container (Optional!)

This is the specialized browser automation worker. **Now completely optional in v4.0**—only runs if you add it to your configuration.

When enabled, it contains:

- Chromium browser with all its dependencies
- Xvfb virtual display for headless automation
- An HTTP API server (Express.js) that exposes browser operations
- Health checks and monitoring

**Size**: ~1.5GB
**Build time**: ~2 minutes
**Rebuild frequency**: Almost never (unless you update browser versions)
**Configuration**: Just add `"playwright"` to the `runServices` array in `devcontainer.json`

The two services communicate via HTTP over an internal Docker network. The workspace makes API calls to the Playwright service, which does all the heavy browser lifting and returns the results.

### The Config-Driven Magic (v4.0)

Here's how simple it is to enable or disable services:

```json
// In .devcontainer/devcontainer.json
"runServices": ["workspace", "playwright"]  // Enable Playwright

// or

"runServices": ["workspace"]  // Minimal setup, no browsers
```

Rebuild your container, and only the services you listed will start. This means:

- **Faster startup** when you don't need browser automation
- **Lower resource usage** (each service uses 1-2GB RAM)
- **Cleaner architecture** with explicit dependencies
- **Easy extensibility** (add FastAPI, PostgreSQL, Redis—whatever you need)

The beauty is that this uses VS Code's native `runServices` feature combined with Docker Compose profiles. No custom scripts, no complex logic—just standard tooling working together.

## Why This Architecture Is Beautiful

### 1. **Separation of Concerns** (For Real This Time)

Each service has one job and does it well. Your development environment doesn't know or care about browser rendering engines. Your browser automation service doesn't know or care about Python package management.

This is the Unix philosophy applied to containers: do one thing and do it well.

### 2. **Blazingly Fast Rebuilds**

When I update Python packages or change my development setup, I only rebuild the workspace container. It takes about a minute. The Playwright service? Untouched. Still cached. Still ready.

Previously, every small change meant rebuilding the entire 3.5GB monster and waiting 7 minutes. Now? I get my time back.

### 3. **Independent Scaling**

Need more resources for browser automation? Bump up the Playwright service's CPU and memory limits. Working on CPU-intensive data science? Give the workspace container more resources.

In `docker-compose.yml`, this is as simple as:

```yaml
services:
  workspace:
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G

  playwright:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
```

### 4. **Cleaner Dependencies**

The workspace container has ZERO browser-related system libraries. No GTK, no Cairo, no Vulkan drivers, no Pango fonts. Just pure development tools.

This means fewer potential conflicts, a cleaner environment, and significantly reduced image size.

### 5. **Security Isolation**

Here's where it gets interesting from a security perspective. The workspace container has access to the host Docker socket (Docker-outside-of-Docker), which is necessary for Docker operations but also grants root-equivalent access to the host.

The Playwright container? Completely isolated. No Docker socket access. No host file system mounts. It can't even be accessed from your host machine—only from the workspace container via the internal Docker network.

If something goes wrong with browser automation (say, a malicious site exploits a browser vulnerability), the blast radius is limited to the Playwright container. It can't touch your Docker daemon, can't access your host filesystem, and can't reach other services outside the Docker network.

### 6. **Modularity and Updates**

When Playwright releases a new version with updated browser binaries, I update one line in the Playwright Dockerfile (now located at `.devcontainer/services/playwright/Dockerfile` in v4.0):

```dockerfile
FROM mcr.microsoft.com/playwright:v1.56.0-jammy  # Updated version
```

Rebuild that one service. Done. The workspace container doesn't need to know or care.

And in v4.0, if you don't need Playwright at all? Just remove it from your `runServices` array. It won't even start, saving you resources and startup time.

## The Technical Implementation

### The Communication Layer

I built a simple HTTP API in the Playwright container that exposes browser operations:

```javascript
// playwright-server.js
app.post('/navigate', async (req, res) => {
  const { url } = req.body;
  await page.goto(url);
  res.json({ success: true });
});

app.post('/screenshot', async (req, res) => {
  const { path, fullPage } = req.body;
  await page.screenshot({ path, fullPage });
  res.json({ success: true });
});
```

And a Python client in the workspace that makes it feel natural:

```python
# remote_playwright.py
class RemotePlaywright:
    def navigate(self, url):
        response = requests.post(
            f"{self.service_url}/navigate",
            json={"url": url}
        )
        return response.json()

    def screenshot(self, path, full_page=False):
        response = requests.post(
            f"{self.service_url}/screenshot",
            json={"path": path, "fullPage": full_page}
        )
        return response.json()
```

This keeps the API simple and maintainable. No gRPC complexity, no message queues—just good old HTTP/JSON.

### Health Checks and Reliability

Docker Compose health checks ensure the Playwright service is actually ready before the workspace tries to use it:

```yaml
playwright:
  healthcheck:
    test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
    interval: 30s
    timeout: 10s
    retries: 3
    start_period: 40s
```

In Python code, I added helper utilities to wait for service readiness:

```python
def wait_for_playwright_service(timeout=60):
    """Wait for Playwright service to be ready."""
    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            response = requests.get(f"{SERVICE_URL}/health", timeout=2)
            if response.ok:
                return True
        except requests.exceptions.RequestException:
            time.sleep(2)
    raise TimeoutError("Playwright service not ready")
```

This prevents those annoying "connection refused" errors when you try to run automation scripts immediately after container startup.

## The Claude Code Integration (And the Meta Learning Experience)

Here's the really cool part: Claude Code gets a **complete, consistent, isolated development environment** with access to:

- Python 3.12 with a clean virtual environment
- Full Jupyter support (Lab, Notebook, and IPython)
- Docker for building and testing containers
- Remote browser automation via Playwright
- GitHub CLI for repository operations
- All the VS Code extensions you'd want

From Claude Code's perspective, it's working in a fully-featured Linux environment with all tools at its disposal. But from *your* perspective, nothing is polluting your host machine. Everything stays in the containers.

You can ask Claude Code to:

- "Create a Jupyter notebook that analyzes this dataset"
- "Build a Docker container for this Flask app"
- "Write a Playwright script to test this website's responsive design"

And it just works, because all those tools are already installed and configured.

### The Learning Journey: Building with AI

Here's where it gets meta: I built this entire project *with* Claude Code's help. The irony isn't lost on me—using Claude Code to create a better environment for Claude Code.

But here's what I learned through this process:

**AI as a Collaborative Partner**: Working with Claude Code taught me to think differently about problem-solving. Instead of Googling for solutions, I explained my goals and constraints, and we iterated together. The multi-container architecture? That came from discussing the separation of concerns. The security hardening? Claude Code helped me understand the implications of different Docker capabilities.

**Documentation as a Teaching Tool**: Claude Code helped me write the 700+ lines of inline documentation. Not by generating walls of text, but by asking clarifying questions that made me think harder about *why* I made each decision. The act of explaining to an AI made me understand my own architecture better.

**The Config-Driven Approach (v4.0)**: The latest iteration—making services optional and configurable—came from discussing modularity and developer experience with Claude Code. "What if someone doesn't need Playwright?" "How can we make this more flexible?" These conversations led to the elegant `runServices` solution.

**Learning by Teaching**: They say the best way to learn something is to teach it. Working with an AI that asks intelligent questions forced me to articulate concepts I thought I understood. Turns out, I didn't fully understand them until I had to explain them clearly.

The result? I didn't just build a DevContainer. I built a deep understanding of containerization, security, and architecture—because I had to explain every decision to an AI collaborator.

> **💡 Curious about the implementation details?** Check out the [`.devcontainer/` directory](https://github.com/michaelhannecke/claude_in_devcontainer/tree/main/.devcontainer) in the repository to see the full Docker Compose setup, Dockerfiles, and configuration—all documented with the help of Claude Code itself.

## The Security Hardening Journey

Let me tell you about the security rabbit hole I went down.

The original setup used `--cap-add=SYS_ADMIN` and `--ipc=host` to get Playwright working with Chromium. These flags are... let's call them "spicy" from a security perspective.

`SYS_ADMIN` grants near-root privileges and is a well-known container escape vector. `--ipc=host` breaks container isolation by sharing inter-process communication with the host.

The problem? Many Playwright tutorials use these flags because they're easy. They "just work." But they also make security professionals cry.

I spent a week figuring out how to run Chromium in a container *without* these dangerous capabilities. The solution involved:

1. Using `--shm-size=2gb` instead of `--ipc=host` for shared memory
2. Running Chromium with `--no-sandbox` (acceptable in a dev container)
3. Using Xvfb for the virtual display without network listeners
4. Proper user permissions and minimal package installation

The result? A security-hardened setup that passes audit checks while still providing full browser automation capabilities.

### Supply Chain Protection

I also pinned every. single. package. version.

No `^1.2.3`. No `~1.2.3`. Exact versions only:

```python
playwright==1.55.0      # Not 1.55.0 or higher
pytest==7.4.3           # Exactly 7.4.3
black==23.12.1          # No surprises
```

This protects against:

- Malicious package updates
- Typosquatting attacks
- Compromised maintainer accounts
- Unexpected breaking changes

Yes, it means I have to manually update versions. But it also means I sleep soundly knowing my dev environment won't suddenly install a cryptominer because some npm package got compromised.

> **🔒 Want to learn more about the security hardening?** Read the detailed [security documentation in CLAUDE.md](https://github.com/michaelhannecke/claude_in_devcontainer/blob/main/CLAUDE.md#security-considerations) in the repository.

## Real-World Benefits

After using this setup for a month, here's what I've noticed:

### Time Savings

- **Before**: 7-minute rebuilds for any change → avoided making changes → accumulated tech debt
- **After**: 1-minute workspace rebuilds → iterate freely → better code quality

### Resource Usage

- **Before**: 3.5GB monolithic image using 6GB RAM
- **After**: Two services totaling 3.5GB using 5GB RAM (better resource allocation)

### Cognitive Load

- **Before**: "What will break if I update this package?"
- **After**: "Which service needs this package?" (Clear separation of concerns)

### Team Adoption

When I shared this with my team, they were able to get up and running in 10 minutes. Clone the repo, open in VS Code, click "Reopen in Container," and everything just works.

No "works on my machine" issues. No dependency conflicts. No "did you install X?" questions.

## The Things That Surprised Me

### Surprise #1: HTTP Overhead Is Negligible

I was worried about the performance impact of making HTTP calls for every browser operation. Turns out, for typical automation tasks (screenshots, navigation, DOM queries), the overhead is under 10ms per operation.

The limiting factor is still browser rendering, not network communication.

### Surprise #2: Xvfb Is Rock Solid

Virtual displays always seemed fragile to me. But Xvfb in a dedicated container has been completely reliable. I've run thousands of browser automation sessions without a single display-related issue.

### Surprise #3: Docker Compose Is Underrated

I initially thought Docker Compose was just for "toy" multi-container setups. But for development environments, it's perfect. The YAML is readable, the orchestration is simple, and the developer experience is smooth.

Starting two services is as simple as: `docker-compose up -d`

### Surprise #4: People Care About Security

When I wrote detailed security documentation explaining why I removed `SYS_ADMIN`, I expected no one to read it.

Instead, I got emails from developers asking security questions and thanking me for the explanations. Apparently, people *do* want to understand the security implications of their dev environments—they just need someone to explain it clearly.

## Lessons Learned

### 1. **Start with the Architecture**

Don't incrementally add features to a monolithic container until it collapses under its own weight (like I did). Think about service boundaries from the beginning.

Ask: "What are the truly separate concerns in my development environment?"

### 2. **Documentation Is Your Future Self's Best Friend**

I documented *everything*. Every configuration choice, every security decision, every potential pitfall.

Six weeks later, when I needed to troubleshoot an issue, I found the answer in my own documentation. Past Michael saved Future Michael hours of debugging.

### 3. **Pinning Versions Is Worth It**

Yes, it's more work. Yes, you have to manually update. But the peace of mind is worth it.

I've had zero "WTF why did this break?" moments since pinning all package versions.

### 4. **Developer Experience Matters**

The difference between a 7-minute rebuild and a 1-minute rebuild isn't just time—it's whether developers will actually use the tool.

Fast iteration cycles mean people will experiment, try new things, and improve the codebase. Slow iteration cycles mean people avoid making changes.

### 5. **Security Doesn't Have to Be a Tradeoff**

With proper architecture, you can have both security AND functionality. You don't need dangerous capabilities if you design around their need.

## How to Use This

If you want to try this setup (and you should!), I've open-sourced everything on GitHub:

**🔗 Repository: [github.com/michaelhannecke/claude_in_devcontainer](https://github.com/michaelhannecke/claude_in_devcontainer)**

### Quick Start

1. Clone the repository: `git clone https://github.com/michaelhannecke/claude_in_devcontainer.git`
2. Open in VS Code
3. Click "Reopen in Container"
4. Wait 5-10 minutes for initial setup
5. Start using Claude Code with the full environment

### What's in the Repository

- ✅ **Complete Docker Compose setup** - Multi-container orchestration with config-driven optional services
- ✅ **v4.0 Config-Driven Architecture** - Simple `runServices` array to enable/disable services
- ✅ **Remote Playwright client library** - Full HTTP API wrapper for browser automation (optional)
- ✅ **Example scripts and tutorials** - Working examples showing real-world usage
- ✅ **Extensive documentation** - 700+ lines of inline comments explaining every decision
- ✅ **Security audit report** - Detailed security hardening documentation
- ✅ **CLAUDE.md guide** - Architecture overview specifically for AI assistants
- ✅ **Service templates** - Documentation for adding your own optional services

### Use as a Template

You can [use this as a GitHub template](https://github.com/michaelhannecke/claude_in_devcontainer/generate) for your own projects. The architecture is flexible—swap Python for Go, add PostgreSQL, remove Playwright—whatever you need.

The [README](https://github.com/michaelhannecke/claude_in_devcontainer#readme) includes detailed customization instructions.

## The Bigger Picture

This project taught me that **containerization isn't just about isolation—it's about architecture**.

Docker containers are often treated as "VMs but lighter." But they're much more powerful when you think of them as composable building blocks.

Multi-container architectures let you:

- Separate concerns clearly
- Update components independently
- Scale services individually
- Enforce security boundaries
- Create maintainable systems

Yes, it's more complex than a single Dockerfile. But the complexity is *organized* complexity. Each service is simple. The composition is what creates power.

## Conclusion: The Joy of Fast Rebuilds (And AI-Assisted Development)

I'll leave you with this: it's now 2 AM, and I'm staring at my terminal. But this time, I'm not looking at error messages.

I'm watching my workspace container rebuild in 58 seconds after I added a new Python package. The Playwright service is humming along, untouched and unbothered.

Claude Code is helping me refactor some messy code, Jupyter is running a data analysis, and I just built and tested a Docker container for our web service.

Everything works. Everything is isolated. Everything is fast.

And for the first time in a long time, my development environment feels like it's *helping* me instead of *fighting* me.

**But here's the real kicker**: I built this entire environment *with* Claude Code's help. The architecture, the security hardening, the documentation, even this blog post—all created through collaboration with an AI.

Some might say, "But did you really build it if an AI helped?"

I say yes. Because understanding *why* something works is more valuable than typing the code yourself. Because asking good questions is a skill. Because iterating with an intelligent partner—human or AI—is how innovation happens.

I learned more about Docker, security, and architecture through this AI-assisted process than I would have alone. Because teaching (even to an AI) is learning. Because explaining is understanding.

That's the real goal, isn't it? Not just working tools, but *understanding* those tools. Not just fast rebuilds, but *knowing why* they're fast.

And now, you can use this environment too. Learn from it, customize it, build upon it. The repository is open-source, the documentation is extensive, and if you want, you can use Claude Code to help you understand and extend it further.

The future of development isn't human *or* AI. It's human *and* AI, working together to build better systems.

---

## Get Started Today

**🔗 Repository**: [github.com/michaelhannecke/claude_in_devcontainer](https://github.com/michaelhannecke/claude_in_devcontainer)

**📖 Full Documentation**: [README.md](https://github.com/michaelhannecke/claude_in_devcontainer#readme)

**🏗️ Architecture Guide**: [CLAUDE.md](https://github.com/michaelhannecke/claude_in_devcontainer/blob/main/CLAUDE.md)

**💬 Questions or Feedback?** [Open an issue](https://github.com/michaelhannecke/claude_in_devcontainer/issues) or [start a discussion](https://github.com/michaelhannecke/claude_in_devcontainer/discussions) on GitHub.

**⭐ Found this useful?** Give the repo a star and consider using it as a template for your own projects. Let's build better development environments together.

---

**Tags**: #DevContainers #Docker #ClaudeCode #Python #DevOps #DeveloperExperience #AITooling #Playwright #Jupyter
