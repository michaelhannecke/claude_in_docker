"""
UI Optimizer - Remote Playwright Version
=========================================
Web UI optimization and testing toolkit using Remote Playwright service.

This version uses the Playwright service running in a separate container
instead of running Playwright locally. It maintains the same interface as
the original UIOptimizer but communicates via HTTP API.

Changes from original:
- Uses RemotePlaywright client instead of local Playwright
- Communicates with http://playwright:3000
- Same interface and functionality
- No browser installation required in workspace

Original file backed up to: ui_optimizer.py.original
"""

import os
import json
from pathlib import Path
from typing import Dict, List, Optional
from datetime import datetime

# Import remote Playwright client
from remote_playwright import RemotePlaywright, PlaywrightError, PlaywrightConnectionError
from connection import wait_for_playwright_service


class UIOptimizer:
    """
    Web UI optimization and testing toolkit using Remote Playwright.

    This class provides the same interface as the original UIOptimizer but
    uses a remote Playwright service instead of running browsers locally.
    """

    def __init__(self, service_url: Optional[str] = None):
        """
        Initialize UI Optimizer

        Args:
            service_url: URL of Playwright service (default: from env)
        """
        self.service_url = service_url
        self.pw = None
        self.context_id = None

    def initialize(self):
        """Initialize connection to Playwright service"""
        print("Connecting to Playwright service...")
        self.pw = RemotePlaywright(service_url=self.service_url)

        # Verify service is accessible
        try:
            health = self.pw.health_check()
            print(f"✅ Connected to Playwright service")
            print(f"   Browser: {health.get('browser', {}).get('version', 'Unknown')}")
        except PlaywrightConnectionError as e:
            print(f"❌ Cannot connect to Playwright service: {e}")
            raise

        # Create browser context
        self.context_id = self.pw.new_context()
        print(f"✅ Browser context created: {self.context_id}")

    def capture_responsive(
        self,
        url: str,
        output_dir: str = './screenshots'
    ) -> List[Dict]:
        """
        Capture screenshots at different viewport sizes

        Args:
            url: URL to capture
            output_dir: Directory to save screenshots

        Returns:
            List of dictionaries with screenshot information
        """
        Path(output_dir).mkdir(parents=True, exist_ok=True)

        viewports = [
            {'width': 375, 'height': 667, 'device': 'iPhone-SE'},
            {'width': 768, 'height': 1024, 'device': 'iPad'},
            {'width': 1366, 'height': 768, 'device': 'laptop'},
            {'width': 1920, 'height': 1080, 'device': 'desktop'}
        ]

        screenshots = []

        for viewport in viewports:
            # Create new context with specific viewport
            # Note: In current implementation, we recreate context for each viewport
            # A future optimization could support viewport changes within same context

            if self.context_id:
                self.pw.close()

            self.context_id = self.pw.new_context(options={
                "viewport": {
                    "width": viewport['width'],
                    "height": viewport['height']
                }
            })

            # Navigate to URL
            self.pw.navigate(url, wait_until="networkidle")

            # Take screenshot
            filename = f"{viewport['device']}-{viewport['width']}x{viewport['height']}.png"
            filepath = os.path.join(output_dir, filename)

            self.pw.screenshot(filename, full_page=True)

            screenshots.append({
                'device': viewport['device'],
                'dimensions': f"{viewport['width']}x{viewport['height']}",
                'path': f"/artifacts/screenshots/{filename}",
                'local_path': filepath
            })

            print(f"✅ Captured {viewport['device']} view")

        return screenshots

    def analyze_colors(self) -> List[Dict[str, any]]:
        """
        Extract and analyze color palette from the current page

        Returns:
            List of dictionaries with color information
        """
        script = '''() => {
            const elements = document.querySelectorAll('*');
            const colorMap = new Map();

            elements.forEach(el => {
                const style = window.getComputedStyle(el);
                const color = style.color;
                const bgColor = style.backgroundColor;

                if (color && color !== 'rgba(0, 0, 0, 0)') {
                    colorMap.set(color, (colorMap.get(color) || 0) + 1);
                }
                if (bgColor && bgColor !== 'rgba(0, 0, 0, 0)') {
                    colorMap.set(bgColor, (colorMap.get(bgColor) || 0) + 1);
                }
            });

            return Array.from(colorMap.entries())
                .sort((a, b) => b[1] - a[1])
                .map(([color, count]) => ({ color, count }));
        }'''

        result = self.pw.evaluate(script)
        return result.get('result', [])

    def check_accessibility(self) -> Dict:
        """
        Perform basic accessibility checks

        Returns:
            Dictionary with accessibility issues
        """
        script = '''() => {
            const checks = {
                images_without_alt: [],
                missing_labels: [],
                heading_structure: [],
                links_without_text: []
            };

            // Check images
            document.querySelectorAll('img').forEach(img => {
                if (!img.alt) {
                    checks.images_without_alt.push(img.src || 'inline-image');
                }
            });

            // Check form inputs
            document.querySelectorAll('input, select, textarea').forEach(input => {
                const id = input.id;
                const ariaLabel = input.getAttribute('aria-label');
                if (id && !document.querySelector(`label[for="${id}"]`) && !ariaLabel) {
                    checks.missing_labels.push({
                        type: input.type,
                        name: input.name || 'unnamed',
                        id: id
                    });
                }
            });

            // Check headings
            const headings = document.querySelectorAll('h1, h2, h3, h4, h5, h6');
            checks.heading_structure = Array.from(headings).map(h => ({
                level: h.tagName,
                text: h.textContent.substring(0, 50)
            }));

            // Check links
            document.querySelectorAll('a').forEach(link => {
                if (!link.textContent.trim() && !link.querySelector('img')) {
                    checks.links_without_text.push(link.href);
                }
            });

            return checks;
        }'''

        result = self.pw.evaluate(script)
        return result.get('result', {})

    def measure_performance(self, url: str) -> Dict:
        """
        Measure page load performance metrics

        Args:
            url: URL to measure

        Returns:
            Dictionary with performance metrics
        """
        # Navigate to URL
        self.pw.navigate(url)

        # Get performance metrics
        script = '''() => {
            const perfData = performance.getEntriesByType('navigation')[0];
            const paintEntries = performance.getEntriesByType('paint');

            return {
                domContentLoaded: perfData.domContentLoadedEventEnd - perfData.domContentLoadedEventStart,
                loadComplete: perfData.loadEventEnd - perfData.loadEventStart,
                domInteractive: perfData.domInteractive,
                responseTime: perfData.responseEnd - perfData.requestStart,
                firstPaint: paintEntries.find(e => e.name === 'first-paint')?.startTime,
                firstContentfulPaint: paintEntries.find(e => e.name === 'first-contentful-paint')?.startTime
            };
        }'''

        result = self.pw.evaluate(script)
        return result.get('result', {})

    def compare_before_after(
        self,
        url: str,
        css_changes: str,
        output_dir: str = './comparisons'
    ) -> Dict[str, str]:
        """
        Capture before/after screenshots with CSS changes

        Args:
            url: URL to test
            css_changes: CSS code to inject
            output_dir: Directory to save comparisons

        Returns:
            Dictionary with paths to before/after screenshots
        """
        Path(output_dir).mkdir(parents=True, exist_ok=True)

        # Navigate to page
        self.pw.navigate(url, wait_until="networkidle")

        # Capture before
        before_filename = 'before.png'
        self.pw.screenshot(before_filename, full_page=True)
        before_path = f"/artifacts/screenshots/{before_filename}"

        # Apply CSS changes
        script = f'''() => {{
            const style = document.createElement('style');
            style.textContent = `{css_changes}`;
            document.head.appendChild(style);
        }}'''
        self.pw.evaluate(script)

        # Wait for styles to apply (simulate wait_for_timeout)
        import time
        time.sleep(0.5)

        # Capture after
        after_filename = 'after.png'
        self.pw.screenshot(after_filename, full_page=True)
        after_path = f"/artifacts/screenshots/{after_filename}"

        print('✅ Before/After comparison saved')

        return {
            'before': before_path,
            'after': after_path,
            'local_before': os.path.join(output_dir, before_filename),
            'local_after': os.path.join(output_dir, after_filename)
        }

    def extract_text(self) -> str:
        """
        Extract all text content from the current page

        Returns:
            Text content of page
        """
        script = '() => document.body.innerText'
        result = self.pw.evaluate(script)
        return result.get('result', '')

    def cleanup(self):
        """Clean up resources"""
        if self.pw and self.context_id:
            try:
                self.pw.close()
            except Exception as e:
                print(f"Warning: Error during cleanup: {e}")

    def __enter__(self):
        """Context manager entry"""
        self.initialize()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit"""
        self.cleanup()


# Example usage and CLI interface
if __name__ == "__main__":
    import sys

    url = sys.argv[1] if len(sys.argv) > 1 else "https://example.com"

    print(f"🔍 Analyzing {url}...")
    print()

    # Wait for Playwright service to be ready
    try:
        wait_for_playwright_service(max_retries=10, delay=1, verbose=True)
    except Exception as e:
        print(f"❌ Playwright service not available: {e}")
        print()
        print("Make sure the Playwright service is running:")
        print("  docker-compose ps")
        print("  docker-compose logs playwright")
        sys.exit(1)

    print()

    try:
        with UIOptimizer() as optimizer:
            # Navigate to page
            optimizer.pw.navigate(url)

            # Capture screenshots
            print("📸 Capturing responsive screenshots...")
            screenshots = optimizer.capture_responsive(url)
            print(f"✅ Captured {len(screenshots)} responsive screenshots")

            # Analyze colors
            print("\n🎨 Analyzing colors...")
            colors = optimizer.analyze_colors()
            print("Top 5 colors:")
            for item in colors[:5]:
                print(f"  - {item['color']}: used {item['count']} times")

            # Check accessibility
            print("\n♿ Checking accessibility...")
            accessibility = optimizer.check_accessibility()
            print(f"Accessibility check:")
            print(f"  - Images without alt: {len(accessibility.get('images_without_alt', []))}")
            print(f"  - Inputs without labels: {len(accessibility.get('missing_labels', []))}")
            print(f"  - Headings found: {len(accessibility.get('heading_structure', []))}")
            print(f"  - Links without text: {len(accessibility.get('links_without_text', []))}")

            # Measure performance
            print("\n⚡ Measuring performance...")
            performance = optimizer.measure_performance(url)
            print(f"Performance metrics:")
            print(f"  - DOM Content Loaded: {performance.get('domContentLoaded', 'N/A')}ms")
            print(f"  - Page Load Complete: {performance.get('loadComplete', 'N/A')}ms")
            print(f"  - First Paint: {performance.get('firstPaint', 'N/A')}ms")
            print(f"  - First Contentful Paint: {performance.get('firstContentfulPaint', 'N/A')}ms")

        print("\n✨ Analysis complete!")
        print()
        print("Screenshots saved to: /artifacts/screenshots/")
        print("Access them from the shared volume in your workspace")

    except PlaywrightError as e:
        print(f"\n❌ Playwright error: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
