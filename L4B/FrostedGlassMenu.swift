
import SwiftUI
import SceneKit


struct FrostedGlassMenu: NSViewRepresentable {
	func makeNSView(context: Context) -> NSVisualEffectView {
		let view = NSVisualEffectView()
		
		// Use the .fullScreenUI appearance to emulate an iOS frosted glass style
		view.material = .fullScreenUI
		view.blendingMode = .behindWindow
		view.state = .active
		
		// Apply corner radius only to the top corners
		view.wantsLayer = true
		view.layer?.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		view.layer?.cornerRadius = 20
		
		return view
	}
	
	
	func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
		// Update view if needed
	}
}
