// ViewSnap - IINA Smart Anchor Video Plugin
// Dynamically anchors videos to display edges based on aspect ratio

const anchoredWindows = new Map();
const ASPECT_THRESHOLD = preferences.aspectThreshold || 1.3;
const EDGE_MARGIN = preferences.edgeMargin || 20;
const ANIMATION_DURATION = preferences.animationDuration || 300;

// Screen edge enum
const ScreenEdge = {
  NONE: 'none',
  LEFT: 'left',
  RIGHT: 'right',
  TOP: 'top',
  BOTTOM: 'bottom'
};

// Get window aspect ratio
function getAspectRatio(window) {
  const frame = window.frame();
  return { width: frame.width / frame.height, height: frame.height / frame.width };
}

// Check if video is vertical
function isVerticalVideo(window) {
  const aspect = getAspectRatio(window);
  return aspect.width < ASPECT_THRESHOLD;
}

// Find closest screen edge
function findClosestEdge(window) {
  const screen = window.screen() || iina.window().screen();
  const windowFrame = window.frame();
  const screenFrame = screen.frame();
  
  const distances = {
    [ScreenEdge.LEFT]: windowFrame.x - screenFrame.x,
    [ScreenEdge.RIGHT]: (screenFrame.x + screenFrame.width) - (windowFrame.x + windowFrame.width),
    [ScreenEdge.TOP]: (screenFrame.y + screenFrame.height) - (windowFrame.y + windowFrame.height),
    [ScreenEdge.BOTTOM]: windowFrame.y - screenFrame.y
  };
  
  return Object.entries(distances).reduce((min, entry) => 
    entry[1] < min[1] ? entry : min
  )[0];
}

// Find vertical anchor edge (left or right)
function findVerticalAnchorEdge(window) {
  const edge = findClosestEdge(window);
  if (edge === ScreenEdge.LEFT || edge === ScreenEdge.RIGHT) {
    return edge;
  }
  return window.frame().x < (window.screen().frame().x + window.screen().frame().width / 2) 
    ? ScreenEdge.LEFT : ScreenEdge.RIGHT;
}

// Find horizontal anchor edge (top or bottom)
function findHorizontalAnchorEdge(window) {
  const edge = findClosestEdge(window);
  if (edge === ScreenEdge.TOP || edge === ScreenEdge.BOTTOM) {
    return edge;
  }
  return window.frame().y < (window.screen().frame().y + window.screen().frame().height / 2) 
    ? ScreenEdge.BOTTOM : ScreenEdge.TOP;
}

// Animate window to edge
function animateToEdge(window, edge) {
  const currentFrame = window.frame();
  const screen = window.screen() || iina.window().screen();
  const screenFrame = screen.frame();
  let newOrigin = { ...currentFrame };
  
  switch (edge) {
    case ScreenEdge.LEFT:
      newOrigin.x = screenFrame.x + EDGE_MARGIN;
      break;
    case ScreenEdge.RIGHT:
      newOrigin.x = (screenFrame.x + screenFrame.width) - currentFrame.width - EDGE_MARGIN;
      break;
    case ScreenEdge.TOP:
      newOrigin.y = (screenFrame.y + screenFrame.height) - currentFrame.height - EDGE_MARGIN;
      break;
    case ScreenEdge.BOTTOM:
      newOrigin.y = screenFrame.y + EDGE_MARGIN + EDGE_MARGIN;
      break;
  }
  
  window.setBounds(newOrigin.x, newOrigin.y, currentFrame.width, currentFrame.height, true);
}

// Anchor window to appropriate edge
function anchorWindow(window) {
  const state = anchoredWindows.get(window.id);
  
  if (state?.isAnchored) return;
  
  const edge = isVerticalVideo(window) 
    ? findVerticalAnchorEdge(window) 
    : findHorizontalAnchorEdge(window);
  
  animateToEdge(window, edge);
  
  anchoredWindows.set(window.id, {
    isAnchored: true,
    anchorEdge: edge,
    originalPosition: { ...window.frame() }
  });
  
  if (preferences.showGuidelines) {
    showGuideline(window);
  }
}

