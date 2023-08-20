//
//  CubeController.swift
//  L4B
//
//  Created by Colton McCasland on 8/20/23.
//

import SwiftUI
import SceneKit


struct CubeControllerView: NSViewRepresentable {
	func makeNSView(context: Context) -> SCNView {
		let sceneView = SCNView()
		sceneView.backgroundColor = NSColor.clear
		sceneView.scene = SCNScene()
		sceneView.allowsCameraControl = false
		
		let cube = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
		
		// Create a white material for the faces
		let faceMaterial = SCNMaterial()
		faceMaterial.diffuse.contents = NSColor.white
		
		// Create a gray material for the edges
		let edgeMaterial = SCNMaterial()
		edgeMaterial.diffuse.contents = NSColor.gray
		
		// Set the materials for each face
		cube.materials = [faceMaterial, faceMaterial, faceMaterial, faceMaterial, faceMaterial, faceMaterial]
		
		let cubeNode = SCNNode(geometry: cube)
		sceneView.scene?.rootNode.addChildNode(cubeNode)
		
		// Create the vertices for the edges
		let vertices: [SCNVector3] = [
			// Vertices for each corner
			SCNVector3(-1, 1, 1), SCNVector3(1, 1, 1),
			SCNVector3(-1, -1, 1), SCNVector3(1, -1, 1),
			SCNVector3(-1, 1, -1), SCNVector3(1, 1, -1),
			SCNVector3(-1, -1, -1), SCNVector3(1, -1, -1),
		]
		
		// Define indices for all the edges
		let edgeIndices: [UInt32] = [
			0, 1, 1, 3, 3, 2, 2, 0,  // Top edges
			4, 5, 5, 7, 7, 6, 6, 4,  // Bottom edges
			0, 4, 1, 5, 2, 6, 3, 7,  // Vertical edges
		]
		
		let edgeVertexSource = SCNGeometrySource(vertices: vertices)
		let edgeIndexElement = SCNGeometryElement(indices: edgeIndices, primitiveType: .line)
		
		// Create the edge geometry
		let edgeGeometry = SCNGeometry(sources: [edgeVertexSource], elements: [edgeIndexElement])
		edgeGeometry.firstMaterial = edgeMaterial
		
		let edgeNode = SCNNode(geometry: edgeGeometry)
		cubeNode.addChildNode(edgeNode)
		
		addText("Top", to: cubeNode, at: SCNVector3(0, 1, 0), rotation: SCNVector4(1, 0, 0, -CGFloat.pi / 2))
		addText("Bottom", to: cubeNode, at: SCNVector3(0, -1, 0), rotation: SCNVector4(1, 0, 0, CGFloat.pi / 2))
		// Add text for left and right here
		
		// Position the camera to view the cube
		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)
		sceneView.scene?.rootNode.addChildNode(cameraNode)
		
		// Add pan gesture recognizer
		let panGesture = NSPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePanGesture(_:)))
		sceneView.addGestureRecognizer(panGesture)
		
		return sceneView
	}




	
	func addText(_ text: String, to node: SCNNode, at position: SCNVector3, rotation: SCNVector4) {
		let textGeometry = SCNText(string: text, extrusionDepth: 0.1)
		textGeometry.font = NSFont.systemFont(ofSize: 1) // Adjust the font size if needed
		textGeometry.alignmentMode = CATextLayerAlignmentMode.center.rawValue // Center the text
		textGeometry.firstMaterial?.diffuse.contents = NSColor.black // Set text color for visibility
		let textNode = SCNNode(geometry: textGeometry)
		
		// Calculate the center of the text geometry
		let min = textGeometry.boundingBox.min
		let max = textGeometry.boundingBox.max
		let textCenter = SCNVector3((max.x - min.x) / 2 + min.x, (max.y - min.y) / 2 + min.y, (max.z - min.z) / 2 + min.z)
		
		// Position the text node at the center of the cube face
		textNode.pivot = SCNMatrix4MakeTranslation(textCenter.x, textCenter.y, textCenter.z)
		textNode.position = position
		textNode.rotation = rotation
		textNode.scale = SCNVector3(0.5, 0.5, 0.5) // Scale the text
		node.addChildNode(textNode)
	}
	
	
	func createMaterial(with text: String) -> SCNMaterial {
		let material = SCNMaterial()
		material.diffuse.contents = NSColor.white
		material.specular.contents = NSColor.gray
		
		let textGeometry = SCNText(string: text, extrusionDepth: 0.1)
		textGeometry.font = NSFont.systemFont(ofSize: 0.5)
		textGeometry.alignmentMode = CATextLayerAlignmentMode.center.rawValue
		let textNode = SCNNode(geometry: textGeometry)
		textNode.scale = SCNVector3(0.5, 0.5, 0.5)
		
		material.diffuse.contents = textNode
		
		return material
	}
	
	
	
	func updateNSView(_ nsView: SCNView, context: Context) {
		// Update view if needed
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator()
	}
	
	class Coordinator: NSObject {
		@objc func handlePanGesture(_ gestureRecognizer: NSPanGestureRecognizer) {
			guard let sceneView = gestureRecognizer.view as? SCNView else {
				return
			}
			
			let translation = gestureRecognizer.translation(in: sceneView)
			let xRotation = Float(-translation.y) * 0.01 // Reversed sign for up-down movement
			let yRotation = Float(translation.x) * 0.01 // Keep the sign for left-right movement
			
			sceneView.scene?.rootNode.childNodes.first?.eulerAngles.x += CGFloat(xRotation)
			sceneView.scene?.rootNode.childNodes.first?.eulerAngles.y += CGFloat(yRotation)
			
			gestureRecognizer.setTranslation(.zero, in: sceneView)
		}
	}
	
	
}
