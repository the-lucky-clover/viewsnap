import Cocoa

// MARK: - Multi-Monitor Support
extension SmartAnchorVideo {
    private func getActiveScreen(for window: NSWindow) -> NSScreen? {
        let windowCenter = NSPoint(
            x: window.frame.midX,
            y: window.frame.midY
        )
        
        return NSScreen.screens.first { screen in
            screen.frame.contains(windowCenter)
        } ?? window.screen ?? NSScreen.main
    }
    
    private func getOccupiedEdges(for screen: NSScreen) -> Set<ScreenEdge> {
        var occupied: Set<ScreenEdge> = []
        
        for (window, state) in anchoredWindows {
            guard let winScreen = getActiveScreen(for: window), winScreen == screen else { continue }
            if state.isAnchored {
                occupied.insert(state.anchorEdge)
            }
        }
        
        return occupied
    }
    
    private func resolveEdgeConflict(for window: NSWindow, preferredEdge: ScreenEdge) -> ScreenEdge {
        guard let screen = getActiveScreen(for: window) else { return preferredEdge }
        let occupied = getOccupiedEdges(for: screen)
        
        if occupied.contains(preferredEdge) {
            let alternatives: [ScreenEdge]
            switch preferredEdge {
            case .left:
                alternatives = [.right, .top, .bottom]
            case .right:
                alternatives = [.left, .top, .bottom]
            case .top, .bottom:
                alternatives = [.left, .right]
            default:
                alternatives = [.left, .right, .top, .bottom]
            }
            
            for alt in alternatives where !occupied.contains(alt) {
                return alt
            }
        }
        
        return preferredEdge
    }
}