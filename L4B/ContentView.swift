import SwiftUI
import CoreData

struct ContentView: View {
	@Environment(\.managedObjectContext) private var viewContext
	
	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Project.timestamp, ascending: true)],
		animation: .default)
	private var projects: FetchedResults<Project>
	
	@State private var isProjectViewPresented = false
	
	var body: some View {
		NavigationView {
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
				ProjectView(onSave: { title in
					addProject(title: title)
				})
			})
		}
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
