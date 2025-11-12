#!/usr/bin/env python3
"""
Example 2: Using Context Manager
=================================
Demonstrates using RemotePlaywright with context manager (with statement).

This is the recommended way to use RemotePlaywright as it automatically
handles cleanup, even if errors occur.
"""

import sys
sys.path.insert(0, '/workspaces/claude_in_devcontainer')

from web_ui_optimizer import RemotePlaywright, wait_for_playwright_service

def main():
    # Wait for service
    wait_for_playwright_service(verbose=False)

    # Context manager automatically creates and closes context
    with RemotePlaywright() as pw:
        # Create browser context
        pw.new_context()

        # Navigate and screenshot
        pw.navigate("https://www.python.org")
        pw.screenshot("python-homepage.png", full_page=True)

        print("✅ Screenshot saved!")

    # Context is automatically closed when exiting the with block
    print("✅ Context automatically cleaned up")

if __name__ == "__main__":
    main()
