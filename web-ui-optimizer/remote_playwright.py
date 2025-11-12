"""
Remote Playwright Client
========================
Client library for interacting with the Playwright browser automation service.

The Playwright service runs in a separate Docker container and exposes an HTTP
API for browser automation. This client provides a Python interface to that API.

Architecture:
    - Playwright service: http://playwright:3000
    - HTTP/REST API for browser control
    - Isolated browser contexts per session
    - Artifact storage (screenshots, videos, traces)

Usage:
    Basic usage:
        from remote_playwright import RemotePlaywright

        pw = RemotePlaywright()
        print(pw.health_check())

        pw.new_context()
        pw.navigate("https://example.com")
        pw.screenshot("output.png", full_page=True)
        pw.close()

    Context manager:
        with RemotePlaywright() as pw:
            pw.new_context()
            pw.navigate("https://example.com")
            pw.screenshot("output.png")
            # Automatically closes context

    Custom options:
        pw = RemotePlaywright(service_url="http://custom-playwright:3000")
        pw.new_context(options={
            "viewport": {"width": 1280, "height": 720},
            "userAgent": "Custom User Agent"
        })
"""

import os
import json
import requests
from typing import Optional, Dict, Any, List
from urllib.parse import urljoin


class PlaywrightError(Exception):
    """Base exception for Playwright client errors"""
    pass


class PlaywrightConnectionError(PlaywrightError):
    """Raised when cannot connect to Playwright service"""
    pass


class PlaywrightContextError(PlaywrightError):
    """Raised when browser context operations fail"""
    pass


