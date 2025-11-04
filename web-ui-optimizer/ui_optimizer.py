from playwright.sync_api import sync_playwright, Page
import os
import json
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from datetime import datetime


class UIOptimizer:
    """Web UI optimization and testing toolkit using Playwright."""

    def __init__(self, headless: bool = True):
        self.playwright = None
        self.browser = None
        self.context = None
        self.page = None
        self.headless = headless

    def initialize(self):
        """Initialize Playwright and browser."""
        self.playwright = sync_playwright().start()
        self.browser = self.playwright.chromium.launch(
            headless=self.headless,
            args=['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
        )
        self.context = self.browser.new_context(
            viewport={'width': 1920, 'height': 1080}
        )
        self.page = self.context.new_page()

        # Enable console logging
        self.page.on("console", lambda msg: print(f"PAGE LOG: {msg.text}"))

    def capture_responsive(self, url: str, output_dir: str = './screenshots') -> List[Dict]:
        """Capture screenshots at different viewport sizes."""
        Path(output_dir).mkdir(parents=True, exist_ok=True)

        viewports = [
            {'width': 375, 'height': 667, 'device': 'iPhone-SE'},
            {'width': 768, 'height': 1024, 'device': 'iPad'},
            {'width': 1366, 'height': 768, 'device': 'laptop'},
            {'width': 1920, 'height': 1080, 'device': 'desktop'}
        ]

        screenshots = []

        for viewport in viewports:
            self.page.set_viewport_size(
                width=viewport['width'],
                height=viewport['height']
            )
            self.page.goto(url, wait_until='networkidle', timeout=30000)

            filename = f"{viewport['device']}-{viewport['width']}x{viewport['height']}.png"
            filepath = os.path.join(output_dir, filename)

            self.page.screenshot(path=filepath, full_page=True)
            screenshots.append({
                'device': viewport['device'],
                'dimensions': f"{viewport['width']}x{viewport['height']}",
                'path': filepath
            })

            print(f"✅ Captured {viewport['device']} view")

        return screenshots

    def analyze_colors(self) -> List[Dict[str, any]]:
        """Extract and analyze color palette from the current page."""
        colors = self.page.evaluate('''() => {
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
        }''')

        return colors

    def check_accessibility(self) -> Dict:
        """Perform basic accessibility checks."""
        results = self.page.evaluate('''() => {
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
        }''')

        return results

    def measure_performance(self, url: str) -> Dict:
        """Measure page load performance metrics."""
        self.page.goto(url, timeout=30000)

        metrics = self.page.evaluate('''() => {
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
        }''')

        return metrics

    def compare_before_after(self, url: str, css_changes: str, output_dir: str = './comparisons') -> Dict[str, str]:
        """Capture before/after screenshots with CSS changes."""
        Path(output_dir).mkdir(parents=True, exist_ok=True)

        # Capture before
        self.page.goto(url, wait_until='networkidle')
        before_path = os.path.join(output_dir, 'before.png')
        self.page.screenshot(path=before_path, full_page=True)

        # Apply CSS changes
        self.page.add_style_tag(content=css_changes)
        self.page.wait_for_timeout(500)  # Wait for styles to apply

        # Capture after
        after_path = os.path.join(output_dir, 'after.png')
        self.page.screenshot(path=after_path, full_page=True)

        print('✅ Before/After comparison saved')

        return {
            'before': before_path,
            'after': after_path
        }

    def extract_text(self) -> str:
        """Extract all text content from the current page."""
        return self.page.evaluate('() => document.body.innerText')

    def cleanup(self):
        """Clean up resources."""
        if self.browser:
            self.browser.close()
        if self.playwright:
            self.playwright.stop()

    def __enter__(self):
        """Context manager entry."""
        self.initialize()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit."""
        self.cleanup()


# Example usage and CLI interface
if __name__ == "__main__":
    import sys

    url = sys.argv[1] if len(sys.argv) > 1 else "https://example.com"

    print(f"🔍 Analyzing {url}...")

    with UIOptimizer() as optimizer:
        # Navigate to page
        optimizer.page.goto(url)

        # Capture screenshots
        screenshots = optimizer.capture_responsive(url)
        print(f"\n📸 Captured {len(screenshots)} responsive screenshots")

        # Analyze colors
        colors = optimizer.analyze_colors()
        print("\n🎨 Top 5 colors:")
        for item in colors[:5]:
            print(f"  - {item['color']}: used {item['count']} times")

        # Check accessibility
        accessibility = optimizer.check_accessibility()
        print(f"\n♿ Accessibility check:")
        print(f"  - Images without alt: {len(accessibility['images_without_alt'])}")
        print(f"  - Inputs without labels: {len(accessibility['missing_labels'])}")
        print(f"  - Headings found: {len(accessibility['heading_structure'])}")
        print(f"  - Links without text: {len(accessibility['links_without_text'])}")

        # Measure performance
        performance = optimizer.measure_performance(url)
        print(f"\n⚡ Performance metrics:")
        print(f"  - DOM Content Loaded: {performance.get('domContentLoaded', 'N/A')}ms")
        print(f"  - Page Load Complete: {performance.get('loadComplete', 'N/A')}ms")
        print(f"  - First Paint: {performance.get('firstPaint', 'N/A')}ms")

    print("\n✨ Analysis complete!")
