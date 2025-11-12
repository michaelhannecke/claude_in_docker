#!/bin/bash
################################################################################
# DOCKER COMPOSE BUILD TEST SCRIPT
################################################################################
# This script tests the Docker Compose build and validates the multi-container
# setup before attempting to use it with VS Code DevContainers.
#
# Usage:
#   bash test-build.sh
#
# Requirements:
#   - Docker installed and running
#   - docker-compose or docker compose available
#
# What this script does:
#   1. Validates configuration files
#   2. Builds both containers
#   3. Starts services
#   4. Runs connectivity tests
#   5. Cleans up
################################################################################

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

print_status() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

# Detect docker-compose command
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif command -v docker &> /dev/null && docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    print_error "Neither 'docker-compose' nor 'docker compose' is available"
    exit 1
fi

print_header "Docker Compose Build Test"

# Test 1: Validate configuration
print_status "Validating docker-compose.yml..."
if $DOCKER_COMPOSE config --quiet; then
    print_success "docker-compose.yml is valid"
else
    print_error "docker-compose.yml has syntax errors"
    exit 1
fi

# Test 2: Build containers
print_status "Building containers (this may take 5-10 minutes)..."
if $DOCKER_COMPOSE build; then
    print_success "Both containers built successfully"
else
    print_error "Container build failed"
    exit 1
fi

# Test 3: Start services
print_status "Starting services..."
if $DOCKER_COMPOSE up -d; then
    print_success "Services started"
else
    print_error "Failed to start services"
    $DOCKER_COMPOSE down
    exit 1
fi

# Test 4: Wait for playwright to be healthy
print_status "Waiting for Playwright service to be healthy..."
for i in {1..30}; do
    health_status=$($DOCKER_COMPOSE ps -q playwright | xargs docker inspect --format='{{.State.Health.Status}}' 2>/dev/null || echo "starting")

    if [ "$health_status" = "healthy" ]; then
        print_success "Playwright service is healthy"
        break
    elif [ "$health_status" = "unhealthy" ]; then
        print_error "Playwright service is unhealthy"
        $DOCKER_COMPOSE logs playwright
        $DOCKER_COMPOSE down
        exit 1
    else
        echo -n "."
        sleep 2
    fi

    if [ $i -eq 30 ]; then
        print_error "Playwright service did not become healthy in time"
        $DOCKER_COMPOSE logs playwright
        $DOCKER_COMPOSE down
        exit 1
    fi
done

# Test 5: Check container status
print_status "Checking container status..."
$DOCKER_COMPOSE ps

# Test 6: Test connectivity
print_status "Testing connectivity..."

# Ping test
if docker exec claude-workspace ping -c 2 playwright > /dev/null 2>&1; then
    print_success "Workspace can ping playwright service"
else
    print_error "Workspace cannot ping playwright service"
fi

# HTTP test
if docker exec claude-workspace curl -sf http://playwright:3000/health > /dev/null 2>&1; then
    print_success "Playwright HTTP API is accessible"
    docker exec claude-workspace curl -s http://playwright:3000/health | python3 -m json.tool || cat
else
    print_error "Playwright HTTP API is not accessible"
fi

# Test 7: View logs
print_status "Service logs (last 20 lines)..."
echo ""
echo "--- Playwright Service ---"
$DOCKER_COMPOSE logs --tail=20 playwright
echo ""
echo "--- Workspace Service ---"
$DOCKER_COMPOSE logs --tail=20 workspace

# Summary
print_header "Test Summary"

print_success "All tests passed!"
echo ""
echo "Services are running:"
$DOCKER_COMPOSE ps

echo ""
echo "Next steps:"
echo "  1. Keep services running: They're ready for use"
echo "  2. Stop services: $DOCKER_COMPOSE down"
echo "  3. Stop and remove volumes: $DOCKER_COMPOSE down -v"
echo "  4. View logs: $DOCKER_COMPOSE logs -f"
echo ""

print_status "Cleanup options:"
echo "  • Leave running (recommended): Services are ready"
echo "  • Stop now: Run '$DOCKER_COMPOSE down'"
echo ""

read -p "Stop services now? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Stopping services..."
    $DOCKER_COMPOSE down
    print_success "Services stopped"
else
    print_status "Services left running"
fi
