#!/bin/bash
echo "🔍 Verifying Playwright setup..."

# Check environment
echo "Environment checks:"
echo "  DISPLAY=$DISPLAY"
echo "  Python: $(python --version)"

# Test Python version
echo -e "\n🐍 Python Playwright test..."
python -c "
from playwright.sync_api import sync_playwright
try:
    with sync_playwright() as p:
        browser = p.chromium.launch(
            headless=True,
            args=['--no-sandbox', '--disable-setuid-sandbox']
        )
        page = browser.new_page()
        page.goto('https://example.com')
        title = page.title()
        print(f'✅ Python Playwright works! Page title: {title}')
        browser.close()
except Exception as e:
    print(f'❌ Python Playwright error: {e}')
    print('Try running: python -m playwright install chromium')
" || echo "Python test failed"

echo -e "\n✨ Setup verification complete!"
