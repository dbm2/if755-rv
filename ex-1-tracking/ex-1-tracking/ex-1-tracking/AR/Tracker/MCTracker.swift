//
//  ViewController+ARSCNViewDelegate.swift
//  ex-1-tracking
//
//  Created by Daniel Barbosa Maranhão on 06/09/18.
//  Copyright © 2018 Daniel Barbosa Maranhão. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class MCTracker: NSObject, MCTrackerProtocol, ARSCNViewDelegate {
    
    fileprivate var sceneView: ARSCNView
    
    fileprivate var referenceImages: Set<ARReferenceImage>

    fileprivate static let imagesNames3DModels: [String: String] = ["mk1": "box1",
                                                                    "mk2": "box1",
                                                                    "mk3": "box2",
                                                                    "mk4": "box2",
                                                                    "mk5": "box3",
                                                                    "mk6": "box3"]
    
    fileprivate weak var delegate: MCTrackerDelegate?
    
    fileprivate var holders: [MCHolder] = []
    
    fileprivate let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! + ".MCTracker")
    
    fileprivate var shouldRemoveOutdatedHolders: Bool = true
    
    fileprivate var detectionAction: SCNAction {
        return SCNAction.wait(duration: 0)
    }
    
    init(withSceneView sceneView: ARSCNView, withDelegate delegate: MCTrackerDelegate? = nil) {
        self.sceneView = sceneView
        
        self.delegate = delegate
        
        self.referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil)!
    }
    
    func start() {
        let trackingConfiguration: ARWorldTrackingConfiguration = ARWorldTrackingConfiguration()
        
        trackingConfiguration.detectionImages = self.referenceImages
        
        self.sceneView.session.run(trackingConfiguration,
                                   options: [.resetTracking, .removeExistingAnchors])
    }
    
    func pause() {
         self.sceneView.session.pause()
    }
    
    func clear() {
        for holder in self.holders {
            self.removeFromScene(holder: holder)
        }
        self.holders.removeAll()
        self.shouldRemoveOutdatedHolders = true
    }
    
    
    func shouldRemoveOutdatedHolders(_ state: Bool) {
        self.shouldRemoveOutdatedHolders = state
    }
    
    fileprivate func removeFromScene(holder: MCHolder) {
        holder.imageNode.removeFromParentNode()
        
        holder.cardNode.removeFromParentNode()
        
        self.sceneView.session.remove(anchor: holder.anchor)
        
        DispatchQueue.main.async {
            self.delegate?.didStopRecognizing(holder: holder)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else {
            return
        }
        
        updateQueue.async {
            
            guard let cardNode = self.getProperNode(forAnchor: imageAnchor) else {
                return
            }
            
            let holder: MCHolder = MCHolder(cardNode: cardNode,
                                                   imageNode: node,
                                                   anchor: imageAnchor,
                                                   detectionDate: Date())
            
            cardNode.runAction(self.detectionAction)
            
            self.sceneView.scene.rootNode.addChildNode(cardNode)
            
            self.holders.append(holder)
            
            DispatchQueue.main.async {
                self.delegate?.didRecognize(holder: holder)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if (self.shouldRemoveOutdatedHolders) {
            self.removeOutdatedHolders()
        }
        
        let t: Float = sin(.pi/2)
        let f3t = simd_make_float3(t, t, t)
        
        for holder in self.holders {
            holder.cardNode.simdWorldPosition = simd_mix(holder.cardNode.simdWorldPosition,
                                                          holder.imageNode.simdWorldPosition,
                                                          f3t)
            holder.cardNode.simdWorldOrientation = simd_slerp(holder.cardNode.simdWorldOrientation,
                                                               holder.imageNode.simdWorldOrientation,
                                                               t)
        }
    }
}

extension MCTracker {
    
    fileprivate func getProperNode(forAnchor anchor: ARImageAnchor) -> SCNNode? {
        
        guard let scene = SCNScene(named: "Scenes.scnassets/boxes.scn") else {
            return nil
        }
        
        guard let imageName = anchor.referenceImage.name else {
            return nil
        }
        
        guard let image3DModel = MCTracker.imagesNames3DModels.first(where: { $0.key == imageName }) else {
            return nil
        }
        
        guard let node = scene.rootNode.childNode(withName: image3DModel.value, recursively: true) else {
            return nil
        }
        
        node.transform = SCNMatrix4(anchor.transform)
        
        let scale = self.getRatio(forNode: node, andAnchor: anchor)
        
        node.scale = SCNVector3Make(scale, scale, scale)
        
        return node
    }
    
    fileprivate func getRatio(forNode node: SCNNode, andAnchor anchor: ARImageAnchor) -> Float {
        let (minSize, maxSize) = node.boundingBox
        let size = SCNVector3Make(maxSize.x - minSize.x, maxSize.y - minSize.y, maxSize.z - minSize.z)
        
        let widthRatio = Float(anchor.referenceImage.physicalSize.width)/size.x
        let heightRatio = Float(anchor.referenceImage.physicalSize.height)/size.z
        
        return min(widthRatio, heightRatio)
    }
    
    fileprivate func removeOutdatedHolders() {
        
        let currentDate: Date = Date()
        
        self.holders = self.holders.filter({ (holder) -> Bool in
            
            guard holder.detectionDate.addingTimeInterval(5.0) > currentDate else {
                self.removeFromScene(holder: holder)
                return false
            }
            
            return true
        })
    }
}
