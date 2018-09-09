//
//  MemoryCardViewModelDelegate.swift
//  ex-1-tracking
//
//  Created by Daniel Barbosa Maranhão on 06/09/18.
//  Copyright © 2018 Daniel Barbosa Maranhão. All rights reserved.
//

import Foundation

protocol MemoryCardViewModelDelegate: class {
    
    func didUpdate(points: Int)
}
