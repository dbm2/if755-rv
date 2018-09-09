//
//  MCTrackerProtocol.swift
//  ex-1-tracking
//
//  Created by Daniel Barbosa Maranhão on 06/09/18.
//  Copyright © 2018 Daniel Barbosa Maranhão. All rights reserved.
//

import Foundation

protocol MCTrackerProtocol {
    
    func start()
    
    func pause()
    
    func clear()
    
    func shouldRemoveOutdatedHolders(_ state: Bool)
}
