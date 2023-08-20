import SwiftUI
import CoreData
import AppKit

struct ProjectGridView: View {
	@Environment(\.managedObjectContext) private var viewContext
	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Project.timestamp, ascending: true)],
		animation: .default)
	private var projects: FetchedResults<Project>
	
	@State private var isProjectViewPresented = false
	@State private var newProjectTitle = ""
	
	var body: some View {
		GeometryReader { geometry in
			ScrollViewReader { scrollViewProxy in
				ScrollView(.horizontal) {
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
							.frame(width: 250, height: 250)
							.id(project) // Ensure each project has a unique identifier
						}
					}
					.padding()
					.onChange(of: geometry.size) { _ in
						// Scroll to the first item when window size changes
						if let firstProject = projects.first {
							scrollViewProxy.scrollTo(firstProject)
						}
					}
				}
			}
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

struct WidthPreferenceKey: PreferenceKey {
	static var defaultValue: CGFloat = 0
	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
		value = max(value, nextValue())
	}
}


