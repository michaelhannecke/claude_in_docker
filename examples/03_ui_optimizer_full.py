#!/usr/bin/env python3
"""
Example 3: Full UI Optimizer Demo
==================================
Demonstrates the high-level UIOptimizer class for comprehensive web analysis.

This shows:
- Responsive screenshots
- Color analysis
- Accessibility checks
- Performance metrics
"""

import sys
sys.path.insert(0, '/workspaces/claude_in_devcontainer')

from web_ui_optimizer import UIOptimizer, wait_for_playwright_service

def main():
    url = sys.argv[1] if len(sys.argv) > 1 else "https://example.com"

    print(f"🔍 Analyzing: {url}")
    print()

    # Wait for service
    wait_for_playwright_service(verbose=False)

    # Use UIOptimizer with context manager
    with UIOptimizer() as optimizer:
        # Capture responsive screenshots
        print("📸 Capturing responsive screenshots...")
        screenshots = optimizer.capture_responsive(url)
        print(f"✅ Captured {len(screenshots)} screenshots")
        for shot in screenshots:
            print(f"   - {shot['device']}: {shot['dimensions']}")
        print()

        # Analyze colors
        print("🎨 Analyzing colors...")
        colors = optimizer.analyze_colors()
        print("Top 5 colors:")
        for i, color_info in enumerate(colors[:5], 1):
            print(f"   {i}. {color_info['color']} (used {color_info['count']} times)")
        print()

        # Check accessibility
        print("♿ Checking accessibility...")
        a11y = optimizer.check_accessibility()
        print(f"Issues found:")
        print(f"   - Images without alt text: {len(a11y.get('images_without_alt', []))}")
        print(f"   - Form inputs without labels: {len(a11y.get('missing_labels', []))}")
        print(f"   - Total headings: {len(a11y.get('heading_structure', []))}")
        print(f"   - Links without text: {len(a11y.get('links_without_text', []))}")
        print()

        # Measure performance
        print("⚡ Measuring performance...")
        perf = optimizer.measure_performance(url)
        print(f"Metrics:")
        print(f"   - DOM Content Loaded: {perf.get('domContentLoaded', 'N/A')} ms")
        print(f"   - Page Load Complete: {perf.get('loadComplete', 'N/A')} ms")
        print(f"   - First Paint: {perf.get('firstPaint', 'N/A')} ms")
        print(f"   - First Contentful Paint: {perf.get('firstContentfulPaint', 'N/A')} ms")

    print()
    print("✨ Analysis complete!")

if __name__ == "__main__":
    main()
