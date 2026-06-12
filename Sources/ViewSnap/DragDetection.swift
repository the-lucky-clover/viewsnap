import Cocoa

// MARK: - Drag Detection Extension
extension SmartAnchorVideo {
    private func setupDragMonitoring(for window: NSWindow) {
        window.delegate = self
    }
}

// MARK: - NSWindowDelegate
extension SmartAnchorVideo: NSWindowDelegate {
    func windowDidMove(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        
        if var state = anchoredWindows[window], state.isAnchored {
            let anchorMargin: CGFloat = 30
            let currentX = window.frame.minX
            let currentY = window.frame.minY
            let screen = window.screen?.frame ?? NSScreen.main?.frame ?? .zero
            
            let isFarFromEdge: Bool
            switch state.anchorEdge {
            case .left:
                isFarFromEdge = currentX > screen.minX + anchorMargin
            case .right:
                isFarFromEdge = currentX < screen.maxX - anchorMargin
            case .top:
                isFarFromEdge = currentY < screen.maxY - anchorMargin
            case .bottom:
                isFarFromEdge = currentY > screen.minY + anchorMargin
            default:
                isFarFromEdge = false
            }
            
            if isFarFromEdge {
                state.isAnchored = false
                anchoredWindows[window] = state
            }
        }
    }
}