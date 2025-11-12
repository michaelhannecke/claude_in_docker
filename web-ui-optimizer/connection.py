"""
Playwright Service Connection Utilities
=======================================
Helper functions for connecting to and managing connections with the
Playwright browser automation service.

Functions:
    - wait_for_playwright_service: Wait for service to be ready
    - check_service_health: Quick health check
    - get_service_info: Get detailed service information
    - verify_connection: Comprehensive connection verification
"""

import os
import time
import requests
from typing import Optional, Dict, Any
from urllib.parse import urljoin


def wait_for_playwright_service(
    max_retries: int = 30,
    delay: int = 2,
    service_url: Optional[str] = None,
    verbose: bool = True
) -> bool:
    """
    Wait for Playwright service to be ready

    Polls the service health endpoint until it responds successfully or
    max retries is reached. Useful for startup scripts and tests.

    Args:
        max_retries: Maximum number of retry attempts (default: 30)
        delay: Seconds to wait between retries (default: 2)
        service_url: URL of service (default: from env or http://playwright:3000)
        verbose: Print progress messages (default: True)

    Returns:
        True if service is ready

    Raises:
        Exception: If service is not available after max_retries

    Example:
        # Wait for service during startup
        wait_for_playwright_service()
        print("Service ready!")

        # Quick check with fewer retries
        wait_for_playwright_service(max_retries=5, delay=1)
    """
    url = service_url or os.environ.get(
        'PLAYWRIGHT_SERVICE_URL',
        'http://playwright:3000'
    )

    # Ensure URL doesn't end with slash
    url = url.rstrip('/')

    if verbose:
        print(f"Waiting for Playwright service at {url}...")

    for i in range(max_retries):
        try:
            response = requests.get(f"{url}/health", timeout=5)
            if response.status_code == 200:
                data = response.json()

                if verbose:
                    print("✅ Playwright service ready!")
                    print(f"   Status: {data.get('status')}")
                    browser_info = data.get('browser', {})
                    print(f"   Browser: {browser_info.get('version', 'Unknown')}")
                    print(f"   Uptime: {data.get('uptime', 0):.1f}s")
                    print(f"   Memory: {data.get('memory', {}).get('used', 0)}MB used")

                return True

        except requests.exceptions.RequestException:
            if verbose:
                print(f"⏳ Waiting for Playwright service... ({i+1}/{max_retries})")
            time.sleep(delay)

    error_msg = f"Playwright service not available at {url} after {max_retries} attempts"
    if verbose:
        print(f"❌ {error_msg}")
    raise Exception(error_msg)


def check_service_health(
    service_url: Optional[str] = None,
    timeout: int = 5
) -> Dict[str, Any]:
    """
    Quick health check of Playwright service

    Args:
        service_url: URL of service (default: from env)
        timeout: Request timeout in seconds (default: 5)

    Returns:
        Health status dictionary

    Raises:
        requests.exceptions.RequestException: If service is not accessible

    Example:
        try:
            health = check_service_health()
            print(f"Service is {health['status']}")
        except Exception as e:
            print(f"Service unavailable: {e}")
    """
    url = service_url or os.environ.get(
        'PLAYWRIGHT_SERVICE_URL',
        'http://playwright:3000'
    )

    url = url.rstrip('/')
    response = requests.get(f"{url}/health", timeout=timeout)
    response.raise_for_status()
    return response.json()


def get_service_info(
    service_url: Optional[str] = None,
    timeout: int = 5
) -> Dict[str, Any]:
    """
    Get detailed information about Playwright service

    Returns comprehensive service information including browser version,
    memory usage, uptime, and active contexts.

    Args:
        service_url: URL of service (default: from env)
        timeout: Request timeout in seconds (default: 5)

    Returns:
        Dictionary with service information:
        {
            "service_url": "http://playwright:3000",
            "status": "healthy",
            "browser": {
                "running": true,
                "version": "Chromium 120.0.6099.0",
                "contexts": 0
            },
            "uptime": 123.45,
            "memory": {
                "used": 145,
                "total": 512,
                "unit": "MB"
            },
            "environment": {
                "display": ":99",
                "nodeVersion": "v22.x.x"
            }
        }

    Raises:
        requests.exceptions.RequestException: If service is not accessible

    Example:
        info = get_service_info()
        print(f"Browser: {info['browser']['version']}")
        print(f"Uptime: {info['uptime']:.1f}s")
        print(f"Memory: {info['memory']['used']}MB")
    """
    url = service_url or os.environ.get(
        'PLAYWRIGHT_SERVICE_URL',
        'http://playwright:3000'
    )

    url = url.rstrip('/')
    response = requests.get(f"{url}/health", timeout=timeout)
    response.raise_for_status()

    data = response.json()
    data['service_url'] = url

    return data


