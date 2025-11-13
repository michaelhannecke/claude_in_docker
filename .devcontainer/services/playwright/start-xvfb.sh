#!/bin/bash
################################################################################
# XVFB AND PLAYWRIGHT SERVER STARTUP SCRIPT
################################################################################
# This script starts both Xvfb (virtual display) and the Playwright HTTP server
#
# Process Management:
# 1. Start Xvfb in background
# 2. Wait for Xvfb to initialize
# 3. Start Playwright server in background
# 4. Wait for both processes (keeps container running)
#
# Exit Handling:
# - If either process dies, the script exits
# - Container orchestration (Docker Compose) can restart if needed
# - Graceful shutdown on SIGTERM/SIGINT
################################################################################

set -e  # Exit on error

# ============================================================================
# COLOR OUTPUT
# ============================================================================
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
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

# ============================================================================
# DISPLAY CONFIGURATION
# ============================================================================
DISPLAY_NUM=99
DISPLAY_RESOLUTION="1920x1080x24"
XVFB_DISPLAY=":${DISPLAY_NUM}"

export DISPLAY="${XVFB_DISPLAY}"

# ============================================================================
# CLEANUP HANDLER
# ============================================================================
cleanup() {
    print_warning "Received shutdown signal, cleaning up..."

    # Kill Playwright server if running
    if [ ! -z "$SERVER_PID" ]; then
        print_info "Stopping Playwright server (PID: $SERVER_PID)..."
        kill -TERM "$SERVER_PID" 2>/dev/null || true
        wait "$SERVER_PID" 2>/dev/null || true
    fi

    # Kill Xvfb if running
    if [ ! -z "$XVFB_PID" ]; then
        print_info "Stopping Xvfb (PID: $XVFB_PID)..."
        kill -TERM "$XVFB_PID" 2>/dev/null || true
        wait "$XVFB_PID" 2>/dev/null || true
    fi

    print_success "Cleanup complete"
    exit 0
}

# Trap signals for graceful shutdown
trap cleanup SIGTERM SIGINT SIGQUIT

# ============================================================================
# START XVFB (VIRTUAL DISPLAY)
# ============================================================================
print_info "Starting Xvfb virtual display..."
print_info "Display: ${XVFB_DISPLAY}"
print_info "Resolution: ${DISPLAY_RESOLUTION}"

# Clean up stale lock files from previous runs
# This prevents "Server is already active for display 99" errors
if [ -f "/tmp/.X${DISPLAY_NUM}-lock" ]; then
    print_warning "Removing stale Xvfb lock file..."
    rm -f "/tmp/.X${DISPLAY_NUM}-lock"
fi

# Clean up stale X11 socket files
if [ -S "/tmp/.X11-unix/X${DISPLAY_NUM}" ]; then
    print_warning "Removing stale X11 socket..."
    rm -f "/tmp/.X11-unix/X${DISPLAY_NUM}"
fi

# Start Xvfb in background
# Options:
#   :99                    - Display number
#   -screen 0 1920x1080x24 - Screen 0, resolution 1920x1080, 24-bit color
#   -nolisten tcp          - Don't listen on TCP (security)
#   -nolisten unix         - Don't listen on Unix socket (security)
#   -ac                    - Disable access control (allow all clients)
Xvfb "${XVFB_DISPLAY}" \
    -screen 0 "${DISPLAY_RESOLUTION}" \
    -nolisten tcp \
    -nolisten unix \
    -ac &

XVFB_PID=$!

# Wait for Xvfb to start
print_info "Waiting for Xvfb to initialize..."
sleep 3

# Verify Xvfb is running
if ps -p $XVFB_PID > /dev/null 2>&1; then
    print_success "Xvfb started successfully (PID: $XVFB_PID)"
else
    print_error "Xvfb failed to start"
    exit 1
fi

# Verify DISPLAY is set
print_info "DISPLAY environment variable: $DISPLAY"

# ============================================================================
# START PLAYWRIGHT SERVER
# ============================================================================
print_info "Starting Playwright HTTP server..."

# Change to application directory
cd /app

# Start Playwright server in background
node /app/playwright-server.js &
SERVER_PID=$!

# Wait for server to start
print_info "Waiting for Playwright server to initialize..."
sleep 5

# Verify server is running
if ps -p $SERVER_PID > /dev/null 2>&1; then
    print_success "Playwright server started successfully (PID: $SERVER_PID)"
else
    print_error "Playwright server failed to start"
    kill -TERM "$XVFB_PID" 2>/dev/null || true
    exit 1
fi

# ============================================================================
# HEALTH CHECK
# ============================================================================
print_info "Performing initial health check..."
sleep 2

if curl -sf http://localhost:3000/health > /dev/null 2>&1; then
    print_success "Health check passed - Server is responding"
else
    print_warning "Health check failed - Server may still be initializing"
fi

# ============================================================================
# STATUS SUMMARY
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "Playwright Service Started"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_info "Xvfb PID:          $XVFB_PID"
print_info "Server PID:        $SERVER_PID"
print_info "Display:           $DISPLAY"
print_info "API endpoint:      http://0.0.0.0:3000"
print_info "Health check:      http://0.0.0.0:3000/health"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ============================================================================
# KEEP CONTAINER RUNNING
# ============================================================================
# Wait for both processes
# If either exits, the script will exit
# This allows Docker to detect container failure and restart if configured
print_info "Container running - waiting for processes..."

# Wait for both processes and exit if either one terminates
wait -n $XVFB_PID $SERVER_PID

# If we reach here, one of the processes has exited
EXIT_CODE=$?

if ps -p $XVFB_PID > /dev/null 2>&1; then
    print_error "Playwright server exited unexpectedly"
    kill -TERM "$XVFB_PID" 2>/dev/null || true
else
    print_error "Xvfb exited unexpectedly"
    kill -TERM "$SERVER_PID" 2>/dev/null || true
fi

exit $EXIT_CODE
