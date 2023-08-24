//
//  SandboxContentView.swift
//  L4B
//
//  Created by Colton McCasland on 8/21/23.
//

import SwiftUI
import SceneKit


struct SandboxContentView: NSViewRepresentable {
	@ObservedObject var rotationState: RotationState
	
	func makeNSView(context: Context) -> SCNView {
		let sceneView = SCNView()
		sceneView.backgroundColor = NSColor.white
		sceneView.scene = createScene()
		sceneView.allowsCameraControl = true
		
		// Add pan gesture recognizer
		let panGesture = NSPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
		sceneView.addGestureRecognizer(panGesture)
		
		// Add rotation gesture recognizer for two-finger twisting
		let rotationGesture = NSRotationGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleRotationGesture(_:)))
		sceneView.addGestureRecognizer(rotationGesture)


		return sceneView
	}
	
	func updateNSView(_ nsView: SCNView, context: Context) {
		for node in nsView.scene?.rootNode.childNodes ?? [] {
			if node.name == "gridNode" {
				node.eulerAngles = rotationState.rotation
			}
		}
	}
	
	func createScene() -> SCNScene {
		let scene = SCNScene()
		let gridNode = SCNNode()
		gridNode.name = "gridNode"
		scene.rootNode.addChildNode(gridNode)
		// Create a floor axis grid
		let gridSize: CGFloat = 1
		let gridLines = 10
		let halfSize = gridSize * CGFloat(gridLines) / 2.0
		
		for i in (-gridLines / 2) + 1..<gridLines / 2 {
			let horizontalLine = SCNNode(geometry: createLine(from: SCNVector3(-halfSize, 0, CGFloat(i) * gridSize),
																			  to: SCNVector3(halfSize, 0, CGFloat(i) * gridSize)))
			gridNode.addChildNode(horizontalLine) // Add to the parent grid node
			
			let verticalLine = SCNNode(geometry: createLine(from: SCNVector3(CGFloat(i) * gridSize, 0, -halfSize),
																			to: SCNVector3(CGFloat(i) * gridSize, 0, halfSize)))
			gridNode.addChildNode(verticalLine) // Add to the parent grid node
		}
		
		// Add camera
		let cameraNode = SCNNode()
		cameraNode.name = "cameraNode" // Assign a name here
		
		let camera = SCNCamera()
		camera.fieldOfView = 60 // Adjust the field of view to make sure the edges are visible
		
		// Position the camera slightly further away from the grid and adjust its angle
		let cameraPosition = SCNVector3(x: 0, y: 0, z: halfSize * 2.5) // Adjust the z value for a more zoomed-out view
		cameraNode.position = cameraPosition
		
		cameraNode.camera = camera
		scene.rootNode.addChildNode(cameraNode)
		
		return scene
	}

	
	
	func degreesToRadians(_ degrees: Int) -> CGFloat {
		return CGFloat(degrees) * .pi / 180
	}
	
	func createLine(from start: SCNVector3, to end: SCNVector3) -> SCNGeometry {
		let indices: [Int32] = [0, 1]
		let source = SCNGeometrySource(vertices: [start, end])
		let element = SCNGeometryElement(indices: indices, primitiveType: .line)
		let geometry = SCNGeometry(sources: [source], elements: [element])
		
		// Create a material with a black color
		let material = SCNMaterial()
		material.diffuse.contents = NSColor.black
		
		// Apply the material to the geometry
		geometry.materials = [material]
		
		return geometry
	}

	
	
	func makeCoordinator() -> Coordinator {
		Coordinator(rotationState: rotationState)
	}
	
	class Coordinator: NSObject {
		@ObservedObject var rotationState: RotationState
		
		init(rotationState: RotationState) {
			self.rotationState = rotationState
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
	}
}