class RemotePlaywright:
    """
    Client for remote Playwright browser automation service

    This client communicates with a Playwright service running in a separate
    container via HTTP API. It manages browser contexts and provides methods
    for common automation tasks.

    Attributes:
        service_url (str): URL of the Playwright service
        context_id (str): ID of the current browser context (if any)
        timeout (int): Request timeout in seconds
    """

    def __init__(
        self,
        service_url: Optional[str] = None,
        timeout: int = 30
    ):
        """
        Initialize Playwright client

        Args:
            service_url: URL of Playwright service
                        Default: from PLAYWRIGHT_SERVICE_URL env or http://playwright:3000
            timeout: Request timeout in seconds (default: 30)

        Raises:
            PlaywrightConnectionError: If service URL is invalid
        """
        self.service_url = service_url or os.environ.get(
            'PLAYWRIGHT_SERVICE_URL',
            'http://playwright:3000'
        )
        self.context_id: Optional[str] = None
        self.timeout = timeout

        # Ensure URL doesn't end with slash
        self.service_url = self.service_url.rstrip('/')

    def __enter__(self):
        """Context manager entry"""
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit - closes context if open"""
        if self.context_id:
            try:
                self.close()
            except Exception:
                pass  # Ignore errors during cleanup

    def _request(
        self,
        method: str,
        endpoint: str,
        json_data: Optional[Dict[str, Any]] = None,
        params: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """
        Make HTTP request to Playwright service

        Args:
            method: HTTP method (GET, POST, etc.)
            endpoint: API endpoint (e.g., '/health')
            json_data: JSON payload for POST requests
            params: Query parameters

        Returns:
            Response data as dictionary

        Raises:
            PlaywrightConnectionError: If connection fails
            PlaywrightError: If API returns error
        """
        url = urljoin(self.service_url, endpoint)

        try:
            response = requests.request(
                method=method,
                url=url,
                json=json_data,
                params=params,
                timeout=self.timeout
            )
            response.raise_for_status()
            return response.json()

        except requests.exceptions.ConnectionError as e:
            raise PlaywrightConnectionError(
                f"Cannot connect to Playwright service at {self.service_url}. "
                f"Is the service running? Error: {e}"
            )
        except requests.exceptions.Timeout as e:
            raise PlaywrightConnectionError(
                f"Request to Playwright service timed out after {self.timeout}s. "
                f"Error: {e}"
            )
        except requests.exceptions.HTTPError as e:
            error_msg = f"Playwright API error: {e}"
            try:
                error_data = response.json()
                error_msg = f"Playwright API error: {error_data.get('error', str(e))}"
            except Exception:
                pass
            raise PlaywrightError(error_msg)
        except requests.exceptions.RequestException as e:
            raise PlaywrightConnectionError(
                f"Request to Playwright service failed: {e}"
            )

    def health_check(self) -> Dict[str, Any]:
        """
        Check service health and get status

        Returns:
            Dictionary with health information:
            {
                "status": "healthy",
                "browser": {"running": true, "version": "..."},
                "contexts": 0,
                "uptime": 123.45,
                "memory": {...}
            }

        Raises:
            PlaywrightConnectionError: If service is not accessible
        """
        return self._request('GET', '/health')

    def new_context(
        self,
        options: Optional[Dict[str, Any]] = None
    ) -> str:
        """
        Create new browser context

        A browser context is an isolated browsing session, similar to an
        incognito window. Each context has its own cookies, cache, etc.

        Args:
            options: Browser context options:
                - viewport: dict with width/height (default: 1920x1080)
                - userAgent: string
                - locale: string (e.g., 'en-US')
                - timezoneId: string
                - metadata: dict with custom metadata

        Returns:
            Context ID (string)

        Raises:
            PlaywrightContextError: If context creation fails

        Example:
            context_id = pw.new_context({
                "viewport": {"width": 1280, "height": 720},
                "userAgent": "Mozilla/5.0 Custom"
            })
        """
        try:
            response = self._request('POST', '/browser/new', json_data={
                "options": options or {}
            })
            self.context_id = response['contextId']
            return self.context_id

        except PlaywrightError as e:
            raise PlaywrightContextError(f"Failed to create browser context: {e}")

    def navigate(
        self,
        url: str,
        wait_until: str = "networkidle",
        timeout: Optional[int] = None
    ) -> Dict[str, Any]:
        """
        Navigate to URL

        Args:
            url: URL to navigate to
            wait_until: When to consider navigation complete:
                - 'load': when 'load' event fires
                - 'domcontentloaded': when DOMContentLoaded event fires
                - 'networkidle': when no network connections for 500ms
            timeout: Navigation timeout in milliseconds (default: 30000)

        Returns:
            Dictionary with navigation result:
            {
                "status": "success",
                "url": "...",
                "title": "..."
            }

        Raises:
            PlaywrightContextError: If no active context
            PlaywrightError: If navigation fails

        Example:
            result = pw.navigate("https://example.com")
            print(f"Loaded: {result['title']}")
        """
        if not self.context_id:
            raise PlaywrightContextError(
                "No active context. Call new_context() first."
            )

        return self._request('POST', '/navigate', json_data={
            "contextId": self.context_id,
            "url": url,
            "waitUntil": wait_until
        })

    def screenshot(
        self,
        path: str,
        full_page: bool = False,
        image_type: str = "png"
    ) -> Dict[str, Any]:
        """
        Take screenshot of current page

        Args:
            path: Filename for screenshot (saved in /artifacts/screenshots/)
            full_page: Capture full scrollable page (default: False)
            image_type: Image format: 'png' or 'jpeg' (default: 'png')

        Returns:
            Dictionary with screenshot result:
            {
                "status": "success",
                "path": "/artifacts/screenshots/...",
                "filename": "..."
            }

        Raises:
            PlaywrightContextError: If no active context
            PlaywrightError: If screenshot fails

        Example:
            result = pw.screenshot("homepage.png", full_page=True)
            print(f"Screenshot saved: {result['path']}")
        """
        if not self.context_id:
            raise PlaywrightContextError(
                "No active context. Call new_context() first."
            )

        return self._request('POST', '/screenshot', json_data={
            "contextId": self.context_id,
            "path": path,
            "fullPage": full_page,
            "type": image_type
        })

    def evaluate(self, script: str) -> Dict[str, Any]:
        """
        Execute JavaScript in page context

        Args:
            script: JavaScript code to execute

        Returns:
            Dictionary with evaluation result:
            {
                "status": "success",
                "result": <return value of script>
            }

        Raises:
            PlaywrightContextError: If no active context
            PlaywrightError: If script execution fails

        Example:
            result = pw.evaluate("document.title")
            print(result['result'])  # Page title

            result = pw.evaluate('''
                () => {
                    return {
                        title: document.title,
                        url: window.location.href
                    }
                }
            ''')
        """
        if not self.context_id:
            raise PlaywrightContextError(
                "No active context. Call new_context() first."
            )

        return self._request('POST', '/evaluate', json_data={
            "contextId": self.context_id,
            "script": script
        })

    def pdf(
        self,
        path: str,
        format: str = "A4",
        landscape: bool = False
    ) -> Dict[str, Any]:
        """
        Generate PDF of current page

        Args:
            path: Filename for PDF (saved in /artifacts/pdfs/)
            format: Paper format: 'A4', 'Letter', etc. (default: 'A4')
            landscape: Landscape orientation (default: False)

        Returns:
            Dictionary with PDF result:
            {
                "status": "success",
                "path": "/artifacts/pdfs/..."
            }

        Raises:
            PlaywrightContextError: If no active context
            PlaywrightError: If PDF generation fails

        Example:
            result = pw.pdf("page.pdf", format="Letter", landscape=True)
        """
        if not self.context_id:
            raise PlaywrightContextError(
                "No active context. Call new_context() first."
            )

        return self._request('POST', '/pdf', json_data={
            "contextId": self.context_id,
            "path": path,
            "format": format,
            "landscape": landscape
        })

    def accessibility(self) -> Dict[str, Any]:
        """
        Run accessibility audit on current page

        Returns:
            Dictionary with accessibility snapshot:
            {
                "status": "success",
                "snapshot": <accessibility tree>
            }

        Raises:
            PlaywrightContextError: If no active context
            PlaywrightError: If audit fails

        Example:
            result = pw.accessibility()
            print(json.dumps(result['snapshot'], indent=2))
        """
        if not self.context_id:
            raise PlaywrightContextError(
                "No active context. Call new_context() first."
            )

        return self._request('POST', '/accessibility', json_data={
            "contextId": self.context_id
        })

    def close(self) -> Dict[str, Any]:
        """
        Close current browser context

        Closes the browser context and frees resources. After calling close(),
        you need to call new_context() again to perform more operations.

        Returns:
            Dictionary with close result:
            {
                "status": "closed",
                "contextId": "..."
            }

        Raises:
            PlaywrightContextError: If no active context
            PlaywrightError: If close fails

        Example:
            pw.close()
            # context_id is now None
        """
        if not self.context_id:
            raise PlaywrightContextError(
                "No active context to close."
            )

        response = self._request('POST', f'/browser/{self.context_id}/close')
        self.context_id = None
        return response

    def __repr__(self) -> str:
        """String representation"""
        status = "with context" if self.context_id else "no context"
        return f"<RemotePlaywright({self.service_url}, {status})>"


# Convenience function for quick scripts
def quick_screenshot(url: str, output_path: str, **kwargs) -> str:
    """
    Quick utility to take a screenshot

    Args:
        url: URL to screenshot
        output_path: Where to save screenshot
        **kwargs: Additional arguments for screenshot()

    Returns:
        Path to screenshot file

    Example:
        path = quick_screenshot("https://example.com", "example.png")
        print(f"Saved to: {path}")
    """
    with RemotePlaywright() as pw:
        pw.new_context()
        pw.navigate(url)
        result = pw.screenshot(output_path, **kwargs)
        return result['path']


if __name__ == "__main__":
    # Example usage and testing
    import sys

    print("Remote Playwright Client")
    print("=" * 60)
    print()

    try:
        pw = RemotePlaywright()

        # Health check
        print("📋 Health Check:")
        health = pw.health_check()
        print(f"   Status: {health.get('status')}")
        print(f"   Browser: {health.get('browser', {}).get('version')}")
        print(f"   Uptime: {health.get('uptime', 0):.1f}s")
        print(f"   Contexts: {health.get('browser', {}).get('contexts', 0)}")
        print()

        print("✅ Playwright service is accessible!")
        print()
        print("Usage Examples:")
        print()
        print("  Basic usage:")
        print("    pw = RemotePlaywright()")
        print("    pw.new_context()")
        print("    pw.navigate('https://example.com')")
        print("    pw.screenshot('example.png', full_page=True)")
        print("    pw.close()")
        print()
        print("  Context manager:")
        print("    with RemotePlaywright() as pw:")
        print("        pw.new_context()")
        print("        pw.navigate('https://example.com')")
        print("        pw.screenshot('example.png')")
        print()
        print("  Quick screenshot:")
        print("    from remote_playwright import quick_screenshot")
        print("    quick_screenshot('https://example.com', 'out.png')")

    except PlaywrightConnectionError as e:
        print(f"❌ Connection Error: {e}")
        print()
        print("Make sure the Playwright service is running:")
        print("  docker-compose ps")
        print("  docker-compose logs playwright")
        sys.exit(1)

    except Exception as e:
        print(f"❌ Error: {e}")
        sys.exit(1)
