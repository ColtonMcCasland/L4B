import SwiftUI
import SceneKit

struct SandboxView: View {
	@ObservedObject var rotationState = RotationState()
	@ObservedObject var positionState = PositionState()
	@StateObject var cameraControl = CameraControl()

	var body: some View {
		ZStack {
			SandboxContentView(rotationState: rotationState, cameraControl: cameraControl)

			VStack {
				ZStack {
					FrostedGlassMenu()
						.frame(height: 80)  // Only set the height

					MenuOptions(
						onFrontButtonClicked: adjustCameraToFrontFace,
						onBackButtonClicked: adjustCameraToBackFace,
						onLeftButtonClicked: adjustCameraToLeftFace,
						onRightButtonClicked: adjustCameraToRightFace,
						onTopButtonClicked: adjustCameraToTopFace,
						onBottomButtonClicked: adjustCameraToBottomFace
					)
						.frame(height: 40)  // Match the height
				}
				
				// Cube below the header
				HStack {
					Spacer()
					CubeControllerView(rotationState: rotationState, cameraControl: cameraControl)
						.frame(width: 100, height: 100)
						.padding(.top, 10)
						.padding(.trailing, 10)
				}
				
				Spacer()
			}
		}
	}
	
	private func adjustCameraToFrontFace() {
		cameraControl.targetPosition = SCNVector3(0, 0, 30)
		rotationState.rotation = SCNVector3(0, 0, 0)
	}
	
	// Implement similar methods for other cube faces
	private func adjustCameraToTopFace() {
		cameraControl.targetPosition = SCNVector3(0, 0, 30) // Above the cube
		rotationState.rotation = SCNVector3(CGFloat.pi / 2, 0, 0) // Looking down
	}
	
	// Implement similar methods for other cube faces
	private func adjustCameraToBackFace() {
		cameraControl.targetPosition = SCNVector3(0, 0, 30) // Opposite the front
		rotationState.rotation = SCNVector3(0, CGFloat.pi, 0) // Rotated 180 degrees around Y axis
	}
	
	private func adjustCameraToBottomFace() {
		cameraControl.targetPosition = SCNVector3(0, 0, 30) // Above the cube
		rotationState.rotation = SCNVector3(-CGFloat.pi / 2, 0, 0) // Looking down
	}

	private func adjustCameraToLeftFace() {
		cameraControl.targetPosition = SCNVector3(0, 0, 30) // Left side of the cube
		rotationState.rotation = SCNVector3(0, CGFloat.pi / 2, 0) // Rotated 90 degrees to the left
	}
	
	private func adjustCameraToRightFace() {
		cameraControl.targetPosition = SCNVector3(0, 0, 30) // Right side of the cube
		rotationState.rotation = SCNVector3(0, -CGFloat.pi / 2, 0) // Rotated 90 degrees to the right
	}

}
