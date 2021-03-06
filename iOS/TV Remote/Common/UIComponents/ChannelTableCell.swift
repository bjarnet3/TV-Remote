//
//  ChannelTableCell.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 28.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class ChannelTableCell: UITableViewCell {

    @IBOutlet weak var channelImageView: UIImageView!
    @IBOutlet weak var channelName: UILabel!
    @IBOutlet weak var channelNumber: UILabel!
    @IBOutlet weak var channelCategory: UILabel!
    
    var channelImageLoaded = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        if highlighted {
            exitAnimation()
        } else {
            enterAnimation()
        }

    }
    
    public enum Direction {
        case enter
        case exit
    }

    func enterAnimation(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.45, delay: 0.0, usingSpringWithDamping: 0.35, initialSpringVelocity: 0.225, options: .curveEaseOut, animations: {

                self.alpha = 1
                self.layer.transform = CATransform3DMakeRotation(0, 1, 0, 0)

                // self.contentView.alpha = 1
                // self.contentView.transform = CGAffineTransform(scaleX: 1.00, y: 1.00)
            })
        } else {
            self.contentView.alpha = 1
            self.contentView.transform = CGAffineTransform(scaleX: 1.00, y: 1.00)
        }

    }

    func exitAnimation(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: 0.50, delay: 0.0, usingSpringWithDamping: 0.40, initialSpringVelocity: 0.25, options: .curveEaseOut, animations: {

                self.alpha = 0.85
                self.layer.transform = CATransform3DMakeRotation(CGFloat.pi / 15, 1, 0, 0)

                // self.contentView.alpha = 0.85
                // self.contentView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            })
        } else {
            self.contentView.alpha = 0.85
            self.contentView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    func animateView( direction: Direction) {
        if direction == .enter {
            self.contentView.alpha = 0
            self.setNeedsDisplay(channelImageView.frame)
            self.contentView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            // self.layer.transform = CATransform3DMakeRotation(CGFloat.pi / 16, 0, 1, 0)
        } else {
            self.contentView.alpha = 1
            self.contentView.transform = CGAffineTransform(scaleX: 1.00, y: 1.00)
            // self.layer.transform = CATransform3DMakeRotation(0, 0, 1, 0)
        }
    }
    
    func setupView(channel: Channel, animated: Bool = true) {
        if let imageName = channel._channelImageName {
            if animated {
                animateView(direction: .enter)
                self.channelImageView.loadLocalImage(imageName: imageName, completion: {
                    let random = Double(arc4random_uniform(UInt32(280))) / 1650
                    UIView.animate(withDuration: 0.58, delay: random, usingSpringWithDamping: 0.44, initialSpringVelocity: 0.28, options: .curveEaseOut, animations: {
                        self.animateView(direction: .exit)
                        
                        self.channelName.text = channel._channelName
                        self.channelNumber.text = "\(channel._channelNumber)"
                        self.channelCategory.text = channel._channelCategory ?? ""
                    })
                    self.channelImageLoaded = true
                })
            } else {
                self.channelImageView.image = UIImage(named: imageName)
                self.channelName.text = channel._channelName
                self.channelNumber.text = "\(channel._channelNumber)"
                self.channelCategory.text = channel._channelCategory ?? ""
            }
        }
    }
}
