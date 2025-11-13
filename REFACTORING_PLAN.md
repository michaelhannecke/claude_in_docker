# 🎯 Refactoring Plan: Config-Driven Optional Services

**Date**: 2025-11-13
**Branch**: `feature/config-driven-services`
**Objective**: Transform multi-container DevContainer into a modular, config-driven system where optional services (Playwright, FastAPI, MCP) can be easily enabled/disabled via a simple configuration file.

---

## 📋 Pre-Refactoring Checklist

- ✅ Git repo is clean (no uncommitted changes)
- ✅ Feature branch created: `feature/config-driven-services`
- ✅ Current structure documented
- ⚠️ **Action Required**: Test current setup works before starting

---

## 🎨 Overview of Changes

### What Changes

1. Add `.env` configuration file for service activation
2. Add `init-profiles.sh` script for dynamic profile loading
3. Restructure directories: `playwright/` → `services/playwright/`
4. Update `docker-compose.yml` to use Docker Compose profiles
5. Update `devcontainer.json` to run init script
6. Simplify and update documentation

### What Stays the Same

- ✅ All Dockerfiles (no changes to container builds)
- ✅ All service functionality (Playwright still works identically)
- ✅ Volume configuration
- ✅ Network configuration
- ✅ Post-create scripts
- ✅ **No breaking changes for existing users**

---

## 📝 Detailed Step-by-Step Plan

### **Phase 1: Backup & Preparation** (5 minutes)

#### Step 1.1: Create backup branch
```bash
git checkout -b backup/before-modular-refactor
git push origin backup/before-modular-refactor
git checkout feature/config-driven-services
```

#### Step 1.2: Document current state
```bash
docker-compose ps > .devcontainer/state-before.txt
docker images | grep claude >> .devcontainer/state-before.txt
```

**Checkpoint**: ✅ Backups created, ready to proceed

---

### **Phase 2: Directory Restructuring** (10 minutes)

#### Step 2.1: Create new directory structure
```bash
mkdir -p .devcontainer/services
```

#### Step 2.2: Move Playwright to services directory
```bash
git mv .devcontainer/playwright .devcontainer/services/playwright
```

#### Step 2.3: Workspace stays at current location
```bash
# No action - .devcontainer/workspace stays as-is (it's the core)
```

**Checkpoint**: ✅ Directory structure matches new architecture

---

### **Phase 3: Create Configuration System** (15 minutes)

#### Step 3.1: Create `.devcontainer/.env` file
```bash
# Configuration file with ENABLE_* flags for each service
# ENABLE_PLAYWRIGHT=true    # Browser automation
# ENABLE_FASTAPI=false      # FastAPI server (future)
# ENABLE_MCP=false          # MCP server (future)
```

#### Step 3.2: Create `.devcontainer/.env.example`
```bash
cp .devcontainer/.env .devcontainer/.env.example
```

#### Step 3.3: Update `.gitignore`
```bash
echo ".devcontainer/.env.profiles" >> .gitignore
echo ".devcontainer/state-*.txt" >> .gitignore
```

#### Step 3.4: Create `init-profiles.sh` script skeleton
```bash
touch .devcontainer/init-profiles.sh
chmod +x .devcontainer/init-profiles.sh
```

**Checkpoint**: ✅ Configuration files created

---

### **Phase 4: Implement Profile System** (20 minutes)

#### Step 4.1: Write `init-profiles.sh` script
- Read `.env` file
- Convert `ENABLE_*` to `*_PROFILE` variables
- Generate `.env.profiles` for docker-compose
- Add error handling and validation

#### Step 4.2: Update `docker-compose.yml`
- Add `env_file` reference to `.env.profiles`
- Update playwright service with `profiles: ["${PLAYWRIGHT_PROFILE:-disabled}"]`
- Update paths: `playwright` → `services/playwright`
- Make workspace dependency on playwright conditional

