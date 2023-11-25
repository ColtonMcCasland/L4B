import SceneKit
import SwiftUI


class RotationState: ObservableObject {
	@Published var rotation: SCNVector3 = SCNVector3(CGFloat.pi / 8, CGFloat.pi / 8, 0)
}
