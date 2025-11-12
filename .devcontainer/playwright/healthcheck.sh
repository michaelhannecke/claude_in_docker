#!/bin/bash
################################################################################
# PLAYWRIGHT SERVICE HEALTH CHECK
################################################################################
# This script is run periodically by Docker to check container health
#
# Health Criteria:
# 1. Xvfb process is running
# 2. Playwright server process is running
# 3. HTTP endpoint responds successfully
# 4. Response indicates healthy status
#
# Exit Codes:
# 0 = Healthy (all checks passed)
# 1 = Unhealthy (one or more checks failed)
#
# Docker will mark container as unhealthy after consecutive failures
# and can restart it based on the restart policy
################################################################################

# ============================================================================
# CONFIGURATION
# ============================================================================
HEALTH_ENDPOINT="http://localhost:3000/health"
TIMEOUT=5  # seconds
DISPLAY_NUM=99

# ============================================================================
# COLOR OUTPUT (for manual testing)
# ============================================================================
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if running in TTY (for colored output)
if [ -t 1 ]; then
    USE_COLOR=true
else
    USE_COLOR=false
fi

print_success() {
    if [ "$USE_COLOR" = true ]; then
        echo -e "${GREEN}✅${NC} $1"
    else
        echo "✅ $1"
    fi
}

print_error() {
    if [ "$USE_COLOR" = true ]; then
        echo -e "${RED}❌${NC} $1"
    else
        echo "❌ $1"
    fi
}

print_warning() {
    if [ "$USE_COLOR" = true ]; then
        echo -e "${YELLOW}⚠${NC} $1"
    else
        echo "⚠ $1"
    fi
}

# ============================================================================
# HEALTH CHECKS
# ============================================================================

# Track overall health status
HEALTH_STATUS=0  # 0 = healthy, 1 = unhealthy

# ----------------------------------------------------------------------------
# Check 1: Xvfb Process Running
# ----------------------------------------------------------------------------
check_xvfb() {
    if pgrep -x "Xvfb" > /dev/null 2>&1; then
        print_success "Xvfb process is running"
        return 0
    else
        print_error "Xvfb process is not running"
        return 1
    fi
}

# ----------------------------------------------------------------------------
# Check 2: Playwright Server Process Running
# ----------------------------------------------------------------------------
check_server_process() {
    if pgrep -f "playwright-server.js" > /dev/null 2>&1; then
        print_success "Playwright server process is running"
        return 0
    else
        print_error "Playwright server process is not running"
        return 1
    fi
}

# ----------------------------------------------------------------------------
# Check 3: HTTP Endpoint Responds
# ----------------------------------------------------------------------------
check_http_endpoint() {
    # Use curl to check if endpoint responds
    # -s: silent mode
    # -f: fail on HTTP error codes
    # -m: maximum time for the request
    # -o /dev/null: discard output
    # -w "%{http_code}": print only HTTP status code

    HTTP_CODE=$(curl -s -f -m "$TIMEOUT" -o /dev/null -w "%{http_code}" "$HEALTH_ENDPOINT" 2>/dev/null)

    if [ $? -eq 0 ] && [ "$HTTP_CODE" = "200" ]; then
        print_success "HTTP endpoint responding (HTTP $HTTP_CODE)"
        return 0
    else
        print_error "HTTP endpoint not responding (HTTP $HTTP_CODE)"
        return 1
    fi
}

# ----------------------------------------------------------------------------
# Check 4: Health Endpoint Returns Healthy Status
# ----------------------------------------------------------------------------
check_health_status() {
    # Get health response and parse JSON
    RESPONSE=$(curl -s -f -m "$TIMEOUT" "$HEALTH_ENDPOINT" 2>/dev/null)

    if [ $? -ne 0 ]; then
        print_error "Failed to get health response"
        return 1
    fi

    # Check if response contains "healthy" status
    # Using grep for simple JSON parsing (avoid dependencies)
    if echo "$RESPONSE" | grep -q '"status"[[:space:]]*:[[:space:]]*"healthy"'; then
        print_success "Service reports healthy status"

        # Extract browser status if available (optional, doesn't affect health)
        if echo "$RESPONSE" | grep -q '"running"[[:space:]]*:[[:space:]]*true'; then
            print_success "Browser is initialized"
        fi

        return 0
    else
        print_error "Service reports unhealthy status"
        return 1
    fi
}

# ============================================================================
# RUN ALL CHECKS
# ============================================================================

# Print header (only if running interactively)
if [ -t 1 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Playwright Service Health Check"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
fi

# Run each check
check_xvfb || HEALTH_STATUS=1
check_server_process || HEALTH_STATUS=1
check_http_endpoint || HEALTH_STATUS=1
check_health_status || HEALTH_STATUS=1

# Print summary (only if running interactively)
if [ -t 1 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [ $HEALTH_STATUS -eq 0 ]; then
        print_success "Overall Status: HEALTHY"
    else
        print_error "Overall Status: UNHEALTHY"
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
fi

# ============================================================================
# EXIT WITH STATUS
# ============================================================================
# Exit code determines Docker health status
# 0 = healthy, 1 = unhealthy

exit $HEALTH_STATUS
