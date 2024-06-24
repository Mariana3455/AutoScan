//
//  Utilities.swift
//  CarVision
//
//  Created by Ira Nazar on 2024-06-23.
//

import Foundation
import SceneKit

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
    
}
extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}
