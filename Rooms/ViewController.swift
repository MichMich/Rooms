//
//  ViewController.swift
//  Rooms
//
//  Created by Michael Teeuw on 25-11-14.
//  Copyright (c) 2014 Michael Teeuw. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let game = Game()
    let plane = Plane(horizontalRooms:5, verticalRooms:7)
    let planeView = PlaneView()
    let gestureRecognizer = UIPanGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add view
        planeView.horizontalRooms = plane.horizontalRooms
        planeView.verticalRooms = plane.verticalRooms
        view.addSubview(planeView)
        
        // add gesture recognizer
        gestureRecognizer.addTarget(self, action: "panGesture:")
        planeView.addGestureRecognizer(gestureRecognizer)
        
        //planeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tapped:"))
        
        // draw pillars
        planeView.pillars = plane.pillars
        planeView.walls = plane.walls
        
        
    }
    
    override func viewDidLayoutSubviews() {
        planeView.frame = view.bounds
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func startNewGame() {
        game.reset()
        plane.reset()
        planeView.pillars = plane.pillars
        planeView.walls = plane.walls
        planeView.rooms = plane.rooms
    }

/*
    func tapped(gesture:UITapGestureRecognizer) {
        plane.addRandomWall()
        planeView.walls = plane.walls
    }
*/
    
    func panGesture(gesture:UIPanGestureRecognizer) {
        
        switch (gesture.state) {
            
            case UIGestureRecognizerState.Began:
                // Gesture Began. Find Start Pillar.
                let gesturePillar = planeView.findNearbyPillar(gesture.locationInView(planeView), inPillars: plane.pillars)
                
                planeView.endPillar = nil
                planeView.startPillar = gesturePillar
     
            case UIGestureRecognizerState.Changed:
                // Gesture Changed. Find End Pillar.
                if planeView.startPillar != nil {
                    let gesturePillar = planeView.findNearbyPillar(gesture.locationInView(planeView), inPillars: plane.allowedConnectionPillarsFor(planeView.startPillar!))
                    planeView.endPillar = (gesturePillar != planeView.startPillar) ? gesturePillar : nil
                }
                
            case UIGestureRecognizerState.Ended:
                // Gesture Ended. Add wall.
                if planeView.startPillar != nil && planeView.endPillar != nil {
                    if (!plane.hasWallBetweenPillar(planeView.startPillar!, andPillar: planeView.endPillar!, inWalls: plane.walls)) {
                        let newRooms = plane.addWallBetweenPillar(planeView.startPillar!, andPillar: planeView.endPillar!, byPlayer:game.currentPlayer)
                        
                        if newRooms.count > 0 {
                            planeView.rooms = plane.rooms
                            checkScore()
                        } else {
                            game.nextPlayer()
                            planeView.currentPlayer = game.currentPlayer
                            
                        }
                        
                        planeView.walls = plane.walls
                    }
                }
                
                planeView.startPillar = nil
                planeView.endPillar = nil
                
            default:
                // Gesure Canceled.
                planeView.startPillar = nil
                planeView.endPillar = nil
            
        }
        
    }
    
    func checkScore() {
        if (plane.rooms.count >= plane.horizontalRooms * plane.verticalRooms) {
            let roomsPlayerA = plane.countRoomsForPlayer(.A)
            let roomsPlayerB = plane.countRoomsForPlayer(.B)

            let title = (roomsPlayerA > roomsPlayerB) ? "RED Wins!" : "BLUE Wins!"
            let message = "Red: \(roomsPlayerA) - Blue: \(roomsPlayerB)"
            
            var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "New Game", style: UIAlertActionStyle.Default, handler: { action in
                self.startNewGame()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    

}

