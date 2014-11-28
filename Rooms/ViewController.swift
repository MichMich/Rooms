//
//  ViewController.swift
//  Rooms
//
//  Created by Michael Teeuw on 25-11-14.
//  Copyright (c) 2014 Michael Teeuw. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let plane = Plane(horizontalRooms: 4, verticalRooms: 7)
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
        
        // draw pillars
        planeView.pillars = plane.pillars
    }

    override func viewDidLayoutSubviews() {
        planeView.frame = view.bounds
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    

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
                    if (!plane.hasWallBetweenPillar(planeView.startPillar!, andPillar: planeView.endPillar!)) {
                        plane.addWallBetweenPillar(planeView.startPillar!, andPillar: planeView.endPillar!)
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
    

}

