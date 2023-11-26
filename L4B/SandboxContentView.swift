import SwiftUI
import SceneKit

struct SandboxContentView: NSViewRepresentable {
	@ObservedObject var rotationState: RotationState
	@ObservedObject var cameraControl: CameraControl  // Make sure to pass this

	func makeNSView(context: Context) -> SCNView {
		let sceneView = SCNView()
		sceneView.backgroundColor = NSColor.white
		sceneView.scene = createGrid()
		sceneView.allowsCameraControl = true
		
		// Set up the tap gesture recognizer
		let tapGesture = NSClickGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTapGesture(_:)))
		sceneView.addGestureRecognizer(tapGesture)
		
		
		// Set the initial camera position for an isometric view
		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		let cameraDistance: CGFloat = 30 // Adjust the camera distance as needed
		
		// Set the camera orientation to look at the center of the scene
		cameraNode.position = SCNVector3(x: 0, y: 0, z: cameraDistance)
		cameraNode.eulerAngles = SCNVector3(x: 0, y:  0, z: 0)
		sceneView.pointOfView = cameraNode
		
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
		
		// Update camera based on CameraControl
		if let newPosition = cameraControl.targetPosition {
			nsView.pointOfView?.position = newPosition
		}
		if let newOrientation = cameraControl.targetOrientation {
			nsView.pointOfView?.orientation = newOrientation
		}
	}
	
	func createGrid() -> SCNScene {
		let scene = SCNScene()
		let gridNode = SCNNode()
		gridNode.name = "gridNode"
		scene.rootNode.addChildNode(gridNode)
		
		// Dynamic grid size based on camera position
		let gridQuadrentSize: CGFloat = 10 // Assume this is dynamically updated

		let gridSize: CGFloat = 1
		
		// Calculate the number of grid lines based on camera position
		let gridLines = Int(gridQuadrentSize / gridSize)
		
		// Create the grid
		for i in -gridLines...gridLines {
			for j in -gridLines...gridLines {
				let horizontalLine = SCNNode(geometry: createLine(from: SCNVector3(-gridSize * CGFloat(gridLines), 0, CGFloat(i) * gridSize),
																				  to: SCNVector3(gridSize * CGFloat(gridLines), 0, CGFloat(i) * gridSize)))
				gridNode.addChildNode(horizontalLine)
				
				let verticalLine = SCNNode(geometry: createLine(from: SCNVector3(CGFloat(j) * gridSize, 0, -gridSize * CGFloat(gridLines)),
																				to: SCNVector3(CGFloat(j) * gridSize, 0, gridSize * CGFloat(gridLines))))
				gridNode.addChildNode(verticalLine)
			}
		}
		
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
		Coordinator(rotationState: rotationState, cameraControl: cameraControl)
	}
	
}