#### Step 4.3: Update `devcontainer.json`
- Add `initializeCommand: "bash .devcontainer/init-profiles.sh"`
- Update comments to explain new system
- Keep all other settings unchanged

**Checkpoint**: ✅ Profile system implemented

---

### **Phase 5: Testing & Validation** (15 minutes)

#### Step 5.1: Test with Playwright ENABLED
```bash
# Set ENABLE_PLAYWRIGHT=true in .env
bash .devcontainer/init-profiles.sh
cat .devcontainer/.env.profiles  # Verify PLAYWRIGHT_PROFILE=playwright
docker-compose config  # Validate compose file syntax
docker-compose up -d  # Start services
docker-compose ps  # Verify both containers running
curl http://localhost:3000/health || curl http://playwright:3000/health
```

#### Step 5.2: Test with Playwright DISABLED
```bash
# Set ENABLE_PLAYWRIGHT=false in .env
docker-compose down
bash .devcontainer/init-profiles.sh
cat .devcontainer/.env.profiles  # Verify PLAYWRIGHT_PROFILE=disabled
docker-compose up -d  # Start services
docker-compose ps  # Verify only workspace running
```

#### Step 5.3: Test in VS Code DevContainer
```bash
# Open in VS Code
# Cmd+Shift+P → "Dev Containers: Reopen in Container"
# Verify:
# - Container builds successfully
# - Python venv works
# - Playwright service starts (if enabled)
# - All tools available (python, node, claude, docker)
```

**Checkpoint**: ✅ All tests pass

---

### **Phase 6: Documentation Update** (20 minutes)

#### Step 6.1: Update `CLAUDE.md`
- Add "Service Configuration" section at top
- Update architecture diagrams
- Update workflow instructions
- Simplify common commands section

#### Step 6.2: Update `QUICK_REFERENCE.md`
- Add service enable/disable instructions
- Update troubleshooting section
- Add examples for each service

#### Step 6.3: Create `services/README.md`
- Document how to add new services
- Provide templates for common services
- Examples: FastAPI, MCP, PostgreSQL, Redis

#### Step 6.4: Update root `README.md`
- Add quick start with service configuration
- Update screenshots/examples if any

**Checkpoint**: ✅ Documentation complete

---

### **Phase 7: Future Service Templates** (Optional - 30 minutes)

**Status**: SKIPPED in initial implementation (can add later)

#### Step 7.1: Create FastAPI service template
```bash
mkdir -p .devcontainer/services/fastapi
# Create Dockerfile, main.py, requirements.txt
```

#### Step 7.2: Create MCP service template
```bash
mkdir -p .devcontainer/services/mcp
# Create Dockerfile, server.py
```

#### Step 7.3: Add to docker-compose.yml
```yaml
fastapi:
  profiles: ["${FASTAPI_PROFILE:-disabled}"]
  # ... config

mcp-server:
  profiles: ["${MCP_PROFILE:-disabled}"]
  # ... config
```

**Checkpoint**: ⏭️ Skipped for now

---

### **Phase 8: Cleanup & Finalization** (10 minutes)

#### Step 8.1: Remove temporary files
```bash
rm -f .devcontainer/state-before.txt
```

#### Step 8.2: Run final validation
```bash
docker-compose down -v
docker-compose up -d
docker-compose ps
# Verify everything works
```

#### Step 8.3: Git commit
```bash
git add .devcontainer/
git add .gitignore
git add REFACTORING_PLAN.md
git commit -m "Refactor: Add config-driven optional services

- Add .env configuration for enabling/disabling services
- Implement Docker Compose profiles system
- Restructure: playwright → services/playwright
- Add init-profiles.sh for dynamic profile loading
- Update documentation for new workflow
- Maintain backward compatibility (Playwright still works)

Breaking changes: None
New features: Easy service activation via config file
"
```

#### Step 8.4: Push feature branch
```bash
git push origin feature/config-driven-services
```

**Checkpoint**: ✅ Refactoring complete

---

## 🔄 Rollback Strategy

If something goes wrong at any phase:

