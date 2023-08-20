import SwiftUI
import SceneKit

struct SandboxView: View {
	var body: some View {
		ZStack {
			SandboxContentView()
			VStack {
				FrostedGlassMenu()
					.frame(height: 70)
				HStack {
					Spacer()
					CubeControllerView()
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
	func makeNSView(context: Context) -> SCNView {
		let sceneView = SCNView()
		sceneView.backgroundColor = NSColor.clear
		sceneView.scene = createScene()
		sceneView.allowsCameraControl = true
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
			
			let pinchScale = 1.0 - gestureRecognizer.magnification
			sceneView.pointOfView?.camera?.fieldOfView *= pinchScale
			
			gestureRecognizer.magnification = 0.0
		}
	}
}

struct CubeControllerView: NSViewRepresentable {
	func makeNSView(context: Context) -> SCNView {
		let sceneView = SCNView()
		sceneView.backgroundColor = NSColor.clear
		sceneView.scene = SCNScene()
		sceneView.allowsCameraControl = false
		
		let cube = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
		cube.firstMaterial?.diffuse.contents = NSColor.white
		cube.firstMaterial?.specular.contents = NSColor.gray
		
		let cubeNode = SCNNode(geometry: cube)
		sceneView.scene?.rootNode.addChildNode(cubeNode)
		
		addText("Top", to: cubeNode, at: SCNVector3(0, 1, 0), rotation: SCNVector4(1, 0, 0, -CGFloat.pi / 2))
		addText("Bottom", to: cubeNode, at: SCNVector3(0, -1, 0), rotation: SCNVector4(1, 0, 0, CGFloat.pi / 2))
//		addText("Left", to: cubeNode, at: SCNVector3(-1, 0, 0), rotation: SCNVector4(0, 1, 0, CGFloat.pi / 2))
//		addText("Right", to: cubeNode, at: SCNVector3(1, 0, 0), rotation: SCNVector4(0, 1, 0, -CGFloat.pi / 2))

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


