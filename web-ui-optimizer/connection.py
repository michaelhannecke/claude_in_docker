"""
Playwright Service Connection Utilities
=======================================
Helper functions for connecting to the Playwright service.
"""

import os
import time
import requests
from typing import Optional


def wait_for_playwright_service(
    max_retries: int = 30,
    delay: int = 2,
    service_url: Optional[str] = None
) -> bool:
    """
    Wait for Playwright service to be ready

    Args:
        max_retries: Maximum number of retry attempts
        delay: Seconds to wait between retries
        service_url: URL of service (default: from env)

    Returns:
        True if service is ready, raises Exception otherwise
    """
    url = service_url or os.environ.get(
        'PLAYWRIGHT_SERVICE_URL',
        'http://playwright:3000'
    )

    print(f"Waiting for Playwright service at {url}...")

    for i in range(max_retries):
        try:
            response = requests.get(f"{url}/health", timeout=5)
            if response.status_code == 200:
                data = response.json()
                print(f"✅ Playwright service ready!")
                print(f"   Status: {data.get('status')}")
                print(f"   Browser: {data.get('browser', {}).get('version')}")
                return True
        except requests.exceptions.RequestException as e:
            print(f"⏳ Waiting for Playwright service... ({i+1}/{max_retries})")
            time.sleep(delay)

    raise Exception(f"Playwright service not available after {max_retries} attempts")


if __name__ == "__main__":
    wait_for_playwright_service()
