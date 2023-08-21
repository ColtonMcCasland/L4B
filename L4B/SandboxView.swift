import SwiftUI
import SceneKit


class RotationState: ObservableObject {
	@Published var rotation: SCNVector3 = SCNVector3Zero {
		didSet {
			print("Rotation updated: \(rotation)")
		}
	}
}

class PositionState: ObservableObject {
	@Published var position: SCNVector3 = SCNVector3Zero {
		didSet {
			print("Position updated: \(position)")
		}
	}
}


struct SandboxView: View {
	@ObservedObject var rotationState = RotationState()
	@ObservedObject var positionState = PositionState() // Add this line
	

	var body: some View {
		ZStack {
			SandboxContentView(rotationState: rotationState, positionState: positionState) // Pass both states here
			VStack {
				FrostedGlassMenu()
					.frame(height: 70)
				HStack {
					Spacer()
					CubeControllerView(rotationState: rotationState  ,positionState: positionState)
					.frame(width: 100, height: 100)
						.padding(.top, 10)
						.padding(.trailing, 10)
				}
				Spacer()
			}
		}
	}
}

struct SandboxContentView: NSViewRepresentable {
	@ObservedObject var rotationState: RotationState
	@ObservedObject var positionState: PositionState // Add this line
	
	func makeNSView(context: Context) -> SCNView {
		let sceneView = SCNView()
		sceneView.backgroundColor = NSColor.clear
		sceneView.scene = createScene()
		sceneView.allowsCameraControl = true
		return sceneView
	}
	
	func updateNSView(_ nsView: SCNView, context: Context) {
		// Update the rotation of the grid nodes
		for node in nsView.scene?.rootNode.childNodes ?? [] {
			if node.name == "gridNode" {
				node.eulerAngles = rotationState.rotation
			}
		}
	}




	
	func createScene() -> SCNScene {
		let scene = SCNScene()
		
		// Create a floor axis grid
		let gridSize: CGFloat = 1
		let gridLines = 10
		let halfSize = gridSize * CGFloat(gridLines) / 2.0
		
		// Create lines extending from the center in all directions except for top and left
		for i in (-gridLines / 2) + 1..<gridLines / 2 {
			let horizontalLine = SCNNode(geometry: createLine(from: SCNVector3(-halfSize, 0, CGFloat(i) * gridSize),
																			  to: SCNVector3(halfSize, 0, CGFloat(i) * gridSize)))
			horizontalLine.name = "gridNode" // Add this line
			scene.rootNode.addChildNode(horizontalLine)
			
			let verticalLine = SCNNode(geometry: createLine(from: SCNVector3(CGFloat(i) * gridSize, 0, -halfSize),
																			to: SCNVector3(CGFloat(i) * gridSize, 0, halfSize)))
			verticalLine.name = "gridNode" // Add this line
			scene.rootNode.addChildNode(verticalLine)
		}

		// Add camera
		let cameraNode = SCNNode()
		cameraNode.name = "cameraNode" // Assign a name here
		
		let camera = SCNCamera()
		camera.fieldOfView = 60 // Adjust the field of view to make sure the edges are visible
		
		// Position the camera slightly further away from the grid and adjust its angle
		let cameraPosition = SCNVector3(x: 0, y: halfSize / 2, z: halfSize * 2.5) // Adjust the z value for a more zoomed-out view
		cameraNode.position = cameraPosition
		
		let tiltAngleX: Float = -Float.pi / 8 // Adjust the angle for a downward tilt
		let tiltAngleZ: Float = 0 // Keep the Z-axis rotation angle 0 for your requirement
		
		cameraNode.eulerAngles = SCNVector3(tiltAngleX, 0, tiltAngleZ) // Apply the rotation to tilt the camera downward
		
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
		return SCNGeometry(sources: [source], elements: [element])
	}

	
	func makeCoordinator() -> Coordinator {
		Coordinator()
	}
	
	class Coordinator: NSObject {
		@objc func handlePinchGesture(_ gestureRecognizer: NSMagnificationGestureRecognizer) {
			guard let sceneView = gestureRecognizer.view as? SCNView else {
				return
			}
			
			let pinchScale = 1.0 - gestureRecognizer.magnification
			sceneView.pointOfView?.camera?.fieldOfView *= pinchScale
			
			gestureRecognizer.magnification = 0.0
		}
	}
}



struct FrostedGlassMenu: NSViewRepresentable {
	func makeNSView(context: Context) -> NSVisualEffectView {
		let view = NSVisualEffectView()
		view.blendingMode = .withinWindow
		view.material = .underWindowBackground
		view.state = .active
		view.wantsLayer = true
		view.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.7).cgColor // Slightly transparent
		
		// Apply corner radius only to the top corners
		view.layer?.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		view.layer?.cornerRadius = 20 // Adjust the radius as needed
		
		return view
	}
	
	func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
		// Update view if needed
	}
}


struct CubeControllerView: NSViewRepresentable {
	@ObservedObject var rotationState: RotationState
	@ObservedObject var positionState: PositionState // Add this line
	
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
		cubeNode.name = "cubeNode"
		cubeNode.eulerAngles = SCNVector3(0, 0, 0) // Adjust the initial rotation here if needed
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
		nsView.scene?.rootNode.childNode(withName: "cubeNode", recursively: false)?.eulerAngles = rotationState.rotation
	}

	
	class Coordinator: NSObject {
		@ObservedObject var rotationState: RotationState
		
		init(rotationState: RotationState) {
			self.rotationState = rotationState
		}
		
		@objc func handlePanGesture(_ gestureRecognizer: NSPanGestureRecognizer) {
			guard let sceneView = gestureRecognizer.view as? SCNView else { return }
			
			let translation = gestureRecognizer.translation(in: sceneView)
			let xRotation = Float(-translation.y) * 0.01
			let yRotation = Float(translation.x) * 0.01
			
			rotationState.rotation.x += CGFloat(xRotation)
			rotationState.rotation.y += CGFloat(yRotation)
			
			// Remove the code that updates the cube's rotation here
			
			gestureRecognizer.setTranslation(.zero, in: sceneView)
		}
	}

	
	func makeCoordinator() -> Coordinator {
		Coordinator(rotationState: rotationState)
	}
}

