//
//  SCNodeHolder.swift
//  ex-1-tracking
//
//  Created by Daniel Barbosa Maranhão on 06/09/18.
//  Copyright © 2018 Daniel Barbosa Maranhão. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

struct MCHolder {
    var cardNode: SCNNode
    var imageNode: SCNNode
    var anchor: ARImageAnchor
    var detectionDate: Date
}
