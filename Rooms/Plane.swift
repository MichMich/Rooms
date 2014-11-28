//
//  Room.swift
//  Rooms
//
//  Created by Michael Teeuw on 26-11-14.
//  Copyright (c) 2014 Michael Teeuw. All rights reserved.
//

import Foundation

func ==(lhs: Pillar, rhs: Pillar) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
}

func ==(lhs: Wall, rhs: Wall) -> Bool {
    return lhs.startPillar == rhs.startPillar && lhs.endPillar == rhs.endPillar
}

func ==(lhs: Room, rhs: Room) -> Bool {
    return lhs.topLeftPillar == rhs.topLeftPillar
}

struct Pillar : Equatable{
    var x:Int
    var y:Int
}

struct Wall : Equatable {
    var startPillar:Pillar
    var endPillar:Pillar
}

struct Room {
    var topLeftPillar:Pillar
    var player:Player = .A
}

class Plane {
    
    let horizontalRooms:Int
    let verticalRooms:Int
    
    var pillars = [Pillar]()
    var walls = [Wall]()
    var rooms = [Room]()
    
    var currentPlayer = Player.A
    
    init(horizontalRooms:Int, verticalRooms:Int) {
        self.horizontalRooms = horizontalRooms
        self.verticalRooms = verticalRooms
        
        generate()
    }
    
    func reset() {
        walls = [Wall]()
        rooms = [Room]()
    }
    
    func generate() {
        for gridX in 0 ... horizontalRooms {
            for gridY in 0 ... verticalRooms {
                pillars.append(Pillar(x: gridX, y: gridY))
            }
        }
    }
    
    func addWallBetweenPillar(pillarA:Pillar, andPillar pillarB:Pillar, byPlayer player:Player) -> Array<Room> {
        walls.append(Wall(startPillar: pillarA, endPillar: pillarB))
        let newRooms = self.roomsWithWall(Wall(startPillar: pillarA, endPillar: pillarB), andPlayer:player)
        
        rooms += newRooms
        
        return newRooms
    }
    
    func allowedConnectionPillarsFor(pillar:Pillar) -> Array<Pillar>{
        var allowedPillars = [Pillar]()
        
        for otherPillar in pillars {
            if wallAllowedBetweenPillar(pillar, andPillar: otherPillar) {
                allowedPillars.append(otherPillar)
            }
        }
        
        return allowedPillars
    }
    
    func wallAllowedBetweenPillar(pillarA:Pillar, andPillar pillarB:Pillar) -> Bool {
        
        var dX = abs(pillarA.x - pillarB.x)
        var dY = abs(pillarA.y - pillarB.y)
        
        if  (dX <= 1 && dY <= 1) && (dX == 0 || dY == 0) {
            return true
        }
        
        return false
    }
    
    func roomsWithWall(wall:Wall, andPlayer player:Player) -> Array<Room> {
        
        var rooms = [Room]()
        if (wall.startPillar.x == wall.endPillar.x) {
            //Vertical wall
            let topPillar = (wall.startPillar.y < wall.endPillar.y) ? wall.startPillar : wall.endPillar
            
            //Check left side of wall
            if (topPillar.x > 0) {
                //println("Check left side")
                if (self.hasRoomWithTopLeftPillar(Pillar(x: topPillar.x - 1, y: topPillar.y))) {
                    rooms.append(Room(topLeftPillar: Pillar(x: topPillar.x - 1, y: topPillar.y), player:player))
                }
            }
            
            //Check right side of wall
            if (topPillar.x < horizontalRooms) {
                //println("Check right side")
                if (self.hasRoomWithTopLeftPillar(topPillar)) {
                    rooms.append(Room(topLeftPillar: topPillar, player:player))
                }
            }
            
        } else {
            //Horizontal wall
            let leftPillar = (wall.startPillar.x < wall.endPillar.x) ? wall.startPillar : wall.endPillar
            
            //Check above wall
            if (leftPillar.y > 0) {
                //println("Check above")
                if (self.hasRoomWithTopLeftPillar(Pillar(x: leftPillar.x, y: leftPillar.y - 1))) {
                    rooms.append(Room(topLeftPillar: Pillar(x: leftPillar.x, y: leftPillar.y - 1), player:player))
                }
            }
            
            //Check below wall
            if (leftPillar.y < verticalRooms) {
                //println("Check below")
                if (self.hasRoomWithTopLeftPillar(leftPillar)) {
                    rooms.append(Room(topLeftPillar: leftPillar, player:player))
                }
            }
            
        }
        
        return rooms
    }
    
    func hasRoomWithTopLeftPillar(topLeftPillar:Pillar) -> Bool {
        if (topLeftPillar.x > horizontalRooms || topLeftPillar.y > verticalRooms) {
            return false
        }

        let topRightPillar = Pillar(x: topLeftPillar.x + 1, y: topLeftPillar.y)
        let bottomLeftPillar = Pillar(x: topLeftPillar.x, y: topLeftPillar.y + 1)
        let bottomRightPillar = Pillar(x: topLeftPillar.x + 1, y: topLeftPillar.y + 1)

        if  self.hasWallBetweenPillar(topLeftPillar, andPillar: topRightPillar) &&
            self.hasWallBetweenPillar(topRightPillar, andPillar: bottomRightPillar) &&
            self.hasWallBetweenPillar(bottomRightPillar, andPillar: bottomLeftPillar) &&
            self.hasWallBetweenPillar(bottomLeftPillar, andPillar: topLeftPillar) {
            return true
        }
        
        return false
    }
    
    func hasWallBetweenPillar(pillarA:Pillar, andPillar pillarB:Pillar) -> Bool {
        if find(walls, Wall(startPillar: pillarA, endPillar: pillarB)) != nil {
            return true
        }
        if find(walls, Wall(startPillar: pillarB, endPillar: pillarA)) != nil {
            return true
        }
        
        return false
    }
    
    func countRoomsForPlayer(player:Player) -> Int {
        var roomCount = 0
        
        for room in rooms {
            if room.player == player {
                roomCount++
            }
        }
        
        return roomCount
    }
}