// Show visual guideline
function showGuideline(window) {
  const overlay = document.createElement('div');
  Object.assign(overlay.style, {
    position: 'absolute',
    inset: '-2px',
    border: '1px solid #007aff',
    borderRadius: '4px',
    pointerEvents: 'none',
    animation: 'fadeOut 2s ease-out forwards'
  });
  
  const style = document.createElement('style');
  style.textContent = '@keyframes fadeOut { to { opacity: 0; } }';
  document.head.appendChild(style);
  
  window.contentView().appendChild(overlay);
  
  setTimeout(() => {
    overlay.remove();
    style.remove();
  }, 2000);
}

// Toggle anchoring on/off
function toggleAnchoring() {
  iina.windows().forEach(window => {
    const state = anchoredWindows.get(window.id) || { isAnchored: false };
    state.isAnchored = !state.isAnchored;
    
    if (!state.isAnchored) {
      anchoredWindows.delete(window.id);
    } else {
      anchorWindow(window);
    }
    
    anchoredWindows.set(window.id, state);
  });
}

// Check all windows periodically
function checkWindows() {
  if (!preferences.enabled) return;
  
  iina.windows().forEach(window => {
    const state = anchoredWindows.get(window.id);
    if (!state?.isAnchored && isVideoWindow(window)) {
      anchorWindow(window);
    }
  });
}

// Check if window is a video window
function isVideoWindow(window) {
  return window.isVideoWindow && window.isVideoWindow();
}

// Setup drag monitoring
function setupDragMonitoring(window) {
  const observer = new MutationObserver(() => {
    const state = anchoredWindows.get(window.id);
    if (!state?.isAnchored) return;
    
    const currentX = window.frame().x;
    const currentY = window.frame().y;
    const screen = window.screen()?.frame() || iina.window().screen().frame();
    
    let isFarFromEdge = false;
    switch (state.anchorEdge) {
      case ScreenEdge.LEFT:
        isFarFromEdge = currentX > screen.x + 30;
        break;
      case ScreenEdge.RIGHT:
        isFarFromEdge = currentX < screen.x + screen.width - 30;
        break;
      case ScreenEdge.TOP:
        isFarFromEdge = currentY < screen.y + 30;
        break;
      case ScreenEdge.BOTTOM:
        isFarFromEdge = currentY > screen.y + screen.height - 30;
        break;
    }
    
    if (isFarFromEdge) {
      state.isAnchored = false;
      anchoredWindows.set(window.id, state);
    }
  });
  
  // Monitor window position changes
  window.onBoundsChanged(() => {
    const state = anchoredWindows.get(window.id);
    if (!state?.isAnchored) return;
    
    const currentX = window.frame().x;
    const currentY = window.frame().y;
    const screen = window.screen()?.frame() || iina.window().screen().frame();
    
    let isFarFromEdge = false;
    switch (state.anchorEdge) {
      case ScreenEdge.LEFT:
        isFarFromEdge = currentX > screen.x + 30;
        break;
      case ScreenEdge.RIGHT:
        isFarFromEdge = currentX < screen.x + screen.width - 30;
        break;
      case ScreenEdge.TOP:
        isFarFromEdge = currentY < screen.y + 30;
        break;
      case ScreenEdge.BOTTOM:
        isFarFromEdge = currentY > screen.y + screen.height - 30;
        break;
    }
    
    if (isFarFromEdge) {
      state.isAnchored = false;
      anchoredWindows.set(window.id, state);
    }
  });
}

// Initialize plugin
iina.onReady(() => {
  console.log('ViewSnap plugin loaded');
  
  // Register hotkey
  iina.registerShortcut('ctrl+shift+a', toggleAnchoring);
  
  // Start monitoring
  setInterval(checkWindows, 1000);
  
  // Setup for existing windows
  iina.windows().forEach(window => {
    setupDragMonitoring(window);
  });
  
  // Setup for new windows
  iina.on('windowDidLoad', (window) => {
    setupDragMonitoring(window);
  });
});

// Handle aspect ratio changes
iina.on('videoSizeChanged', (window) => {
  const state = anchoredWindows.get(window.id);
  if (state?.isAnchored) {
    // Re-anchor on aspect ratio change
    state.isAnchored = false;
    anchoredWindows.set(window.id, state);
    anchorWindow(window);
  }
});