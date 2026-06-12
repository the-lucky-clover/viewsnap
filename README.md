# ViewSnap - IINA Smart Anchor Video Plugin

## Overview
Swift-based IINA plugin that dynamically anchors video windows to display edges based on aspect ratio.

## Features
- **Aspect-Ratio-Based Anchoring**: Vertical videos (9:16) anchor to left/right edges; horizontal videos (16:9) anchor to top/bottom
- **Smooth Animations**: 300ms ease-in-out transitions when anchoring
- **Manual Override**: Drag to temporarily disable auto-anchoring
- **Keyboard Toggle**: `Ctrl+Shift+A` to enable/disable anchoring
- **Multi-Monitor Support**: Detects active screen and resolves edge conflicts
- **Visual Guidelines**: Subtle blue outline shows when anchored

## Installation
1. Build the plugin using Swift Package Manager
2. Place the resulting `.bundle` in `~/Library/Application Support/IINA/plugins/`
3. Enable via IINA Preferences → Plugins

## Usage
1. Open any video in IINA
2. Plugin automatically detects aspect ratio and anchors to nearest edge
3. Drag window to move freely (override)
4. Press `Ctrl+Shift+A` to re-enable anchoring

## Technical
- Swift 5.9+
- Requires IINA with Swift plugin support
- Uses NSAnimationContext for smooth transitions