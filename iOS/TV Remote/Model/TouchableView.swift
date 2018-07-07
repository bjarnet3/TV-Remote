//
//  TouchableView.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 07.07.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class TouchableView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var touchViews = [UITouch:TouchSpotView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isMultipleTouchEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            createViewForTouch(touch: touch)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let view = viewForTouch(touch: touch)
            // Move the view to the new location.
            let newLocation = touch.location(in: self)
            view?.center = newLocation
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            removeViewForTouch(touch: touch)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            removeViewForTouch(touch: touch)
        }
    }
    
    // Other methods. . .

    func createViewForTouch( touch : UITouch ) {
        let newView = TouchSpotView()
        newView.bounds = CGRect(x: 0, y: 0, width: 1, height: 1)
        newView.center = touch.location(in: self)
        
        // Add the view and animate it to a new size.
        addSubview(newView)
        UIView.animate(withDuration: 0.2) {
            newView.bounds.size = CGSize(width: 100, height: 100)
        }
        
        // Save the views internally
        touchViews[touch] = newView
    }
    
    func viewForTouch (touch : UITouch) -> TouchSpotView? {
        return touchViews[touch]
    }
    
    func removeViewForTouch (touch : UITouch ) {
        if let view = touchViews[touch] {
            view.removeFromSuperview()
            touchViews.removeValue(forKey: touch)
        }
    }
}
