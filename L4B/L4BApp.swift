//
//  L4BApp.swift
//  L4B
//
//  Created by Colton McCasland on 8/19/23.
//

import SwiftUI

@main
struct L4BApp: App {
	let persistenceController = PersistenceController.shared
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.frame(minWidth: 700, minHeight: 700) // Set the minimum size here

				.environment(\.managedObjectContext, persistenceController.container.viewContext)
		}
	}
}
