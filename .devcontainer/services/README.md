# Optional Services

This directory contains optional services that can be enabled/disabled via `.devcontainer/.env` configuration.

## Available Services

### Playwright (Browser Automation)
**Status**: ✅ Available
**Location**: `services/playwright/`
**Enable**: Set `ENABLE_PLAYWRIGHT=true` in `.env`

Browser automation service with Chromium via HTTP API.

**Use cases**:
- Web scraping
- UI testing
- Screenshot capture
- Web automation workflows

**Access**: `http://playwright:3000` from workspace container

### FastAPI (Future)
**Status**: 🚧 Template (not yet implemented)
**Enable**: Set `ENABLE_FASTAPI=true` in `.env`

FastAPI development server with hot reload.

### MCP Server (Future)
**Status**: 🚧 Template (not yet implemented)
**Enable**: Set `ENABLE_MCP=true` in `.env`

Model Context Protocol server for AI/ML integration.

---

## Adding a New Service

Follow these 3 steps to add a new optional service:

### Step 1: Add Configuration

Edit `.devcontainer/.env`:

```bash
# Add your new service
ENABLE_MYSERVICE=false
MYSERVICE_PORT=9000
```

Edit `.devcontainer/.env.example` (same changes for documentation)

### Step 2: Update Profile Script

Edit `.devcontainer/init-profiles.sh`, add profile conversion logic:

```bash
# MyService
if [[ "${ENABLE_MYSERVICE}" == "true" ]]; then
    MYSERVICE_PROFILE="myservice"
    print_success "MyService: ENABLED"
else
    MYSERVICE_PROFILE="disabled"
    print_info "MyService: disabled"
fi
```

And update the `.env.profiles` generation section:

```bash
# Service Profiles
PLAYWRIGHT_PROFILE=${PLAYWRIGHT_PROFILE}
FASTAPI_PROFILE=${FASTAPI_PROFILE}
MCP_PROFILE=${MCP_PROFILE}
MYSERVICE_PROFILE=${MYSERVICE_PROFILE}  # Add this line

# Port Configuration
PLAYWRIGHT_PORT=${PLAYWRIGHT_PORT:-3000}
FASTAPI_PORT=${FASTAPI_PORT:-8000}
MCP_PORT=${MCP_PORT:-8080}
MYSERVICE_PORT=${MYSERVICE_PORT:-9000}  # Add this line
```

### Step 3: Add Service to docker-compose.yml

Add service definition to `.devcontainer/docker-compose.yml`:

```yaml
  myservice:
    # Load environment variables
    env_file:
      - .env.profiles

    # Docker Compose Profile (only starts if enabled)
    profiles:
      - ${MYSERVICE_PROFILE:-disabled}

    # Build configuration
    build:
      context: services/myservice
      dockerfile: Dockerfile

    # Container name
    container_name: claude-myservice

    # Hostname for internal DNS
    hostname: myservice

    # Volumes (if needed)
    volumes:
      - myservice_data:/data

    # Environment variables
    environment:
      - SERVICE_PORT=${MYSERVICE_PORT:-9000}

    # Networking
    networks:
      - playwright-network

    # Expose port (internal only)
    expose:
      - "${MYSERVICE_PORT:-9000}"

    # Health check (optional)
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:${MYSERVICE_PORT:-9000}/health"]
      interval: 30s
      timeout: 10s
      retries: 3

    # Restart policy
    restart: unless-stopped
```

Don't forget to add the volume to the volumes section at the bottom:

```yaml
volumes:
  # ... existing volumes ...

  myservice_data:
    name: claude-myservice-data
    driver: local
```

### Step 4: Create Service Directory

```bash
mkdir -p .devcontainer/services/myservice
cd .devcontainer/services/myservice
```

Create `Dockerfile`:

```dockerfile
FROM your-base-image:latest

# Install dependencies
RUN apt-get update && apt-get install -y \\
    your-dependencies \\
    && rm -rf /var/lib/apt/lists/*

# Copy application files
COPY . /app
WORKDIR /app

# Expose port
EXPOSE 9000

# Start command
CMD ["your-start-command"]
```

### Step 5: Test

```bash
# Enable the service
echo "ENABLE_MYSERVICE=true" >> .devcontainer/.env

# Generate profiles
bash .devcontainer/init-profiles.sh

# Verify configuration
docker-compose config

# Start services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f myservice
```

---

## Service Templates

### FastAPI Service Template

