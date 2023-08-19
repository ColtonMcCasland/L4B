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
	@Environment(\.managedObjectContext) private var viewContext
	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Project.timestamp, ascending: true)],
		animation: .default)
	private var projects: FetchedResults<Project>
	
	@State private var isProjectViewPresented = false
	@State private var newProjectTitle = ""
	
	var body: some View {
		ScrollView {
			LazyVGrid(columns: [
				GridItem(.flexible()),
				GridItem(.flexible())
			], spacing: 20) {
				ForEach(projects) { project in
					RoundedRectangle(cornerRadius: 10)
						.frame(width: 250, height: 250)
						.foregroundColor(Color(.darkGray))
						.overlay(
							Text(project.title ?? "")
								.font(.headline)
								.foregroundColor(.white)
						)
				}
			}
			.padding()
		}
		.navigationTitle("Projects")
		.toolbar {
			ToolbarItem {
				Button(action: {
					isProjectViewPresented.toggle()
				}) {
					Label("Create Project", systemImage: "plus")
				}
			}
		}
		.sheet(isPresented: $isProjectViewPresented, content: {
			ProjectView(onSave: addProject)
		})
	}
	
	private func addProject(title: String) {
		withAnimation {
			let newProject = Project(context: viewContext)
			newProject.timestamp = Date()
			newProject.title = title
			
			do {
				try viewContext.save()
			} catch {
				let nsError = error as NSError
				fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
			}
		}
	}
}

