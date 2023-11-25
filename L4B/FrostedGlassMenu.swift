
import SwiftUI
import SceneKit


struct FrostedGlassMenu: NSViewRepresentable {
	func makeNSView(context: Context) -> NSVisualEffectView {
		let view = NSVisualEffectView()
		
		// Adjust the material and blending mode for a lighter, more translucent effect
		view.material = .hudWindow // or .menu for a slightly different effect
		view.blendingMode = .withinWindow // Adjust the blending mode for a lighter effect
		view.state = .active
		
		// Apply corner radius only to the top corners
		view.wantsLayer = true
		view.layer?.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		view.layer?.cornerRadius = 20
		
		// Set the background color to clear for added transparency
		view.layer?.backgroundColor = NSColor.clear.cgColor
		
		return view
	}
	
	func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
		// Update view if needed
	}
}
