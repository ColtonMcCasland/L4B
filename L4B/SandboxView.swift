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
			SandboxContentView(rotationState: rotationState) // Pass both states here
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
	
	func makeNSView(context: Context) -> SCNView {
		let sceneView = SCNView()
		sceneView.backgroundColor = NSColor.clear
		sceneView.scene = createScene()
		sceneView.allowsCameraControl = true
		return sceneView
	}
	
	func updateNSView(_ nsView: SCNView, context: Context) {
		for node in nsView.scene?.rootNode.childNodes ?? [] {
			if node.name == "gridNode" {
				node.eulerAngles = rotationState.rotation
				print("Grid Rotation: \(rotationState.rotation)")
			} else if node.name == "cubeNode" {
				node.eulerAngles = rotationState.rotation
				print("Cube Rotation: \(rotationState.rotation)")
			}
		}
	}





	
	func createScene() -> SCNScene {
		let scene = SCNScene()
		
		// Create a floor axis grid
		let gridSize: CGFloat = 1
		let gridLines = 10
		let halfSize = gridSize * CGFloat(gridLines) / 2.0
		
		for i in (-gridLines / 2) + 1..<gridLines / 2 {
			let horizontalLine = SCNNode(geometry: createLine(from: SCNVector3(-halfSize, 0, CGFloat(i) * gridSize),
																			  to: SCNVector3(halfSize, 0, CGFloat(i) * gridSize)))
			horizontalLine.name = "gridNode"
			scene.rootNode.addChildNode(horizontalLine)
			
			let verticalLine = SCNNode(geometry: createLine(from: SCNVector3(CGFloat(i) * gridSize, 0, -halfSize),
																			to: SCNVector3(CGFloat(i) * gridSize, 0, halfSize)))
			verticalLine.name = "gridNode"
			scene.rootNode.addChildNode(verticalLine)
		}


		// Add camera
		let cameraNode = SCNNode()
		cameraNode.name = "cameraNode" // Assign a name here
		
		let camera = SCNCamera()
		camera.fieldOfView = 60 // Adjust the field of view to make sure the edges are visible
		
		// Position the camera slightly further away from the grid and adjust its angle
		
		
														// this tilts the camera down towards the grid,
														// halfSize / 2
		let cameraPosition = SCNVector3(x: 0, y: 0, z: halfSize * 2.5) // Adjust the z value for a more zoomed-out view
		cameraNode.position = cameraPosition
		
//		let tiltAngleX: Float = -Float.pi / 8 // Adjust the angle for a downward tilt
//		let tiltAngleZ: Float = 0 // Keep the Z-axis rotation angle 0 for your requirement
//
//		cameraNode.eulerAngles = SCNVector3(tiltAngleX, 0, tiltAngleZ) // Apply the rotation to tilt the camera downward
		
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
