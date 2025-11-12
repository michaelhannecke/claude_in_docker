# Remote Playwright Examples

This directory contains example scripts demonstrating how to use the remote Playwright service.

## Prerequisites

- Multi-container DevContainer running
- Playwright service healthy (`docker-compose ps`)
- Python virtual environment activated (`source ~/.venv/bin/activate`)

## Running Examples

```bash
# Activate virtual environment
source ~/.venv/bin/activate

# Run examples
python examples/01_basic_screenshot.py
python examples/02_context_manager.py
python examples/03_ui_optimizer_full.py https://example.com
```

## Examples

### 01_basic_screenshot.py
**Basic Screenshot**

Demonstrates the fundamental workflow:
1. Wait for Playwright service
2. Create browser context
3. Navigate to URL
4. Take screenshot
5. Close context

**Usage**:
```bash
python examples/01_basic_screenshot.py
```

**Output**:
- Screenshot: `/artifacts/screenshots/example.png`

---

### 02_context_manager.py
**Context Manager**

Shows recommended usage with `with` statement:
- Automatic resource cleanup
- Exception handling
- Cleaner code

**Usage**:
```bash
python examples/02_context_manager.py
```

**Output**:
- Screenshot: `/artifacts/screenshots/python-homepage.png`

---

### 03_ui_optimizer_full.py
**Full UI Optimizer**

Comprehensive web analysis using UIOptimizer:
- Responsive screenshots (4 viewports)
- Color palette analysis
- Accessibility checks
- Performance metrics

**Usage**:
```bash
# Default URL
python examples/03_ui_optimizer_full.py

# Custom URL
python examples/03_ui_optimizer_full.py https://github.com
```

**Output**:
- Screenshots: `/artifacts/screenshots/*.png`
- Analysis printed to console

---

## Accessing Screenshot Output

Screenshots are saved in the Playwright service container and shared via Docker volume.

**Viewing screenshots**:

```bash
# List screenshots
docker exec claude-playwright ls -lh /artifacts/screenshots/

# Copy screenshot to workspace
docker cp claude-playwright:/artifacts/screenshots/example.png ./

# Or access via shared volume (if configured)
ls /artifacts/screenshots/
```

## API Reference

### RemotePlaywright

Low-level client for Playwright HTTP API.

**Methods**:
- `health_check()` - Check service health
- `new_context(options)` - Create browser context
- `navigate(url)` - Navigate to URL
- `screenshot(path, full_page)` - Take screenshot
- `evaluate(script)` - Execute JavaScript
- `pdf(path, format)` - Generate PDF
- `accessibility()` - Run accessibility audit
- `close()` - Close context

### UIOptimizer

High-level toolkit for web analysis.

**Methods**:
- `capture_responsive(url)` - Multi-viewport screenshots
- `analyze_colors()` - Extract color palette
- `check_accessibility()` - Accessibility audit
- `measure_performance(url)` - Performance metrics
- `compare_before_after(url, css)` - CSS A/B testing
- `extract_text()` - Extract page text

### Connection Utilities

**Functions**:
- `wait_for_playwright_service()` - Wait for service ready
- `check_service_health()` - Quick health check
- `get_service_info()` - Detailed service info
- `verify_connection()` - Comprehensive verification

## Creating Your Own Scripts

### Template

```python
#!/usr/bin/env python3
import sys
sys.path.insert(0, '/workspaces/claude_in_devcontainer')

from web_ui_optimizer import RemotePlaywright, wait_for_playwright_service

def main():
    # Wait for service
    wait_for_playwright_service(verbose=False)

    # Use context manager
    with RemotePlaywright() as pw:
        pw.new_context()

        # Your automation code here
        pw.navigate("https://example.com")
        pw.screenshot("output.png")

        print("✅ Done!")

if __name__ == "__main__":
    main()
```

## Troubleshooting

### "Cannot connect to Playwright service"

Check if service is running:
```bash
docker-compose ps
docker-compose logs playwright
```

### "Context not found"

Make sure to create a context before other operations:
```python
pw.new_context()  # Required before navigate, screenshot, etc.
```

### Screenshots not found

Screenshots are saved in the Playwright container:
```bash
# Check if files exist
docker exec claude-playwright ls /artifacts/screenshots/

# Copy to workspace
docker cp claude-playwright:/artifacts/screenshots/ ./output/
```

## Next Steps

1. **Modify examples** - Adapt scripts for your use cases
2. **Write tests** - Create automated browser tests
3. **Build tools** - Use in CI/CD pipelines
4. **Integrate** - Add to existing projects

## Documentation

- `../web-ui-optimizer/remote_playwright.py` - Client library docs
- `../web-ui-optimizer/ui_optimizer.py` - UI Optimizer docs
- `../web-ui-optimizer/connection.py` - Connection utilities
- `../ARCHITECTURE_PLAN.md` - Architecture details
- `../.devcontainer/QUICK_REFERENCE.md` - Command reference
