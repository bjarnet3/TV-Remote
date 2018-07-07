//
//  UXButton.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 07.07.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class UXButton: UIButton {

    var size:CGFloat = 0
    
    override func draw(_ rect: CGRect) {
        /*
        let view_width = self.bounds.width
        let view_height = self.bounds.height
        
        let context = UIGraphicsGetCurrentContext()
        let rectangle = CGRect(x: 0, y: view_height - size,
                               width: view_width, height: size)
        context?.addRect(rectangle)
        context?.setFillColor(UIColor.red.cgColor)
        context?.fill(rectangle)
 
        */
    }
    
    
    /*
    var feedbackGenerator: (notification: UINotificationFeedbackGenerator, impact: (light: UIImpactFeedbackGenerator, medium: UIImpactFeedbackGenerator, heavy: UIImpactFeedbackGenerator), selection: UISelectionFeedbackGenerator)? = {
        return (notification: UINotificationFeedbackGenerator(), impact: (light: UIImpactFeedbackGenerator(style: .light), medium: UIImpactFeedbackGenerator(style: .medium), heavy: UIImpactFeedbackGenerator(style: .heavy)), selection: UISelectionFeedbackGenerator())
    }()
    
    let sections: [(title: String, options: [String])] = [
        ("Basic", ["Standard Vibration", "Alert Vibration"]),
        ("Taptic Engine", ["Peek", "Pop", "Cancelled", "Try Again", "Failed"]),
        ("Haptic Feedback - Notification", ["Success", "Warning", "Error"]),
        ("Haptic Feedback - Impact", ["Light", "Medium", "Heavy"]),
        ("Haptic Feedback - Selection", ["Selection"])
    ]
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        
        // Instantiate a new generator.
        feedbackGenerator?.selection.prepare()
        
        handleTouch(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        
        feedbackGenerator?.selection.selectionChanged()
        
        feedbackGenerator?.selection.prepare()
        
        handleTouch(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        
        feedbackGenerator = nil
        
        size = 0
        self.setNeedsDisplay()
    }
    
    func handleTouch(_ touches:Set<UITouch>) {
        
        let feedbackLight = feedbackGenerator?.impact.light
        let feedbackMedium = feedbackGenerator?.impact.medium
        let feedbackHeavy = feedbackGenerator?.impact.heavy
        
        let touch = touches.first
        size = touch!.force * 100
        
        let ligthForce = (touch?.maximumPossibleForce)! / 3.3
        let mediumForce = (touch?.maximumPossibleForce)! / 2.2
        let maximumForce = (touch?.maximumPossibleForce)!
        
        if let force = touch?.force {
            switch force {
            case 0..<ligthForce:
                feedbackLight?.impactOccurred()
            case ligthForce..<mediumForce:
                print(" medium force")
                feedbackMedium?.impactOccurred()
            case mediumForce..<maximumForce:
                feedbackHeavy?.impactOccurred()
            default:
                print("default")
                break
            }
        }
        
        self.setNeedsDisplay()
    }
    */

}
