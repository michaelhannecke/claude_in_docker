#!/bin/bash
set -e

echo "🚀 Starting simplified Playwright setup for Claude Code..."

# Update and install system dependencies
echo "📦 Installing system dependencies..."
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 \
    libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 \
    libgbm1 libasound2 libatspi2.0-0 libgtk-3-0 libpango-1.0-0 \
    libcairo2 libgdk-pixbuf-2.0-0 xvfb fonts-liberation \
    fonts-noto-color-emoji libvulkan1

# Install Claude Code
echo "🤖 Installing Claude Code..."
npm install -g @anthropic-ai/claude-code

# Create a project directory for Playwright scripts
echo "🎭 Setting up Playwright project..."
mkdir -p ~/web-ui-optimizer
cd ~/web-ui-optimizer

# Initialize npm project
npm init -y

# Install Playwright locally
npm install playwright

# Install browsers (using default location)
echo "🌐 Installing browsers..."
cd ~/web-ui-optimizer
npx playwright install chromium
npx playwright install-deps chromium

# Optional: Install other browsers (comment out to save time)
# npx playwright install firefox webkit
# npx playwright install-deps firefox webkit

cd ~

# Create UI optimization toolkit
cat > ui-optimizer.js << 'EOF'
const { chromium } = require('playwright');
const fs = require('fs').promises;
const path = require('path');

class UIOptimizer {
    constructor() {
        this.browser = null;
        this.page = null;
    }

    async initialize(headless = true) {
        this.browser = await chromium.launch({
            headless,
            args: ['--no-sandbox', '--disable-setuid-sandbox']
        });
        this.page = await this.browser.newPage();
    }

    async captureResponsive(url, outputDir = './screenshots') {
        await fs.mkdir(outputDir, { recursive: true });
        
        const viewports = [
            { width: 375, height: 667, device: 'iPhone-SE' },
            { width: 768, height: 1024, device: 'iPad' },
            { width: 1366, height: 768, device: 'laptop' },
            { width: 1920, height: 1080, device: 'desktop' }
        ];

        const screenshots = [];
        
        for (const viewport of viewports) {
            await this.page.setViewportSize(viewport);
            await this.page.goto(url, { waitUntil: 'networkidle' });
            
            const filename = `${viewport.device}-${viewport.width}x${viewport.height}.png`;
            const filepath = path.join(outputDir, filename);
            
            await this.page.screenshot({ 
                path: filepath,
                fullPage: true 
            });
            
            screenshots.push({
                device: viewport.device,
                dimensions: `${viewport.width}x${viewport.height}`,
                path: filepath
            });
            
            console.log(`✅ Captured ${viewport.device} view`);
        }
        
        return screenshots;
    }

    async analyzeColors() {
        return await this.page.evaluate(() => {
            const elements = document.querySelectorAll('*');
            const colors = new Set();
            
            elements.forEach(el => {
                const style = window.getComputedStyle(el);
                colors.add(style.color);
                colors.add(style.backgroundColor);
            });
            
            return Array.from(colors).filter(c => c !== 'rgba(0, 0, 0, 0)');
        });
    }

    async injectCSS(css) {
        await this.page.addStyleTag({ content: css });
    }

    async compareBeforeAfter(url, cssChanges, outputDir = './comparisons') {
        await fs.mkdir(outputDir, { recursive: true });
        
        // Capture before
        await this.page.goto(url, { waitUntil: 'networkidle' });
        await this.page.screenshot({ 
            path: path.join(outputDir, 'before.png'),
            fullPage: true 
        });
        
        // Apply CSS and capture after
        await this.injectCSS(cssChanges);
        await this.page.screenshot({ 
            path: path.join(outputDir, 'after.png'),
            fullPage: true 
        });
        
        console.log('✅ Before/After comparison saved');
    }

    async cleanup() {
        if (this.browser) {
            await this.browser.close();
        }
    }
}

// Export for use in other scripts
module.exports = UIOptimizer;

// CLI usage
if (require.main === module) {
    (async () => {
        const optimizer = new UIOptimizer();
        await optimizer.initialize();
        
        // Example usage - modify URL as needed
        const url = process.argv[2] || 'https://example.com';
        console.log(`🔍 Analyzing ${url}...`);
        
        await optimizer.captureResponsive(url);
        const colors = await optimizer.analyzeColors();
        
        console.log('\n📊 Color Palette Found:');
        colors.forEach(color => console.log(`  - ${color}`));
        
        await optimizer.cleanup();
        console.log('\n✨ Analysis complete!');
    })();
}
EOF

