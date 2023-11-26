import SwiftUI
import SceneKit

struct MenuOptions: View {
	var body: some View {
		VStack {
			// Add more Spacer elements to move the arrow down
			Spacer()
			Spacer()
			
			HStack {
				Spacer()
				
				// Add the chevron arrow pointing down
				Image(systemName: "chevron.down")
				
				Spacer()
			}
		}
	}
}
