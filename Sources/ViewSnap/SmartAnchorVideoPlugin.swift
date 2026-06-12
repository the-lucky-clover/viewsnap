import Cocoa
import IINA

// MARK: - Plugin Definition
class SmartAnchorVideo: NSObject, IWPlugin {
    private var anchoredWindows: [NSWindow: AnchorState] = [:]
    private var toggleHotkey: IWHotkey?
    private let aspectThreshold: CGFloat = 1.3
    
    struct AnchorState {
        var isAnchored: Bool = false
        var anchorEdge: ScreenEdge = .none
        var originalPosition: NSPoint = .zero
    }
    
    enum ScreenEdge {
        case none, left, right, top, bottom
    }
    
    // MARK: - Plugin Lifecycle
    override func awake(with controller: IWPluginViewController) {
        setupHotkey()
        startMonitoring()
    }
    
    private func setupHotkey() {
        toggleHotkey = IWHotkey(
            keyCode: 43, // 'a'
            modifiers: [.control, .shift],
            target: self,
            action: #selector(toggleAnchoring)
        )
    }
    
    // MARK: - Aspect Ratio Detection
    private func getAspectRatio(of window: NSWindow) -> (width: CGFloat, height: CGFloat) {
        let frame = window.frame
        return (frame.width / frame.height, frame.height / frame.width)
    }
    
    private func isVerticalVideo(window: NSWindow) -> Bool {
        let aspect = getAspectRatio(of: window)
        return aspect.width < aspectThreshold
    }
    
    // MARK: - Edge Proximity Detection
    private func findClosestEdge(for window: NSWindow) -> ScreenEdge {
        guard let screen = window.screen else { return .none }
        let windowFrame = window.frame
        let screenFrame = screen.frame
        
        let distances: [ScreenEdge: CGFloat] = [
            .left: windowFrame.minX - screenFrame.minX,
            .right: screenFrame.maxX - windowFrame.maxX,
            .top: screenFrame.maxY - windowFrame.maxY,
            .bottom: windowFrame.minY - screenFrame.minY
        ]
        
        return distances.min(by: { $0.value < $1.value })?.key ?? .none
    }
    
    // MARK: - Window Anchoring
    private func anchorWindow(_ window: NSWindow) {
        guard var state = anchoredWindows[window], state.isAnchored == false else { return }
        
        let edge = isVerticalVideo(window: window) ? 
            findVerticalAnchorEdge(for: window) : 
            findHorizontalAnchorEdge(for: window)
        
        animateToEdge(window, edge: edge)
        state.isAnchored = true
        state.anchorEdge = edge
        anchoredWindows[window] = state
    }
    
    private func findVerticalAnchorEdge(for window: NSWindow) -> ScreenEdge {
        let edge = findClosestEdge(for: window)
        return (edge == .left || edge == .right) ? edge : (window.frame.midX < window.screen?.frame.midX ?? 0 ? .left : .right)
    }
    
    private func findHorizontalAnchorEdge(for window: NSWindow) -> ScreenEdge {
        let edge = findClosestEdge(for: window)
        return (edge == .top || edge == .bottom) ? edge : (window.frame.midY < window.screen?.frame.midY ?? 0 ? .bottom : .top)
    }
    
    // MARK: - Smooth Animation
    private func animateToEdge(_ window: NSWindow, edge: ScreenEdge) {
        let currentFrame = window.frame
        let screenFrame = window.screen?.frame ?? NSScreen.main?.frame ?? .zero
        var newOrigin = currentFrame.origin
        
        switch edge {
        case .left:
            newOrigin.x = screenFrame.minX + 20
        case .right:
            newOrigin.x = screenFrame.maxX - currentFrame.width - 20
        case .top:
            newOrigin.y = screenFrame.maxY - currentFrame.height - 20
        case .bottom:
            newOrigin.y = screenFrame.minY + 20 + (NSScreen.screens.first?.frame.height ?? 0) * 0.1
        default:
            break
        }
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().setFrame(NSRect(origin: newOrigin, size: currentFrame.size), display: true)
        }
    }
    
    // MARK: - Keyboard Toggle
    @objc private func toggleAnchoring() {
        for (window, var state) in anchoredWindows {
            state.isAnchored.toggle()
            if state.isAnchored {
                anchorWindow(window)
            } else {
                showGuideline(window)
            }
            anchoredWindows[window] = state
        }
    }
    
    // MARK: - Visual Feedback
    private func showGuideline(_ window: NSWindow) {
        guard let contentView = window.contentView else { return }
        
        let guideline = NSView()
        guideline.wantsLayer = true
        guideline.layer?.borderColor = NSColor.systemBlue.cgColor
        guideline.layer?.borderWidth = 1
        guideline.layer?.backgroundColor = NSColor.clear
        
        contentView.addSubview(guideline)
        guideline.frame = contentView.bounds.insetBy(dx: -2, dy: -2)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            guideline.removeFromSuperview()
        }
    }
    
    // MARK: - Monitoring
    private func startMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkWindows()
        }
    }
    
    private func checkWindows() {
        for window in NSApp.windows {
            guard isVideoWindow(window) else { continue }
            let state = anchoredWindows[window] ?? AnchorState()
            if shouldAutoAnchor(state: state) {
                anchorWindow(window)
            }
        }
    }
    
    private func isVideoWindow(_ window: NSWindow) -> Bool {
        return window.className.contains("Video") || window.identifier?.rawValue.contains("Player") == true
    }
    
    private func shouldAutoAnchor(state: AnchorState) -> Bool {
        return !state.isAnchored
    }
}