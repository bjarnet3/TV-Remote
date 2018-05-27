//
//  CustomImageView.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 12.10.2016.
//  Copyright © 2016 Digital Mood. All rights reserved.
//

import UIKit

// @IBDesignable

class CustomImageView: UIImageView {

    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.purple.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = true
        self.layer.cornerRadius = self.frame.height / 2
        
    }
}
