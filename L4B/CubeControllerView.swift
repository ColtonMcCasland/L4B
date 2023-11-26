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
	@ObservedObject var cameraControl: CameraControl
	
	func updateNSView(_ nsView: SCNView, context: Context) {
		if let scene = nsView.scene {
			let cubeNode = scene.rootNode.childNode(withName: "cubeNode", recursively: false)
			let gridNode = scene.rootNode.childNode(withName: "gridNode", recursively: false)
			
			// Apply the rotation to both the cube and the grid
			let rotation = rotationState.rotation
			cubeNode?.eulerAngles = rotation
			gridNode?.eulerAngles = rotation
		}
	}
	
	func makeNSView(context: Context) -> SCNView {
	
		
		let sceneView = SCNView()
		sceneView.backgroundColor = NSColor.lightGray
		sceneView.scene = SCNScene()
		sceneView.allowsCameraControl = false
		
		
		// Create the grid-like material for the cube
		let gridMaterial = SCNMaterial()
		gridMaterial.isDoubleSided = true
		gridMaterial.diffuse.contents = NSColor.clear // Set the background color to clear for added transparency
		
		// Apply frosted glass appearance with rounded corners
		gridMaterial.transparencyMode = .dualLayer // Use dualLayer transparency mode
		gridMaterial.diffuse.intensity = 0.7 // Adjust the intensity for the frosted effect
		gridMaterial.specular.contents = NSColor.clear // Disable specular reflections
		
		// Apply rounded corners to the SCNView
		sceneView.layer?.cornerRadius = 20
		sceneView.layer?.masksToBounds = true

		
		// Create the cube node
		let cube = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
		let cubeNode = SCNNode(geometry: cube)
		
		
		// Create a material for the lines of the grid
		let lineMaterial = SCNMaterial()
		lineMaterial.diffuse.contents = NSColor.black // Lines color
		
		// Calculate the number of lines based on the desired grid size
		let gridSize = 3
		let lineSpacing = Float(2) / Float(gridSize) // Assuming cube width is 2
		
		// Generate grid lines for each face of the cube
		for i in 0...gridSize {
			let position = Float(i) * lineSpacing - 1 // Position of the line
			
			// Horizontal lines along Z
			for z in [-1, 1].map(Float.init) {
				let start = SCNVector3(-1, position, z)
				let end = SCNVector3(1, position, z)
				let lineNode = lineBetweenPoints(start: start, end: end, material: lineMaterial)
				cubeNode.addChildNode(lineNode)
			}
			
			// Vertical lines along Z
			for z in [-1, 1].map(Float.init) {
				let start = SCNVector3(position, -1, z)
				let end = SCNVector3(position, 1, z)
				let lineNode = lineBetweenPoints(start: start, end: end, material: lineMaterial)
				cubeNode.addChildNode(lineNode)
			}
			
			// Horizontal lines along X
			for x in [-1, 1].map(Float.init) {
				let start = SCNVector3(x, position, -1)
				let end = SCNVector3(x, position, 1)
				let lineNode = lineBetweenPoints(start: start, end: end, material: lineMaterial)
				cubeNode.addChildNode(lineNode)
			}
			
			// Vertical lines along X
			for x in [-1, 1].map(Float.init) {
				let start = SCNVector3(x, -1, position)
				let end = SCNVector3(x, 1, position)
				let lineNode = lineBetweenPoints(start: start, end: end, material: lineMaterial)
				cubeNode.addChildNode(lineNode)
			}
			
			// Horizontal and Vertical lines for Front and Back faces (along YZ plane)
			for y in [-1, 1].map(Float.init) {
				// Horizontal lines on Front and Back
				let frontStart = SCNVector3(-1, y, position)
				let frontEnd = SCNVector3(1, y, position)
				let frontLineNode = lineBetweenPoints(start: frontStart, end: frontEnd, material: lineMaterial)
				cubeNode.addChildNode(frontLineNode)
				
				// Vertical lines on Front and Back
				let backStart = SCNVector3(position, y, -1)
				let backEnd = SCNVector3(position, y, 1)
				let backLineNode = lineBetweenPoints(start: backStart, end: backEnd, material: lineMaterial)
				cubeNode.addChildNode(backLineNode)
			}
		}
		
		// Create a gray material for the edges
		let edgeMaterial = SCNMaterial()
		edgeMaterial.diffuse.contents = NSColor.gray

		
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
		addText("Top", to: cubeNode, at: SCNVector3(0, 1.1, 0), rotation: SCNVector4(1, 0, 0, -1.57079632679489661923132169163975144))
		addText("Bottom", to: cubeNode, at: SCNVector3(0, -1.1, 0), rotation: SCNVector4(1, 0, 0, 1.57079632679489661923132169163975144))
		addText("Front", to: cubeNode, at: SCNVector3(0, 0, 1.1), rotation: SCNVector4(1, 0, 0, 0))
		addText("Back", to: cubeNode, at: SCNVector3(0, 0, -1.1), rotation: SCNVector4(1, 0, 0, 3.14159265358979323846264338327950288))
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
		
		// Add tap gesture recognizer
		let tapGesture = NSClickGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTapGesture(_:)))
		sceneView.addGestureRecognizer(tapGesture)

		
		return sceneView
	}
	
	
	// Function to create a line between two points
	func lineBetweenPoints(start: SCNVector3, end: SCNVector3, material: SCNMaterial) -> SCNNode {
		let indices: [Int32] = [0, 1]
		let source = SCNGeometrySource(vertices: [start, end])
		let element = SCNGeometryElement(indices: indices, primitiveType: .line)
		let lineGeometry = SCNGeometry(sources: [source], elements: [element])
		lineGeometry.materials = [material]
		return SCNNode(geometry: lineGeometry)
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
	
	
	
	class Coordinator: NSObject {
		@ObservedObject var rotationState: RotationState
		var cameraControl: CameraControl  // Add this line

		init(rotationState: RotationState, cameraControl: CameraControl) {
			self.rotationState = rotationState
			self.cameraControl = cameraControl
		}
				
		enum CubeFace {
			case front
			case back
			case left
			case right
			case top
			case bottom
			case test
		}
		
		@objc func handleTapGesture(_ gestureRecognizer: NSClickGestureRecognizer) {
			guard let sceneView = gestureRecognizer.view as? SCNView else { return }
			let location = gestureRecognizer.location(in: sceneView)
			let hitResults = sceneView.hitTest(location, options: [:])
			
			if let hitResult = hitResults.first, hitResult.node.name == "cubeNode" {
				let tappedFace = determineTappedFace(from: hitResult)
				adjustCamera(to: tappedFace)
			}
		}
		
		private func adjustCamera(to face: CubeFace) {
			switch face {
				case .front:
					adjustCameraToFrontFace()
				case .back:
					adjustCameraToBackFace()
				case .left:
					adjustCameraToLeftFace()
				case .right:
					adjustCameraToRightFace()
				case .top:
					adjustCameraToTopFace()
				case .bottom:
					adjustCameraToBottomFace()
				default:
					break
			}
		}
		
		private func adjustCameraToFrontFace() {
			DispatchQueue.main.async {
				self.cameraControl.targetPosition = SCNVector3(0, 0, 30)
				self.rotationState.rotation = SCNVector3(0, 0, 0)
			}
		}
		
		private func adjustCameraToTopFace() {
			DispatchQueue.main.async {
				self.cameraControl.targetPosition = SCNVector3(0, 0, 30) // Above the cube
				self.rotationState.rotation = SCNVector3(CGFloat.pi / 2, 0, 0) // Looking down
			}
		}

		private func adjustCameraToBackFace() {
			DispatchQueue.main.async {
				self.cameraControl.targetPosition = SCNVector3(0, 0, 30) // Opposite the front
				self.rotationState.rotation = SCNVector3(0, CGFloat.pi, 0) // Rotated 180 degrees around Y axis
			}
		}

		private func adjustCameraToBottomFace() {
			DispatchQueue.main.async {
				self.cameraControl.targetPosition = SCNVector3(0, 0, 30) // Below the cube
				self.rotationState.rotation = SCNVector3(-CGFloat.pi / 2, 0, 0) // Looking up
			}
		}

		private func adjustCameraToLeftFace() {
			DispatchQueue.main.async {
				self.cameraControl.targetPosition = SCNVector3(0, 0, 30) // Left side of the cube
				self.rotationState.rotation = SCNVector3(0, CGFloat.pi / 2, 0) // Rotated 90 degrees to the left
			}
		}

		private func adjustCameraToRightFace() {
			DispatchQueue.main.async {
				self.cameraControl.targetPosition = SCNVector3(0, 0, 30) // Right side of the cube
				self.rotationState.rotation = SCNVector3(0, -CGFloat.pi / 2, 0) // Rotated 90 degrees to the right
			}
		}




		
		func determineTappedFace(from hitResult: SCNHitTestResult) -> CubeFace {
			let hitNormal = hitResult.localNormal
			
			// Debugging: Print hit normal
			// print("Hit Normal: \(hitNormal)")
			
			// Determine the face based on the normal vector of the hit result
			if hitNormal.x > 0.9 {
				return .right
			} else if hitNormal.x < -0.9 {
				return .left
			} else if hitNormal.y > 0.9 {
				return .top
			} else if hitNormal.y < -0.9 {
				return .bottom
			} else if hitNormal.z > 0.9 {
				return .front
			} else if hitNormal.z < -0.9 {
				return .back
			} else {
				// Default case if the face cannot be determined
				return .front
			}
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
		Coordinator(rotationState: rotationState, cameraControl: cameraControl)
	}
	
}

