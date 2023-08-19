import SwiftUI

struct VisualEffectView: View {
	var effect: NSVisualEffectView.Material
	
	var body: some View {
		VisualEffectViewRepresentable(effect: effect)
			.frame(width: 100, height: 100)
			.cornerRadius(10)
			.overlay(
				Text("Add")
					.font(.headline)
					.foregroundColor(Color(.lightGray))
			)
	}
}

struct VisualEffectViewRepresentable: NSViewRepresentable {
	typealias NSViewType = NSVisualEffectView
	
	var effect: NSVisualEffectView.Material
	
	func makeNSView(context: Context) -> NSVisualEffectView {
		let view = NSVisualEffectView()
		view.material = effect
		return view
	}
	
	func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
		nsView.material = effect
	}
}

struct ProjectGridView: View {
	@State private var items: [String] = []
	@State private var isCreateSheetPresented = false
	@State private var newProjectTitle = ""
	@State private var newProjectType = ""
	
	var body: some View {
		let columns = [
			GridItem(.flexible()),
			GridItem(.flexible())
			// Add more GridItems for more columns
		]
		
		ScrollView {
			LazyVGrid(columns: columns, spacing: 20) {
				ForEach(items, id: \.self) { item in
					RoundedRectangle(cornerRadius: 10)
						.frame(width: 250, height: 250)
						.foregroundColor(Color(.darkGray))
						.overlay(
							Text(item)
								.font(.headline)
								.foregroundColor(.white)
						)
				}
			}
			.padding()
		}
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				HStack {
					Button("Import") {
						// Add your import logic here
					}
					.keyboardShortcut("i", modifiers: .command)
					
					Button("Export") {
						// Add your export logic here
					}
					.keyboardShortcut("e", modifiers: .command)
					
					Button("Create") {
						isCreateSheetPresented.toggle()
					}
					.keyboardShortcut("n", modifiers: .command)
				}
			}
		}
		.sheet(isPresented: $isCreateSheetPresented, content: {
			CreateProjectSheet(
				isPresented: $isCreateSheetPresented,
				newProjectTitle: $newProjectTitle,
				newProjectType: $newProjectType,
				onSave: createNewProject
			)
		})
	}
	
	func createNewProject() {
		let timestamp = "\(Date().timeIntervalSince1970)"
		let newProject = "\(newProjectTitle) - \(newProjectType)"
		items.append(newProject)
		newProjectTitle = ""
		newProjectType = ""
	}
}

struct CreateProjectSheet: View {
	@Binding var isPresented: Bool
	@Binding var newProjectTitle: String
	@Binding var newProjectType: String
	var onSave: () -> Void
	
	var body: some View {
		VStack {
			Text("Create New Project")
				.font(.headline)
				.padding(.bottom, 10)
			
			TextField("Project Title", text: $newProjectTitle)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.padding(.bottom, 10)
			
			TextField("Project Type", text: $newProjectType)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.padding(.bottom, 20)
			
			Button("Save") {
				onSave()
				isPresented.toggle()
			}
		}
		.padding()
	}
}
