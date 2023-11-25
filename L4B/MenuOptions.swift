import SwiftUI
import SceneKit

struct MenuOptions: View {
	var onFrontButtonClicked: () -> Void
	var onBackButtonClicked: () -> Void
	var onLeftButtonClicked: () -> Void
	var onRightButtonClicked: () -> Void
	var onTopButtonClicked: () -> Void
	var onBottomButtonClicked: () -> Void
	

	var body: some View {
		HStack {
			Spacer()
			
			VStack {
				Spacer()
				Button("Front") { onFrontButtonClicked() }
				Spacer()
				Button("Back") { onBackButtonClicked() }
				Spacer()
				Button("Left") { onLeftButtonClicked() }
				Spacer()
			}
			VStack {
				Spacer()
				Button("Right") { onRightButtonClicked() }
				Spacer()
				Button("Top") { onTopButtonClicked() }
				Spacer()
				Button("Bottom") { onBottomButtonClicked() }
				Spacer()
			}
			
			Spacer()
		}
	}
}
