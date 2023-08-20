import SwiftUI
import SceneKit

struct MenuOptions: View {
	var body: some View {
		HStack(spacing: 0) {
			
			Spacer()
			
			// Logic to create shapes
			
			HStack {
				VStack {
					Spacer()
					
					Button("Line") {
						// Handle drawing shapes
					}
					Button("Poly Line") {
						// Handle drawing shapes
					}
					Spacer()
				}

				
				VStack {
					Spacer()
					Button("Arc") {
						// Handle drawing shapes
					}
					Button("Circle") {
						// Handle drawing shapes
					}
					Spacer()
				}
			}
			

			
			// Logic to create 3d mesh objects and modify them.

			//			TBD...
//			Button("Create 3D Objects") {
//				// Handle 3D objects
//			}
//			Spacer()
//			//			TBD...
//			Button("Add Chamfers") {
//				// Handle chamfers
//			}
			Spacer()
			// Add more options as needed
		}
	}
}
