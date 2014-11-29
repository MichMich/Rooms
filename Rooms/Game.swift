//
//  Game.swift
//  Rooms
//
//  Created by Michael Teeuw on 28/11/14.
//  Copyright (c) 2014 Michael Teeuw. All rights reserved.
//

import Foundation

enum Player {
    case A, B
}

class Game { 
    var currentPlayer = Player.A
    
    func nextPlayer() {
        currentPlayer = (currentPlayer == .A) ? .B : .A
    }
    
    func reset() {
        currentPlayer = Player.A
    }
    
    func random() {
        currentPlayer = (Int(arc4random() % UInt32(2)) == 1) ? .A : .B
    }
}