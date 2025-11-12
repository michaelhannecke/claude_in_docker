"""
Remote Playwright Client
========================
Client library for interacting with the Playwright service container.

The Playwright service runs in a separate Docker container and exposes
an HTTP API for browser automation. This client provides a Python interface
to that API.

Usage:
    from remote_playwright import RemotePlaywright

    pw = RemotePlaywright()
    print(pw.health_check())

    pw.new_context()
    pw.navigate("https://example.com")
    pw.screenshot("output.png", full_page=True)
    pw.close()
"""

import os
import requests
from typing import Optional, Dict, Any


class RemotePlaywright:
    """Client for remote Playwright service"""

    def __init__(self, service_url: Optional[str] = None):
        """
        Initialize Playwright client

        Args:
            service_url: URL of Playwright service (default: from env or http://playwright:3000)
        """
        self.service_url = service_url or os.environ.get(
            'PLAYWRIGHT_SERVICE_URL',
            'http://playwright:3000'
        )
        self.context_id: Optional[str] = None

    def health_check(self) -> Dict[str, Any]:
        """
        Check service health

        Returns:
            Health status dictionary
        """
        response = requests.get(f"{self.service_url}/health")
        response.raise_for_status()
        return response.json()

    def new_context(self, options: Optional[Dict[str, Any]] = None) -> str:
        """
        Create new browser context

        Args:
            options: Browser context options (viewport, userAgent, etc.)

        Returns:
            Context ID
        """
        response = requests.post(
            f"{self.service_url}/browser/new",
            json={"options": options or {}}
        )
        response.raise_for_status()
        data = response.json()
        self.context_id = data["contextId"]
        return self.context_id

    def navigate(self, url: str, wait_until: str = "networkidle") -> Dict[str, Any]:
        """
        Navigate to URL

        Args:
            url: URL to navigate to
            wait_until: When to consider navigation complete

        Returns:
            Navigation result
        """
        if not self.context_id:
            raise ValueError("No active context. Call new_context() first.")

        response = requests.post(
            f"{self.service_url}/navigate",
            json={
                "contextId": self.context_id,
                "url": url,
                "waitUntil": wait_until
            }
        )
        response.raise_for_status()
        return response.json()

    def screenshot(
        self,
        path: str,
        full_page: bool = False,
        type: str = "png"
    ) -> Dict[str, Any]:
        """
        Take screenshot

        Args:
            path: Filename for screenshot
            full_page: Capture full scrollable page
            type: Image type (png, jpeg)

        Returns:
            Screenshot result
        """
        if not self.context_id:
            raise ValueError("No active context. Call new_context() first.")

        response = requests.post(
            f"{self.service_url}/screenshot",
            json={
                "contextId": self.context_id,
                "path": path,
                "fullPage": full_page,
                "type": type
            }
        )
        response.raise_for_status()
        return response.json()

    def evaluate(self, script: str) -> Dict[str, Any]:
        """
        Execute JavaScript in page context

        Args:
            script: JavaScript code to execute

        Returns:
            Evaluation result
        """
        if not self.context_id:
            raise ValueError("No active context. Call new_context() first.")

        response = requests.post(
            f"{self.service_url}/evaluate",
            json={
                "contextId": self.context_id,
                "script": script
            }
        )
        response.raise_for_status()
        return response.json()

    def close(self) -> Dict[str, Any]:
        """
        Close browser context

        Returns:
            Close result
        """
        if not self.context_id:
            raise ValueError("No active context to close.")

        response = requests.post(
            f"{self.service_url}/browser/{self.context_id}/close"
        )
        response.raise_for_status()
        result = response.json()

        self.context_id = None
        return result


if __name__ == "__main__":
    # Example usage
    pw = RemotePlaywright()
    print("Health check:", pw.health_check())
    print("\nTo use:")
    print("  pw = RemotePlaywright()")
    print("  pw.new_context()")
    print("  pw.navigate('https://example.com')")
    print("  pw.screenshot('example.png', full_page=True)")
    print("  pw.close()")
