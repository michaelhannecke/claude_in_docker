#!/usr/bin/env python3
"""
Example 1: Basic Screenshot
============================
Simple example of taking a screenshot using remote Playwright.

This demonstrates:
- Connecting to Playwright service
- Creating a browser context
- Navigating to a URL
- Taking a screenshot
- Closing the context
"""

import sys
sys.path.insert(0, '/workspaces/claude_in_devcontainer')

from web_ui_optimizer import RemotePlaywright, wait_for_playwright_service

def main():
    # Wait for service to be ready
    print("Waiting for Playwright service...")
    wait_for_playwright_service(max_retries=10, delay=1, verbose=False)
    print("✅ Service ready")
    print()

    # Create Playwright client
    pw = RemotePlaywright()

    try:
        # Check service health
        health = pw.health_check()
        print(f"Browser: {health['browser']['version']}")
        print()

        # Create browser context
        print("Creating browser context...")
        context_id = pw.new_context()
        print(f"✅ Context created: {context_id}")
        print()

        # Navigate to URL
        url = "https://example.com"
        print(f"Navigating to {url}...")
        result = pw.navigate(url)
        print(f"✅ Page loaded: {result['title']}")
        print()

        # Take screenshot
        print("Taking screenshot...")
        result = pw.screenshot("example.png", full_page=True)
        print(f"✅ Screenshot saved: {result['path']}")
        print()

        # Close context
        print("Closing context...")
        pw.close()
        print("✅ Context closed")

    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
