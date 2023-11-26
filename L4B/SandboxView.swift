import SwiftUI
import SceneKit

struct SandboxView: View {
	@ObservedObject var rotationState = RotationState()
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
					
					VStack {
						CubeControllerView(rotationState: rotationState, cameraControl: cameraControl)
							.frame(width: 100, height: 100)
							.padding(.top, 10)
							.padding(.trailing, 10)
						
					
						
						HStack {
							Button(action: {
								// Reset the camera's rotation to the initial position
								self.rotationState.rotation = SCNVector3(CGFloat.pi / 8, CGFloat.pi / 8, 0)
							}) {
								Image(systemName: "house.fill") // House icon
									.resizable()
									.frame(width: 18, height: 18) // Adjust the width and height as needed
									.padding(3) // Adjust the padding as needed
									.background(Color.white)
									.cornerRadius(16)
									.foregroundColor(Color.gray)
							}
							
							
						}
						
						
						
						Spacer()

					}
					
					
				}
				.cornerRadius(16) // Adjust the corner radius value as needed
				
				Spacer()
			}
		}
	}

}