```yaml
fastapi:
  env_file:
    - .env.profiles
  profiles:
    - ${FASTAPI_PROFILE:-disabled}
  build:
    context: services/fastapi
    dockerfile: Dockerfile
  container_name: claude-fastapi
  hostname: fastapi
  volumes:
    - ../..:/workspaces/claude_in_devcontainer:cached
  environment:
    - FASTAPI_PORT=${FASTAPI_PORT:-8000}
  networks:
    - playwright-network
  ports:
    - "${FASTAPI_PORT:-8000}:${FASTAPI_PORT:-8000}"
  command: uvicorn main:app --host 0.0.0.0 --port ${FASTAPI_PORT:-8000} --reload
  restart: unless-stopped
```

### PostgreSQL Database Template

```yaml
postgres:
  env_file:
    - .env.profiles
  profiles:
    - ${POSTGRES_PROFILE:-disabled}
  image: postgres:16-alpine
  container_name: claude-postgres
  hostname: postgres
  environment:
    - POSTGRES_USER=dev
    - POSTGRES_PASSWORD=dev
    - POSTGRES_DB=devdb
  volumes:
    - postgres_data:/var/lib/postgresql/data
  networks:
    - playwright-network
  expose:
    - "5432"
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U dev"]
    interval: 10s
    timeout: 5s
    retries: 5
  restart: unless-stopped
```

### Redis Cache Template

```yaml
redis:
  env_file:
    - .env.profiles
  profiles:
    - ${REDIS_PROFILE:-disabled}
  image: redis:7-alpine
  container_name: claude-redis
  hostname: redis
  volumes:
    - redis_data:/data
  networks:
    - playwright-network
  expose:
    - "6379"
  healthcheck:
    test: ["CMD", "redis-cli", "ping"]
    interval: 10s
    timeout: 3s
    retries: 3
  restart: unless-stopped
```

---

## Best Practices

1. **Isolation**: Keep each service in its own directory under `services/`
2. **Health Checks**: Add health checks for reliable startup ordering
3. **Internal Networking**: Use `expose` instead of `ports` for internal services
4. **Resource Limits**: Set CPU and memory limits in production
5. **Documentation**: Update this README when adding new services
6. **Naming**: Use consistent naming: `ENABLE_X`, `X_PROFILE`, `X_PORT`
7. **Defaults**: Provide sensible defaults in profile generation
8. **Testing**: Test both enabled and disabled states

---

## Troubleshooting

### Service not starting

```bash
# Check if profile is enabled
cat .devcontainer/.env.profiles | grep YOUR_SERVICE

# Verify docker-compose syntax
docker-compose config

# Check service logs
docker-compose logs your-service

# Force recreate
docker-compose up -d --force-recreate your-service
```

### Profile not applying

```bash
# Regenerate profiles
bash .devcontainer/init-profiles.sh

# Verify .env file
cat .devcontainer/.env

# Check generated profiles
cat .devcontainer/.env.profiles
```

### Container can't reach service

```bash
# Check network
docker network inspect playwright-network

# Test connectivity from workspace
docker exec claude-workspace ping -c 2 your-service
docker exec claude-workspace curl http://your-service:PORT/health
```

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│ Docker Compose Stack (Config-Driven)                    │
│                                                          │
│  ┌────────────────────────────────────────────────┐    │
│  │ workspace (ALWAYS)                             │    │
│  │ Core: Python, Jupyter, Docker CLI              │    │
│  └────────────────────────────────────────────────┘    │
│                         ↕                               │
│             playwright-network (bridge)                 │
│                         ↕                               │
│  ┌────────────────────────────────────────────────┐    │
│  │ playwright (if ENABLE_PLAYWRIGHT=true)         │    │
│  │ Browser automation service                     │    │
│  └────────────────────────────────────────────────┘    │
│                         ↕                               │
│  ┌────────────────────────────────────────────────┐    │
│  │ fastapi (if ENABLE_FASTAPI=true)               │    │
│  │ FastAPI development server                     │    │
│  └────────────────────────────────────────────────┘    │
│                         ↕                               │
│  ┌────────────────────────────────────────────────┐    │
│  │ mcp-server (if ENABLE_MCP=true)                │    │
│  │ MCP protocol server                            │    │
│  └────────────────────────────────────────────────┘    │
│                                                          │
│  Configuration: .devcontainer/.env                      │
│  Profiles: .devcontainer/.env.profiles (auto-generated) │
└─────────────────────────────────────────────────────────┘
```

---

**End of Services README**
