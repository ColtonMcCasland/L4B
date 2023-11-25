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
				print(tappedFace)
				animateCamera(to: tappedFace, in: sceneView)
			}
		}
		
		func animateCamera(to face: CubeFace, in sceneView: SCNView) {
			guard let cameraNode = sceneView.scene?.rootNode.childNode(withName: "cameraNode", recursively: true) else { return }
			
			print(face)
			
			let newPosition: SCNVector3
			let newOrientation: SCNQuaternion
			let distance: Float = 5 // Distance from the cube, adjust as needed
			
			// Define new camera position and orientation based on the tapped face
			switch face {
				case .front:
					newPosition = SCNVector3(0, 0, distance)
					newOrientation = SCNQuaternion(x: 0, y: 0, z: 0, w: 1) // Facing front
				case .back:
					newPosition = SCNVector3(0, 0, -distance)
					newOrientation = SCNQuaternion(x: 0, y: 1, z: 0, w: -1) // Facing back
				case .left:
					newPosition = SCNVector3(-distance, 0, 0)
					newOrientation = SCNQuaternion(x: 0, y: 1, z: 0, w: CGFloat(Float.pi) / 2) // Facing left
				case .right:
					newPosition = SCNVector3(distance, 0, 0)
					newOrientation = SCNQuaternion(x: 0, y: 1, z: 0, w: CGFloat(-Float.pi) / 2) // Facing right
				case .top:
					newPosition = SCNVector3(0, distance, 0)
					newOrientation = SCNQuaternion(x: 1, y: 0, z: 0, w: -CGFloat(Float.pi) / 2) // Facing top
				case .bottom:
					newPosition = SCNVector3(0, -distance, 0)
					newOrientation = SCNQuaternion(x: 1, y: 0, z: 0, w: CGFloat(Float.pi) / 2) // Facing bottom
				default:
					return // If the face is not recognized, do not change the camera
			}
			
			// Update the shared CameraControl object
			DispatchQueue.main.async {
				self.cameraControl.targetPosition = newPosition
				self.cameraControl.targetOrientation = newOrientation
			}
			
			// Animate the camera movement
			SCNTransaction.begin()
			SCNTransaction.animationDuration = 1.0 // Adjust the duration as needed
			
			cameraNode.position = newPosition
			cameraNode.orientation = newOrientation
			
			SCNTransaction.commit()
		}
		
		func determineTappedFace(from hitResult: SCNHitTestResult) -> CubeFace {
			let hitNormal = hitResult.localNormal
			
			// Debugging: Print hit normal
			print("Hit Normal: \(hitNormal)")
			
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

