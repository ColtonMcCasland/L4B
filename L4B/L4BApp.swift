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
			  ProjectGridView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
