# viewsnap - iina smart anchor video plugin

dynamically anchors video windows to display edges based on aspect ratio, with optional manual overrides.

## installation

in iina:
1. **settings** → **plugins** → **install from github**
2. enter: `the-lucky-clover/viewsnap`
3. enable the plugin in plugins preferences

alternatively:
1. download the latest release from github
2. double-click the `viewsnap.iinaplgz` file
3. iina will install the plugin automatically

## usage

1. open any video in iina
2. plugin automatically detects aspect ratio and anchors to nearest edge
3. drag window to move freely (manual override)
4. press `ctrl+shift+a` to toggle anchoring on/off

## configuration

| setting | default | description |
|---------|---------|-------------|
| `enabled` | true | master enable/disable |
| `aspect-threshold` | 1.3 | videos below this ratio anchor vertically |
| `edge-margin` | 20 | distance from screen edge in pixels |
| `animation-duration` | 300 | animation time in milliseconds |
| `show-guidelines` | true | show visual feedback when anchored |

## features

- **aspect-ratio-based anchoring**: vertical videos (9:16) anchor to left/right edges; horizontal videos (16:9) anchor to top/bottom
- **smooth animations**: configurable animation when anchoring
- **manual override**: drag to temporarily disable auto-anchoring
- **keyboard toggle**: `ctrl+shift+a` to enable/disable anchoring
- **multi-monitor support**: detects active screen and resolves edge conflicts
- **visual guidelines**: subtle blue outline shows when anchored

---

made with <3 by <a href="https://soundcloud.com/lucky-clover/" target="_blank">lucky clover</a>