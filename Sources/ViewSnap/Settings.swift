import Cocoa
import IINA

// MARK: - User Preferences
struct SmartAnchorSettings {
    static let shared = SmartAnchorSettings()
    
    private let defaults = UserDefaults.standard
    
    var isEnabled: Bool {
        get { defaults.bool(forKey: "SmartAnchorEnabled") }
        set { defaults.set(newValue, forKey: "SmartAnchorEnabled") }
    }
    
    var aspectRatioThreshold: CGFloat {
        get { defaults.object(forKey: "AspectRatioThreshold") as? CGFloat ?? 1.3 }
        set { defaults.set(newValue, forKey: "AspectRatioThreshold") }
    }
    
    var edgeMargin: CGFloat {
        get { defaults.object(forKey: "EdgeMargin") as? CGFloat ?? 20 }
        set { defaults.set(newValue, forKey: "EdgeMargin") }
    }
    
    var animationDuration: Double {
        get { defaults.object(forKey: "AnimationDuration") as? Double ?? 0.3 }
        set { defaults.set(newValue, forKey: "AnimationDuration") }
    }
    
    var showGuidelines: Bool {
        get { defaults.bool(forKey: "ShowGuidelines") }
        set { defaults.set(newValue, forKey: "ShowGuidelines") }
    }
}

// MARK: - Settings Panel Controller
class SmartAnchorSettingsViewController: IWPluginViewController {
    private var enableCheckbox: NSButton!
    private var thresholdField: NSTextField!
    private var marginField: NSTextField!
    
    override func loadView() {
        self.view = NSView()
        view.wantsLayer = true
        
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .left
        view.addSubview(stack)
        
        enableCheckbox = NSButton(checkboxWithTitle: "Enable Smart Anchor", target: self, action: #selector(toggleEnabled))
        enableCheckbox.state = SmartAnchorSettings.shared.isEnabled ? .on : .off
        stack.addArrangedSubview(enableCheckbox)
        
        thresholdField = NSTextField(labelWithAttributedString: NSAttributedString(string: "Aspect Ratio Threshold:"))
        stack.addArrangedSubview(thresholdField)
    }
    
    @objc private func toggleEnabled() {
        SmartAnchorSettings.shared.isEnabled = enableCheckbox.state == .on
    }
}