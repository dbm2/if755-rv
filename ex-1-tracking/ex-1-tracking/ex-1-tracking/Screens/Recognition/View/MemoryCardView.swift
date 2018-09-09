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

class MemoryCardView: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    fileprivate var pointsLabel: UILabel!
    fileprivate var wonAlert: UIAlertController!
    
    fileprivate var tracker: MCTracker!
    
    fileprivate var viewModel: MemoryCardViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel = MemoryCardViewModel()
        self.viewModel.delegate = self
        
        self.setupView()
        
        self.prepareCardsTracking()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tracker.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tracker.pause()
    }
    
    fileprivate func setupView() {
        self.setupPointsLabel()
        self.setupWonView()
    }
    
    fileprivate func prepareCardsTracking() {
        
        self.tracker = MCTracker(withSceneView: self.sceneView, withDelegate: self)
        
        self.sceneView.delegate = self.tracker
    }
}

extension MemoryCardView {

    fileprivate func setupPointsLabel() {
        let labelFrame: CGRect = CGRect(x: 0.0,
                                        y: 20.0,
                                        width: self.sceneView.frame.width,
                                        height: 30.0)
        self.pointsLabel = UILabel(frame: labelFrame)
        self.pointsLabel.text = "Pontuação: 0"
        self.pointsLabel.textAlignment = .center
        self.pointsLabel.textColor = .white
        
        self.sceneView.addSubview(self.pointsLabel)
    }
    
    fileprivate func setupWonView() {
        self.wonAlert = UIAlertController(title: "You won!", message: nil, preferredStyle: .alert)
        self.wonAlert.addAction(UIAlertAction(title: "Restart", style: .default, handler: { (_) in
            self.tracker.clear()
            self.viewModel.restart()
        }))
    }
}

extension MemoryCardView: MCTrackerDelegate {
    
    func didRecognize(holder: MCHolder) {
        guard let imageName = holder.anchor.referenceImage.name else {
            return
        }
        
        self.viewModel.didRecognizeImage(withName: imageName)
    }
    
    func didStopRecognizing(holder: MCHolder) {
        guard let imageName = holder.anchor.referenceImage.name else {
            return
        }
        
        self.viewModel.didStopRecognizingImage(withName: imageName)
    }
}

extension MemoryCardView: MemoryCardViewModelDelegate {
    
    func didUpdate(points: Int) {
        self.pointsLabel.text = "Pontuação: \(points)"
        
        if (points == 3 && self.presentedViewController == nil) {
            self.tracker.shouldRemoveOutdatedHolders(false)
            self.present(self.wonAlert, animated: true, completion: nil)
        }
    }
}


