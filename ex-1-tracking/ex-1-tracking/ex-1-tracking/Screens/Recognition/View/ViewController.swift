//
//  ViewController.swift
//  ex-1-tracking
//
//  Created by Daniel Barbosa Maranhão on 04/09/18.
//  Copyright © 2018 Daniel Barbosa Maranhão. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!

    fileprivate var planeNode: SCNNode?
    fileprivate var imageNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.prepareReferenceImagesDetection()
    }
    
    fileprivate func prepareReferenceImagesDetection() {
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            return
        }
        
        let trackingConfiguration: ARWorldTrackingConfiguration = ARWorldTrackingConfiguration()
        trackingConfiguration.detectionImages = referenceImages
        
        self.sceneView.session.run(trackingConfiguration)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else {
            return
        }
        
        guard let planeScene = SCNScene(named: "Scenes.scnassets/plane.scn") else {
            return
        }
        
        guard let planeNode = planeScene.rootNode.childNode(withName: "plane", recursively: true) else {
            return
        }
        
        let (minSize, maxSize) = planeNode.boundingBox
        let size = SCNVector3Make(maxSize.x - minSize.x, maxSize.y - minSize.y, maxSize.z - minSize.z)
        
        let widthRatio = Float(imageAnchor.referenceImage.physicalSize.width)/size.x
        let heightRatio = Float(imageAnchor.referenceImage.physicalSize.height)/size.z
        
        let finalRatio = min(widthRatio, heightRatio)
        
        planeNode.transform = SCNMatrix4(imageAnchor.transform)
        
        let appearanceAction = SCNAction.scale(to: CGFloat(finalRatio), duration: 0.4)
        appearanceAction.timingMode = .easeOut
        
        planeNode.scale = SCNVector3Make(0, 0, 0)
        
        self.sceneView.scene.rootNode.addChildNode(planeNode)

        planeNode.runAction(appearanceAction)
        
        self.planeNode = planeNode
        self.imageNode = node
    }
}

