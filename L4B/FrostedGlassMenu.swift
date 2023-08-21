
import SwiftUI
import SceneKit


struct FrostedGlassMenu: NSViewRepresentable {
	func makeNSView(context: Context) -> NSVisualEffectView {
		let view = NSVisualEffectView()
		view.blendingMode = .withinWindow
		view.material = .underWindowBackground
		view.state = .active
		view.wantsLayer = true
		view.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.7).cgColor // Slightly transparent
		
		// Apply corner radius only to the top corners
		view.layer?.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		view.layer?.cornerRadius = 20 // Adjust the radius as needed
		
		return view
	}
	
	func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
		// Update view if needed
	}
}
