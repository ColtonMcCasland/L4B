import SceneKit
import SwiftUI


class RotationState: ObservableObject {
	@Published var rotation: SCNVector3 = SCNVector3Zero {
		didSet {
			print("Rotation updated: \(rotation)")
		}
	}
}

