//
//  Coordinator.swift
//  L4B
//
//  Created by Colton McCasland on 11/26/23.
//

import Foundation
import SwiftUI
import SceneKit



class Coordinator: NSObject {
	@ObservedObject var rotationState: RotationState
	@ObservedObject var cameraControl: CameraControl
	
	init(rotationState: RotationState, cameraControl: CameraControl) {
		self.rotationState = rotationState
		self.cameraControl = cameraControl
		super.init()
	}
	
	@objc func handlePanGesture(_ gestureRecognizer: NSPanGestureRecognizer) {
		guard let sceneView = gestureRecognizer.view as? SCNView else { return }
		
		let translation = gestureRecognizer.translation(in: sceneView)
		let xRotation = Float(-translation.y) * 0.01
		let yRotation = Float(translation.x) * 0.01
		
		rotationState.rotation.x += CGFloat(xRotation)
		rotationState.rotation.y += CGFloat(yRotation)
		
		gestureRecognizer.setTranslation(.zero, in: sceneView)
	}
	
	@objc func handleRotationGesture(_ gestureRecognizer: NSRotationGestureRecognizer) {
		guard let sceneView = gestureRecognizer.view as? SCNView else { return }
		
		// Get the rotation angle from the gesture in radians
		let twistAngle = CGFloat(gestureRecognizer.rotation)
		
		// Update the shared rotation state to synchronize the cube and grid
		rotationState.rotation.y += twistAngle
		
		// Reset the rotation for continuous twisting
		gestureRecognizer.rotation = 0
	}
	
	@objc func handleTapGesture(_ gestureRecognizer: NSClickGestureRecognizer) {
		guard let sceneView = gestureRecognizer.view as? SCNView else { return }
		
		print("tap")
		
		let location = gestureRecognizer.location(in: sceneView)
		let hitResults = sceneView.hitTest(location, options: [:])
		
		if let firstHit = hitResults.first {
			let tappedNode = firstHit.node
			if tappedNode.name == "cubeFace" {
				// Calculate the new camera position based on the tapped cube face
				let newPosition = tappedNode.worldPosition
				print("Tapped cube face at \(newPosition)")
				cameraControl.targetPosition = newPosition
			}
		}
	}
	
	
	}

