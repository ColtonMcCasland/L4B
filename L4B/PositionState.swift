import SceneKit
import SwiftUI

class PositionState: ObservableObject {
	@Published var position: SCNVector3 = SCNVector3Zero {
		didSet {
			print("Position updated: \(position)")
		}
	}
}
