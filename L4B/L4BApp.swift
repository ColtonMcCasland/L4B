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
			// Create the required objects
			let rotationState = RotationState()
			let cameraControl = CameraControl()

			
			SandboxView(rotationState: rotationState, cameraControl: cameraControl)
				.frame(minWidth: 700, minHeight: 700)
				.environment(\.managedObjectContext, persistenceController.container.viewContext)
		}
	}
}

