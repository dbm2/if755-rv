//
//  MemoryCardViewModel.swift
//  ex-1-tracking
//
//  Created by Daniel Barbosa Maranhão on 06/09/18.
//  Copyright © 2018 Daniel Barbosa Maranhão. All rights reserved.
//

import Foundation


class MemoryCardViewModel: MemoryCardViewModelProtocol {
    
    fileprivate enum MemoryCard {
        case green
        case yellow
        case orange
        
        init(withImageName imageName: String) {
            switch imageName {
            case "mk1":
                self = .green
            case "mk2":
                self = .green
            case "mk3":
                self = .yellow
            case "mk4":
                self = .yellow
            case "mk5":
                self = .orange
            case "mk6":
                self = .orange
            default:
                self = .orange
            }
        }
    }
    
    weak var delegate: MemoryCardViewModelDelegate?
    
    fileprivate var points: Int = 0
    
    fileprivate var recognizedCardsCount: [MemoryCard: Int] = [:]
    
    func restart() {
        self.recognizedCardsCount = [:]
        self.points = 0
        self.delegate?.didUpdate(points: self.points)
    }
    
    func didRecognizeImage(withName name: String) {
        
        let card: MemoryCard = MemoryCard(withImageName: name)
        
        self.updateCount(ofCard: card, isIncreasing: true)
    }
    
    func didStopRecognizingImage(withName name: String) {
        
        let card: MemoryCard = MemoryCard(withImageName: name)
        
        self.updateCount(ofCard: card, isIncreasing: false)
    }
    
    fileprivate func updateCount(ofCard card: MemoryCard, isIncreasing: Bool) {
        let cardCount = self.recognizedCardsCount[card] ?? 0
        
        let newCardCount = max(min(cardCount + (isIncreasing ? 1 : -1), 2), 0)
        
        self.recognizedCardsCount.updateValue(newCardCount, forKey: card)
        
        self.points = self.recognizedCardsCount.reduce(0, { result, cardCount in
            result + (cardCount.value == 2 ? 1 : 0)
        })
        
        self.delegate?.didUpdate(points: self.points)
    }
}