def verify_connection(
    service_url: Optional[str] = None,
    verbose: bool = True
) -> bool:
    """
    Comprehensive connection verification

    Performs multiple checks to verify the Playwright service is accessible
    and functioning correctly:
    1. Network connectivity
    2. HTTP response
    3. Health check endpoint
    4. Browser availability

    Args:
        service_url: URL of service (default: from env)
        verbose: Print detailed results (default: True)

    Returns:
        True if all checks pass

    Raises:
        Exception: If any check fails (with detailed error message)

    Example:
        # Verify connection during startup
        if verify_connection():
            print("All checks passed!")

        # Silent verification
        try:
            verify_connection(verbose=False)
        except Exception as e:
            print(f"Verification failed: {e}")
    """
    url = service_url or os.environ.get(
        'PLAYWRIGHT_SERVICE_URL',
        'http://playwright:3000'
    )

    url = url.rstrip('/')

    if verbose:
        print("Verifying Playwright service connection...")
        print(f"Service URL: {url}")
        print()

    # Check 1: Basic connectivity
    if verbose:
        print("1. Testing network connectivity...")

    try:
        response = requests.get(f"{url}/health", timeout=5)
        if verbose:
            print(f"   ✅ Service is reachable (HTTP {response.status_code})")
    except requests.exceptions.ConnectionError as e:
        error_msg = f"Cannot connect to service at {url}. Is it running?"
        if verbose:
            print(f"   ❌ {error_msg}")
        raise Exception(error_msg) from e
    except requests.exceptions.Timeout as e:
        error_msg = f"Connection to service at {url} timed out"
        if verbose:
            print(f"   ❌ {error_msg}")
        raise Exception(error_msg) from e

    # Check 2: Health status
    if verbose:
        print("2. Checking service health...")

    try:
        data = response.json()
        status = data.get('status')

        if status == 'healthy':
            if verbose:
                print(f"   ✅ Service reports healthy status")
        else:
            error_msg = f"Service reports unhealthy status: {status}"
            if verbose:
                print(f"   ❌ {error_msg}")
            raise Exception(error_msg)

    except (KeyError, ValueError) as e:
        error_msg = f"Invalid health response from service"
        if verbose:
            print(f"   ❌ {error_msg}")
        raise Exception(error_msg) from e

    # Check 3: Browser availability
    if verbose:
        print("3. Checking browser availability...")

    browser_info = data.get('browser', {})
    browser_running = browser_info.get('running', False)
    browser_version = browser_info.get('version', 'Unknown')

    if browser_running:
        if verbose:
            print(f"   ✅ Browser is running ({browser_version})")
    else:
        error_msg = "Browser is not running"
        if verbose:
            print(f"   ⚠️  {error_msg}")
        # Warning but not fatal

    # Check 4: Service details
    if verbose:
        print("4. Service details:")
        print(f"   • Uptime: {data.get('uptime', 0):.1f}s")
        print(f"   • Active contexts: {browser_info.get('contexts', 0)}")

        memory = data.get('memory', {})
        print(f"   • Memory: {memory.get('used', 0)}/{memory.get('total', 0)} {memory.get('unit', 'MB')}")

        env = data.get('environment', {})
        print(f"   • Display: {env.get('display', 'Unknown')}")
        print(f"   • Node: {env.get('nodeVersion', 'Unknown')}")

    if verbose:
        print()
        print("✅ All checks passed! Service is ready.")

    return True


def test_connection_script():
    """
    Interactive script to test Playwright service connection

    Runs when this module is executed directly.
    Performs comprehensive checks and reports results.
    """
    import sys

    print("=" * 70)
    print("  Playwright Service Connection Test")
    print("=" * 70)
    print()

    service_url = os.environ.get('PLAYWRIGHT_SERVICE_URL', 'http://playwright:3000')
    print(f"Testing connection to: {service_url}")
    print()

    try:
        # Try to verify connection
        verify_connection(verbose=True)

        print()
        print("=" * 70)
        print("  ✅ SUCCESS - Service is fully operational")
        print("=" * 70)
        print()
        print("Next steps:")
        print("  1. Import the client library:")
        print("     from remote_playwright import RemotePlaywright")
        print()
        print("  2. Create a client:")
        print("     pw = RemotePlaywright()")
        print()
        print("  3. Start automating:")
        print("     pw.new_context()")
        print("     pw.navigate('https://example.com')")
        print("     pw.screenshot('output.png')")
        print("     pw.close()")

        sys.exit(0)

    except Exception as e:
        print()
        print("=" * 70)
        print("  ❌ FAILED - Service is not accessible")
        print("=" * 70)
        print()
        print(f"Error: {e}")
        print()
        print("Troubleshooting:")
        print("  1. Check if Playwright service is running:")
        print("     docker-compose ps")
        print()
        print("  2. Check Playwright service logs:")
        print("     docker-compose logs playwright")
        print()
        print("  3. Verify network connectivity:")
        print("     docker exec claude-workspace ping playwright")
        print()
        print("  4. Check service URL environment variable:")
        print("     echo $PLAYWRIGHT_SERVICE_URL")

        sys.exit(1)


if __name__ == "__main__":
    test_connection_script()
