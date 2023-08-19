import SwiftUI
import CoreData
import AppKit

struct ContentView: View {
	@Environment(\.managedObjectContext) private var viewContext
	
	var body: some View {
		NavigationView {
			ProjectGridView()
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
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
			LazyHGrid(rows: [GridItem(.adaptive(minimum: 250), spacing: 20)], spacing: 20) {
				ForEach(projects) { project in
					ZStack(alignment: .topTrailing) {
						RoundedRectangle(cornerRadius: 10)
							.frame(width: 250, height: 250)
							.foregroundColor(Color(.darkGray))
							.overlay(
								VStack {
									Text(project.title ?? "")
										.font(.headline)
										.foregroundColor(.white)
								}
							)
						
						Button(action: {
							showDeleteConfirmation(for: project)
						}) {
							Image(systemName: "xmark.circle.fill")
								.resizable()
								.frame(width: 24, height: 24)
								.foregroundColor(.white)
						}
						.padding(8)
						.buttonStyle(BorderlessButtonStyle())
						.onHover { isHovered in
							// Adjust the appearance when hovering
							// (Optional: Change the icon's color or size)
						}
					}
					.gesture(
						LongPressGesture(minimumDuration: 1.0)
							.onEnded { _ in
								showDeleteConfirmation(for: project)
							}
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
	
	private func showDeleteConfirmation(for project: Project) {
		let alert = NSAlert()
		alert.messageText = "Delete Project"
		alert.informativeText = "Are you sure you want to delete this project?"
		alert.addButton(withTitle: "Cancel")
		alert.addButton(withTitle: "Delete")
		
		let response = alert.runModal()
		if response == .alertSecondButtonReturn {
			deleteProject(project)
		}
	}
	
	private func addProject(title: String) {
		withAnimation {
			let newProject = Project(context: viewContext)
			newProject.timestamp = Date()
			newProject.title = title
			
			do {
				try viewContext.save()
				newProjectTitle = "" // Clear the text input
				isProjectViewPresented = false // Close the sheet
			} catch {
				let nsError = error as NSError
				fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
			}
		}
	}
	
	private func deleteProject(_ project: Project) {
		withAnimation {
			viewContext.delete(project)
			
			do {
				try viewContext.save()
			} catch {
				let nsError = error as NSError
				fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
			}
		}
	}
}

struct ProjectView: View {
	var onSave: (String) -> Void
	@State private var newProjectTitle = ""
	
	var body: some View {
		VStack {
			Text("Create New Project")
				.font(.headline)
				.padding(.bottom, 10)
			
			TextField("Project Title", text: $newProjectTitle)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.padding(.bottom, 20)
			
			Button("Save") {
				onSave(newProjectTitle)
			}
		}
		.padding()
	}
}
