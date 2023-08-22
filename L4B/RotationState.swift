import SceneKit
import SwiftUI


class RotationState: ObservableObject {
	@Published var rotation: SCNVector3 = SCNVector3(0, 0, 0)
}
