//
//  UXView.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 07.07.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class UXView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func layoutSubviews() {
        setEffect()
    }
}

extension UXView {
    func setEffect(blurEffect: UIBlurEffectStyle = .dark) {
        for view in subviews {
            if view is UIVisualEffectView {
                view.removeFromSuperview()
            }
        }
        
        let frost = UIVisualEffectView(effect: UIBlurEffect(style: blurEffect))
        frost.frame = bounds
        frost.autoresizingMask = .flexibleWidth
        
        insertSubview(frost, at: 0)
    }
}

extension UISearchBar {
    func setEffect(blurEffect: UIBlurEffectStyle = .dark) {
        for view in subviews {
            if view is UIVisualEffectView {
                view.removeFromSuperview()
            }
        }

        let frost = UIVisualEffectView(effect: UIBlurEffect(style: blurEffect))
        frost.frame = bounds
        frost.autoresizingMask = .flexibleWidth

        insertSubview(frost, at: 0)
    }
}
