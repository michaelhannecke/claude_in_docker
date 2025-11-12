"""
Web UI Optimizer - Remote Playwright Edition
============================================
Browser automation toolkit using remote Playwright service.

This package provides tools for web UI testing, optimization, and analysis
using a Playwright service running in a separate Docker container.

Main Components:
    - RemotePlaywright: Low-level HTTP client for Playwright API
    - UIOptimizer: High-level toolkit for UI testing and optimization
    - Connection utilities: Helper functions for service connectivity

Usage:
    Basic automation:
        from remote_playwright import RemotePlaywright

        with RemotePlaywright() as pw:
            pw.new_context()
            pw.navigate("https://example.com")
            pw.screenshot("output.png")

    UI optimization:
        from ui_optimizer import UIOptimizer

        with UIOptimizer() as optimizer:
            screenshots = optimizer.capture_responsive("https://example.com")
            colors = optimizer.analyze_colors()
            accessibility = optimizer.check_accessibility()

    Connection testing:
        from connection import wait_for_playwright_service, verify_connection

        wait_for_playwright_service()
        verify_connection(verbose=True)
"""

__version__ = "2.0.0"
__author__ = "Claude Code DevContainer Project"

# Export main classes and functions
from .remote_playwright import (
    RemotePlaywright,
    PlaywrightError,
    PlaywrightConnectionError,
    PlaywrightContextError,
    quick_screenshot
)

from .ui_optimizer import UIOptimizer

from .connection import (
    wait_for_playwright_service,
    check_service_health,
    get_service_info,
    verify_connection
)

__all__ = [
    # Main classes
    "RemotePlaywright",
    "UIOptimizer",

    # Exceptions
    "PlaywrightError",
    "PlaywrightConnectionError",
    "PlaywrightContextError",

    # Utility functions
    "quick_screenshot",
    "wait_for_playwright_service",
    "check_service_health",
    "get_service_info",
    "verify_connection",
]
