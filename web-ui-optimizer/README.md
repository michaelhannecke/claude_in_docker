# Claude Code + Playwright (Python) Setup 🎭

## Quick Start

### 1. Verify Installation
```bash
cd ~/web-ui-optimizer
./verify_setup.sh
```

### 2. Basic Usage

```bash
python ui_optimizer.py https://example.com
```

### 3. With Claude Code

```bash
cd ~/web-ui-optimizer
```

Then ask Claude Code to:
- "Test example.com and capture screenshots"
- "Check accessibility issues on my website"
- "Extract the color palette from a webpage"

## Troubleshooting

### Browser not found error

If you get browser not found errors, reinstall:

```bash
python -m playwright install chromium --with-deps
```

### Display issues

Make sure Xvfb is running:
```bash
export DISPLAY=:99
Xvfb :99 -screen 0 1920x1080x24 > /dev/null 2>&1 &
```

## Features

- 📸 Responsive screenshot capture
- 🎨 Color palette extraction
- ♿ Accessibility checking
- ⚡ Performance metrics
- 🔄 Before/after comparisons
- 📝 Text extraction

## Examples

### Context manager usage
```python
from ui_optimizer import UIOptimizer

with UIOptimizer(headless=False) as optimizer:
    optimizer.page.goto("https://example.com")
    # Your analysis here
```

### Custom screenshot sizes
```python
optimizer.page.set_viewport_size(width=1440, height=900)
optimizer.page.screenshot(path="custom.png", full_page=True)
```
