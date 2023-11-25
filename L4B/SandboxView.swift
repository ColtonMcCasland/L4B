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

					MenuOptions()
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
}
