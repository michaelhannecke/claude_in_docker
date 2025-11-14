# How I Used Claude Code to Build a Better DevContainer for Claude Code (Meta, Right?)

![Claude Code in DevContainer](data/claude-in-devcontainer-cosy.png)

🤖 **Full transparency**: I built this entire project WITH Claude Code's help. Using AI to build better AI tooling? That's where things get interesting.

## The Problem

I wanted to use Claude Code (Anthropic's AI coding assistant) in a containerized environment. Classic developer mistake: I kept adding "just one more thing."

Python? Check. Jupyter? Sure. Playwright? Why not. Docker-in-Docker? Obviously!

**The result?** A 3.5GB monolithic container that took 7 minutes to rebuild. Every. Single. Time.

The slow feedback loop was killing my productivity. I avoided making changes just to dodge those painful waits.

## The Solution (Co-Created with Claude Code)

Working with Claude Code, we designed a **multi-container architecture** with **optional services** (v4.0):

### 🔧 Workspace Container (~2GB, always on)
- Python 3.12 + Jupyter + Claude Code CLI
- Docker support (DooD)
- **Build time: 1 minute** (85% faster!)

### 🌐 Playwright Container (~1.5GB, OPTIONAL)
- Enable with one line: `"runServices": ["workspace", "playwright"]`
- Only runs when you need browser automation
- HTTP API for remote control
- **Rebuild frequency: Almost never**

The breakthrough? **Config-driven optional services**. Don't need Playwright? Don't run it. Want to add PostgreSQL? Just add it to the array.

## The Results

**Before:**
- ⏱️ 7-minute rebuilds for any change
- 🤦 Avoided making improvements due to slow feedback
- 💾 3.5GB monolithic image
- 🔄 Tech debt accumulated

**After:**
- ⚡ 1-minute workspace rebuilds (85% faster)
- 🚀 Iterate freely without fear
- 📦 Better resource allocation across services
- 🎯 Clear separation of concerns

## What Makes This Special

✨ **Optional services** - Only run what you need
⚡ **85% faster rebuilds** - 1 minute vs 7 minutes
🔒 **Security hardened** - Removed `SYS_ADMIN` and other dangerous capabilities
🤖 **AI-assisted development** - Built with Claude Code, documented with Claude Code
📚 **Extensively documented** - 700+ lines explaining every decision
🎯 **Production-ready** - Pinned versions, security audit, real-world tested

## The AI Collaboration Angle

Here's what surprised me: **Working with Claude Code to build this taught me as much as building it.**

- Explaining architecture decisions to an AI forced me to think deeper
- The documentation improved because I had to articulate the "why"
- The v4.0 config-driven approach came from discussing modularity with Claude Code

Teaching an AI is learning. This wasn't just "AI wrote my code"—it was collaborative problem-solving that made me a better engineer.

## 📖 Want the Full Story?

I wrote a detailed article about:
- The architecture decisions and why they matter
- How Claude Code helped solve each problem
- Security hardening deep-dive
- The learning journey of AI-assisted development
- Complete technical implementation details

**👉 Read the full article:** [How I Built a Multi-Container DevContainer for Claude Code](https://medium.com/@michaelhannecke) *(medium.md)*

The article includes code examples, architecture diagrams, and lessons learned that won't fit in a LinkedIn post.

## 🔗 Open Source Repository

Everything is open-source on GitHub:

✅ v4.0 config-driven Docker Compose setup
✅ Optional Playwright HTTP API & Python client
✅ Working examples and tutorials
✅ 700+ lines of inline documentation
✅ Security audit and hardening guide
✅ Service templates for adding your own services

**GitHub:** [github.com/michaelhannecke/claude_in_devcontainer](https://github.com/michaelhannecke/claude_in_devcontainer)

---

## Quick Start

```bash
git clone https://github.com/michaelhannecke/claude_in_devcontainer.git
cd claude_in_devcontainer
code .  # Click "Reopen in Container"
```

5-10 minutes later: Complete dev environment with Claude Code, Python, Jupyter, Docker, and optional browser automation.

---

## Let's Discuss

**Have you used AI tools to build better dev environments?**

I'm curious about your experiences with AI-assisted development. Does working with AI make you a better engineer, or does it just make you faster?

**Read the full article** to see how this played out in my project, and drop your thoughts in the comments.

👉 **Medium article:** *(link to medium.md when published)*
⭐ **GitHub repo:** [claude_in_devcontainer](https://github.com/michaelhannecke/claude_in_devcontainer)

If you found this interesting, give the repo a star and share it with your team!

---

#DevContainers #Docker #ClaudeCode #AIAssistedDevelopment #DevOps #Python #DeveloperExperience #AITools #SoftwareEngineering #Productivity #MachineLearning
