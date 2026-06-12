import Cocoa
import IINA

// MARK: - Plugin Bundle Entry Point
@objc(ViewSnapPlugin)
class ViewSnapPlugin: IWPluginBundle {
    private let plugin = SmartAnchorVideo()
    
    override func awake() {
        plugin.awake()
    }
    
    @objc var name: String {
        return "ViewSnap"
    }
    
    @objc var version: String {
        return "1.0.0"
    }
    
    @objc var author: String {
        return "Custom Plugin"
    }
    
    @objc var description: String {
        return "Dynamically anchors videos to display edges based on aspect ratio"
    }
}