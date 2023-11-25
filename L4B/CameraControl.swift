//
//  cameraState.swift
//  L4B
//
//  Created by Colton McCasland on 11/25/23.
//
import SceneKit
import SwiftUI

class CameraControl: ObservableObject {
	@Published var targetPosition: SCNVector3?
	@Published var targetOrientation: SCNQuaternion?
}
