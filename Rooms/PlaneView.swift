//
//  RoomsView.swift
//  Rooms
//
//  Created by Michael Teeuw on 25-11-14.
//  Copyright (c) 2014 Michael Teeuw. All rights reserved.
//

import UIKit

struct Color {
    struct Pillar {
        static let Default = UIColor.whiteColor()
        static let Start = UIColor.yellowColor()
        static let End = UIColor.greenColor()
    }
    struct Wall {
        static let Default = UIColor(white: 0.7, alpha: 1)
        static let Active = UIColor.whiteColor()
    }
    struct Room {
        static let PlayerA = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        static let PlayerB = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
    }
    
    struct Background {
        static let PlayerA = UIColor(red: 0.25, green: 0, blue: 0, alpha: 1)
        static let PlayerB = UIColor(red: 0, green: 0, blue: 0.25, alpha: 1)
    }
}



class PlaneView: UIView {

    // Settings
    let PADDING:CGFloat = 20
    let RADIUS:CGFloat = 4
    let LINE_WIDTH:CGFloat = 3
    
    var pillars: Array<Pillar>?         { didSet { setNeedsDisplay() }}
    var walls: Array<Wall>?             { didSet { setNeedsDisplay() }}
    var rooms: Array<Room>?             { didSet { setNeedsDisplay() }}
    var startPillar:Pillar?             { didSet { setNeedsDisplay() }}
    var endPillar:Pillar?               { didSet { setNeedsDisplay() }}
    var horizontalRooms:Int = 0         { didSet { setNeedsDisplay() }}
    var verticalRooms:Int = 0           { didSet { setNeedsDisplay() }}
    var currentPlayer: Player = .A      { didSet { setNeedsDisplay() }}
    
    var roomSize:CGSize  {
        get {
            return CGSizeMake((self.bounds.size.width - PADDING * 2) / CGFloat(horizontalRooms), (self.bounds.size.height - PADDING * 2) / CGFloat(verticalRooms))
        }
    }
    
    convenience init(horizontalRooms:Int, verticalRooms:Int) {
        self.init()
        
        self.horizontalRooms = horizontalRooms
        self.verticalRooms = verticalRooms
    }
    
    override func drawRect(rect: CGRect) {
        
        CGContextClearRect(UIGraphicsGetCurrentContext(), rect);
        
        drawBackground()
        drawRooms()
        drawLines()
        drawGrid()
    }
    
    func drawBackground() {
        if (currentPlayer == .A) {
            Color.Background.PlayerA.setFill()
        } else {
            Color.Background.PlayerB.setFill()
        }
        
        UIBezierPath(rect: self.bounds).fill()
    }
    
    func drawRooms() {
        if let rooms = rooms? {
            for room in rooms {
                let topLeftPoint = pillarCenter(room.topLeftPillar)
                if (room.player == .A) {
                    Color.Room.PlayerA.setFill()
                } else {
                    Color.Room.PlayerB.setFill()
                }
                UIBezierPath(rect: CGRect(x: topLeftPoint.x, y: topLeftPoint.y, width: roomSize.width, height: roomSize.height)).fill()
            }
        }
    }
   
    func drawLines() {
        
        // draw gesture line
        if startPillar != nil && endPillar != nil {
            let line = UIBezierPath()
            line.moveToPoint(pillarCenter(startPillar!))
            line.addLineToPoint(pillarCenter(endPillar!))
            
            Color.Wall.Active.setStroke()
            line.lineWidth = LINE_WIDTH
            line.stroke()
        }
        
        // draw other lines
        if let walls = walls? {
            for wall in walls {
                let otherLine = UIBezierPath()
                otherLine.moveToPoint(pillarCenter(wall.startPillar))
                otherLine.addLineToPoint(pillarCenter(wall.endPillar))
                
                Color.Wall.Default.setStroke()
                otherLine.lineWidth = LINE_WIDTH
                otherLine.stroke()
            }
        }
    }
    
    func drawGrid() {
        
        let gridPath = UIBezierPath()
        if let pillars = pillars? {
            for pillar in pillars {
                
                if pillar == startPillar {
                    Color.Pillar.Start.setFill()
                } else if pillar == endPillar {
                    Color.Pillar.End.setFill()
                } else {
                    Color.Pillar.Default.setFill()
                }
         
                UIBezierPath(arcCenter: self.pillarCenter(pillar), radius: RADIUS, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: true).fill()
            }
        }
        
    }
    
    func pillarCenter(gridPoint:Pillar) -> CGPoint {
        
        if horizontalRooms > 0 && verticalRooms > 0 {
    
            return CGPoint(x: roomSize.width * CGFloat(gridPoint.x) + PADDING, y: roomSize.height * CGFloat(gridPoint.y) + PADDING)

        }
        
        return CGPointZero
    }
    
    func findNearbyPillar(point:CGPoint, inPillars pillars:Array<Pillar>) -> Pillar? {
        var nearbyPillar = pillars.first
        var minDistance = self.bounds.size.height * self.bounds.size.width
    
        for pillar in pillars {
            var pillarCenter = self.pillarCenter(pillar)
            let xDist = (pillarCenter.x - point.x)
            let yDist = (pillarCenter.y - point.y)
            let distance = sqrt((xDist * xDist) + (yDist * yDist))
            
            if (distance < minDistance) {
                minDistance = distance
                nearbyPillar = pillar
            }
            
        }
    
        return nearbyPillar
    }
    
}
