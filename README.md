# ViewSnap - IINA Smart Anchor Video Plugin

Dynamically anchors video windows to display edges based on aspect ratio, with optional manual overrides.

## Installation

In IINA:
1. **Settings** → **Plugins** → **Install from GitHub**
2. Enter: `the-lucky-clover/ViewSnap`
3. Enable the plugin in Plugins preferences

Alternatively:
1. Download the latest release from GitHub
2. Double-click the `ViewSnap.iinaplgz` file
3. IINA will install the plugin automatically

## Usage

1. Open any video in IINA
2. Plugin automatically detects aspect ratio and anchors to nearest edge
3. Drag window to move freely (manual override)
4. Press `Ctrl+Shift+A` to toggle anchoring on/off

## Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| `enabled` | true | Master enable/disable |
| `aspectThreshold` | 1.3 | Videos below this ratio anchor vertically |
| `edgeMargin` | 20 | Distance from screen edge in pixels |
| `animationDuration` | 300 | Animation time in milliseconds |
| `showGuidelines` | true | Show visual feedback when anchored |

## Features

- **Aspect-Ratio-Based Anchoring**: Vertical videos (9:16) anchor to left/right edges; horizontal videos (16:9) anchor to top/bottom
- **Smooth Animations**: Configurable animation when anchoring
- **Manual Override**: Drag to temporarily disable auto-anchoring
- **Keyboard Toggle**: `Ctrl+Shift+A` to enable/disable anchoring
- **Multi-Monitor Support**: Detects active screen and resolves edge conflicts
- **Visual Guidelines**: Subtle blue outline shows when anchored

---

Made with <3 by <a href="https://soundcloud.com/lucky-clover/" target="_blank">Lucky Clover</a>