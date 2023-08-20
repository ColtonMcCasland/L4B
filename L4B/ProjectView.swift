//
//  ProjectView.swift
//  L4B
//
//  Created by Colton McCasland on 8/19/23.
//

import SwiftUI

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