# Create Python version for flexibility
cat > ui_optimizer.py << 'EOF'
from playwright.sync_api import sync_playwright
import os
from pathlib import Path

class UIOptimizer:
    def __init__(self):
        self.playwright = None
        self.browser = None
        self.page = None
    
    def initialize(self, headless=True):
        self.playwright = sync_playwright().start()
        self.browser = self.playwright.chromium.launch(
            headless=headless,
            args=['--no-sandbox', '--disable-setuid-sandbox']
        )
        self.page = self.browser.new_page()
    
    def capture_responsive(self, url, output_dir='./screenshots'):
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
            self.page.goto(url, wait_until='networkidle')
            
            filename = f"{viewport['device']}-{viewport['width']}x{viewport['height']}.png"
            filepath = os.path.join(output_dir, filename)
            
            self.page.screenshot(path=filepath, full_page=True)
            screenshots.append({
                'device': viewport['device'],
                'path': filepath
            })
            
            print(f"✅ Captured {viewport['device']} view")
        
        return screenshots
    
    def cleanup(self):
        if self.browser:
            self.browser.close()
        if self.playwright:
            self.playwright.stop()

# Example usage
if __name__ == "__main__":
    import sys
    
    optimizer = UIOptimizer()
    optimizer.initialize()
    
    url = sys.argv[1] if len(sys.argv) > 1 else "https://example.com"
    print(f"🔍 Analyzing {url}...")
    
    optimizer.capture_responsive(url)
    optimizer.cleanup()
    print("✨ Analysis complete!")
EOF

# Install Python Playwright
pip install playwright
python -m playwright install

# Start virtual display
echo "🖥️ Starting virtual display..."
Xvfb :99 -screen 0 1920x1080x24 -nolisten tcp -nolisten unix &
export DISPLAY=:99

# Create usage documentation
cat > ~/web-ui-optimizer/README.md << 'EOF'
# Web UI Optimizer with Playwright 🎭

## Quick Start

### With Claude Code:
```bash
cd ~/web-ui-optimizer
claude-code

# Ask Claude Code to:
# "Run ui-optimizer.js on localhost:3000 and analyze the results"
# "Modify the CSS to improve contrast and show me before/after"
# "Test responsive design at different breakpoints"
```

### Direct Usage:

**JavaScript:**
```bash
node ui-optimizer.js https://your-site.com
```

**Python:**
```bash
python ui_optimizer.py https://your-site.com
```

### Use Cases for Claude Code:

1. **Responsive Testing:**
   "Test how my site looks on mobile, tablet, and desktop"

2. **A/B Testing CSS Changes:**
   "Try these CSS changes and show me before/after screenshots"

3. **Color Analysis:**
   "Extract the color palette from my website"

4. **Performance Testing:**
   "Measure page load times and rendering performance"

5. **Accessibility Checking:**
   "Check color contrast ratios for WCAG compliance"

## API Usage in Your Own Scripts:

```javascript
const UIOptimizer = require('./ui-optimizer');

async function optimizeMyUI() {
    const optimizer = new UIOptimizer();
    await optimizer.initialize();
    
    // Your custom logic here
    await optimizer.captureResponsive('http://localhost:3000');
    
    await optimizer.cleanup();
}
```

## Troubleshooting:

- **Browser won't start:** Check if DISPLAY=:99 is set
- **Screenshots are blank:** Add waitUntil: 'networkidle'
- **Permission denied:** Use --no-sandbox flag

## Next Steps:

1. Integrate with your local dev server
2. Set up automated visual regression testing
3. Create custom optimization rules
4. Build a UI improvement pipeline with Claude Code
EOF

echo "✅ Setup complete!"
echo ""
echo "📂 Your UI optimization toolkit is ready in: ~/web-ui-optimizer"
echo "🤖 Start Claude Code and navigate to that directory"
echo "📖 See ~/web-ui-optimizer/README.md for usage examples"
echo ""
echo "Quick test: cd ~/web-ui-optimizer && node ui-optimizer.js"