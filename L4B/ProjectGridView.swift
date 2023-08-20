import SwiftUI
import CoreData
import AppKit

struct ProjectGridView: View {
	@Environment(\.managedObjectContext) private var viewContext
	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \Project.timestamp, ascending: true)],
		animation: .default)
	private var projects: FetchedResults<Project>
	
	@State private var isAddingProject = false
	
	var body: some View {
		NavigationView {
			GeometryReader { geometry in
				ScrollViewReader { scrollViewProxy in
					ScrollView(.horizontal) {
						LazyHGrid(rows: [GridItem(.adaptive(minimum: 250), spacing: 20)], spacing: 20) {
							ForEach(projects) { project in
								NavigationLink(destination: SandboxView()) {
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
									}
									.frame(width: 250, height: 250)
									.id(project) // Ensure each project has a unique identifier
								}
								.buttonStyle(PlainButtonStyle())
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
				// Add button to show the new project sheet
				Button(action: { isAddingProject.toggle() }) {
					Image(systemName: "plus")
				}
			}
			.sheet(isPresented: $isAddingProject) {
				ProjectView(isPresented: $isAddingProject) { title in
					addProject(title: title)
				}
			}
		}
	}

	
	private func addProject(title: String) {
		withAnimation {
			let newProject = Project(context: viewContext)
			newProject.title = title
			newProject.timestamp = Date()
			do {
				try viewContext.save()
			} catch {
				let nsError = error as NSError
				fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
			}
		}
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
	@Binding var isPresented: Bool
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
				onSave(newProjectTitle) // Pass the title to the onSave closure
				isPresented = false // Dismiss the sheet
			}
		}
		.padding()
	}
}
