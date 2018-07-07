//
//  TouchSpotView.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 07.07.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class TouchSpotView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.lightGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Update the corner radius when the bounds change.
    override var bounds: CGRect {
        get { return super.bounds }
        set(newBounds) {
            super.bounds = newBounds
            layer.cornerRadius = newBounds.size.width / 2.0
        }
    }
}