### Option 1: Rollback to backup branch
```bash
git checkout backup/before-modular-refactor
docker-compose down
docker-compose up -d
```

### Option 2: Rollback specific files
```bash
# Restore just docker-compose.yml
git checkout main -- .devcontainer/docker-compose.yml

# Restore directory structure
git mv .devcontainer/services/playwright .devcontainer/playwright
```

### Option 3: Full reset to main
```bash
git checkout main
git branch -D feature/config-driven-services
git clean -fd
docker-compose down -v
docker-compose up -d
```

---

## 📊 Estimated Timeline

| Phase | Duration | Can Skip? |
|-------|----------|-----------|
| Phase 1: Backup | 5 min | No |
| Phase 2: Directory | 10 min | No |
| Phase 3: Config Files | 15 min | No |
| Phase 4: Implementation | 20 min | No |
| Phase 5: Testing | 15 min | No |
| Phase 6: Documentation | 20 min | Partial |
| Phase 7: Templates | 30 min | **Yes** ✅ |
| Phase 8: Cleanup | 10 min | No |

**Total**: ~90 minutes (Phase 7 skipped)

---

## ⚠️ Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Docker Compose syntax error | Low | High | Validate with `docker-compose config` |
| Path references break | Medium | High | Test both enabled/disabled states |
| VS Code can't connect | Low | High | Test in VS Code before committing |
| Git conflicts | Low | Low | Working on feature branch |
| Lost work | Very Low | High | Backup branch + feature branch |

---

## 🎯 Success Criteria

- ✅ User can enable/disable Playwright by editing `.env`
- ✅ Core workspace starts fast regardless of optional services
- ✅ All existing functionality preserved
- ✅ Easy to add new services (documented 3-step process)
- ✅ Documentation clear and concise
- ✅ No breaking changes for existing users
- ✅ Git history clean with good commit message

---

## 📐 Architecture Comparison

### Before: Always-On Multi-Container
```
workspace (always)  ←→  playwright (always)
```

### After: Config-Driven Modular
```
workspace (always)  ←→  playwright (if ENABLE_PLAYWRIGHT=true)
                    ←→  fastapi (if ENABLE_FASTAPI=true)
                    ←→  mcp-server (if ENABLE_MCP=true)
```

---

## 🔑 Key Files Modified

- `.devcontainer/.env` - **NEW** - Service configuration
- `.devcontainer/.env.example` - **NEW** - Configuration template
- `.devcontainer/init-profiles.sh` - **NEW** - Profile initialization
- `.devcontainer/docker-compose.yml` - **MODIFIED** - Add profiles
- `.devcontainer/devcontainer.json` - **MODIFIED** - Add initializeCommand
- `.devcontainer/playwright/` → `.devcontainer/services/playwright/` - **MOVED**
- `.gitignore` - **MODIFIED** - Ignore .env.profiles
- `CLAUDE.md` - **MODIFIED** - Updated documentation
- `QUICK_REFERENCE.md` - **MODIFIED** - Updated documentation
- `REFACTORING_PLAN.md` - **NEW** - This file

---

## 📝 Notes

- Docker Compose profiles feature requires Docker Compose v1.28+ (widely available)
- `.env` file is gitignored by default, but `.env.example` is committed
- Each developer can customize their own service configuration
- Services remain isolated in separate containers (architectural benefit maintained)
- Future services follow same pattern: add to .env, init script, and docker-compose

---

## ✅ Completion Checklist

After implementation, verify:

- [ ] `.env` file controls service activation
- [ ] `bash .devcontainer/init-profiles.sh` generates `.env.profiles`
- [ ] `docker-compose up` starts only enabled services
- [ ] Playwright works when enabled
- [ ] Workspace starts without Playwright when disabled
- [ ] VS Code DevContainer works with both configurations
- [ ] Documentation updated and accurate
- [ ] All tests pass
- [ ] Git history clean
- [ ] Feature branch pushed to remote

---

**End of Refactoring Plan**
