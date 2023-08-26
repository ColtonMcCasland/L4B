import SwiftUI
import SceneKit


struct SandboxView: View {
	@ObservedObject var rotationState = RotationState()
	@ObservedObject var positionState = PositionState() // Add this line
	

	var body: some View {
		ZStack {
			SandboxContentView(rotationState: rotationState) // Pass both states here
			VStack {
				
				HStack {
					Spacer()
					CubeControllerView(rotationState: rotationState)
					.frame(width: 100, height: 100)
						.padding(.top, 10)
						.padding(.trailing, 10)
				}
				Spacer()
			}
		}
	}
}
