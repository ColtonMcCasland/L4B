import SwiftUI
import SceneKit

struct ContentView: View {
	var body: some View {
		SandboxView()
	}
}

struct SandboxView: NSViewRepresentable {
	func makeNSView(context: Context) -> SCNView {
		let sceneView = SCNView()
		
		// Set the background color to transparent
		sceneView.backgroundColor = NSColor.clear
		
		sceneView.scene = createScene()
		sceneView.allowsCameraControl = true
		
		// Add a pinch gesture recognizer using the coordinator
		let pinchGesture = NSMagnificationGestureRecognizer(target: context.coordinator,
																			 action: #selector(Coordinator.handlePinchGesture(_:)))
		sceneView.addGestureRecognizer(pinchGesture)
		
		return sceneView
	}
	
	func updateNSView(_ nsView: SCNView, context: Context) {
		// Update view if needed
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
			scene.rootNode.addChildNode(horizontalLine)
			
			let verticalLine = SCNNode(geometry: createLine(from: SCNVector3(CGFloat(i) * gridSize, 0, -halfSize),
																			to: SCNVector3(CGFloat(i) * gridSize, 0, halfSize)))
			scene.rootNode.addChildNode(verticalLine)
		}
		
		// Add camera
		let cameraNode = SCNNode()
		cameraNode.camera = SCNCamera()
		cameraNode.position = SCNVector3(x: 0, y: 15, z: 15)
		cameraNode.eulerAngles = SCNVector3(x: degreesToRadians(-45), y: 0, z: 0)
		scene.rootNode.addChildNode(cameraNode)
		
		return scene
	}
	
	func degreesToRadians(_ degrees: Int) -> CGFloat {
		return CGFloat(degrees) * .pi / 180
	}
	
	func createLine(from start: SCNVector3, to end: SCNVector3) -> SCNGeometry {
		let indices: [UInt32] = [0, 1]
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
			
			// Adjust the camera's field of view for zooming
			let pinchScale = 1.0 - gestureRecognizer.magnification
			sceneView.pointOfView?.camera?.fieldOfView *= pinchScale
			
			gestureRecognizer.magnification = 0.0
		}
	}
}

