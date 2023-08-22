//
//  CubeController.swift
//  L4B
//
//  Created by Colton McCasland on 8/20/23.
//

import SwiftUI
import SceneKit


struct CubeControllerView: NSViewRepresentable {
	@ObservedObject var rotationState: RotationState
	
	func makeNSView(context: Context) -> SCNView {
		let sceneView = SCNView()
		sceneView.backgroundColor = NSColor.clear
		sceneView.scene = SCNScene()
		sceneView.allowsCameraControl = false
		
		// Create the grid-like material for the cube
		let gridMaterial = SCNMaterial()
		gridMaterial.diffuse.contents = NSColor.white
		gridMaterial.isDoubleSided = true
		gridMaterial.diffuse.wrapS = .repeat
		gridMaterial.diffuse.wrapT = .repeat
		gridMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(3.0, 3.0, 1.0) // Adjust the scale
		
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
		cubeNode.name = "cubeNode"
		sceneView.scene?.rootNode.addChildNode(cubeNode)
		
		// Set initial rotation of cube based on rotationState
		cubeNode.eulerAngles = rotationState.rotation
		
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
		
		// Add labels to all sides of the cube
		addText("Front", to: cubeNode, at: SCNVector3(0, 1.1, 0), rotation: SCNVector4(1, 0, 0, -1.57079632679489661923132169163975144))
		addText("Back", to: cubeNode, at: SCNVector3(0, -1.1, 0), rotation: SCNVector4(1, 0, 0, 1.57079632679489661923132169163975144))
		addText("Bottom", to: cubeNode, at: SCNVector3(0, 0, 1.1), rotation: SCNVector4(1, 0, 0, 0))
		addText("Top", to: cubeNode, at: SCNVector3(0, 0, -1.1), rotation: SCNVector4(1, 0, 0, 3.14159265358979323846264338327950288))
		addText("Left", to: cubeNode, at: SCNVector3(-1, 0, 0), rotation: SCNVector4(0, 1, 0, -Float.pi / 2))
		addText("Right", to: cubeNode, at: SCNVector3(1, 0, 0), rotation: SCNVector4(0, 1, 0, Float.pi / 2))
		
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
		let textGeometry = SCNText(string: text, extrusionDepth: 0.05) // Adjust extrusionDepth as needed
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
		if let cubeNode = nsView.scene?.rootNode.childNode(withName: "cubeNode", recursively: false) {
			// Apply the grid's rotation to the cube
			cubeNode.eulerAngles = rotationState.rotation
			
			// Apply additional rotation to align the grid with the bottom face of the cube
			// (You may need to adjust this rotation based on your specific scene setup)
			cubeNode.eulerAngles.x += CGFloat.pi / 2
		}
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
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(rotationState: rotationState)
	}

}

