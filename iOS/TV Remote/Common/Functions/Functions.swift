//
//  Functions.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 21.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

// Stored Images
let imageCache = NSCache<NSString, UIImage>()

// Completion Typealias
public typealias Completion = () -> Void

// First understandable and usefull enum - (enum here used for typo arguments)
public enum HapticEngineTypes {
    case error, success, warning, light, medium, heavy, selection
}

/// haptic engine effect when pressing buttons - Parameter: Hello
public func hapticButton(_ types: HapticEngineTypes,_ fire: Bool = true) {
    if fire {
        switch types {
        case .error:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        case .success:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        case .warning:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        case .light:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        case .medium:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        case .heavy:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        default:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
}

public func animateCellsWithProgress(in tableView: UITableView,_ animated: Bool = true, progress: UIProgressView, completion: Completion? = nil) {
    if animated /* && lowPowerModeDisabled */ {
        let cells = tableView.visibleCells
        progress.setProgress(0.05, animated: true)
        progress.backgroundColor = PINK_NANNY_LOGO
        for cell in cells { cell.alpha = 0 }
        tableView.alpha = 1
        var index = 0
        for cell in cells {
            // cell.layer.transform = CATransform3DMakeRotation(CGFloat.pi / 4, 1, 0, 0)
            cell.transform = CGAffineTransform(scaleX: 0.89, y: 0.89)
            UIView.animate(withDuration: 0.800, delay: 0.040 * Double(index), usingSpringWithDamping: 0.75, initialSpringVelocity: 0.65, options: .curveEaseOut, animations: {
                cell.alpha = 1
                // sett "end" transition point
                let value = (Float(index)/(Float(cells.count))) * (0.3 + Float(index)/100.0)
                progress.progress = value
                // cell.layer.transform = CATransform3DMakeRotation(0, 1, 0, 0)
                cell.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: { (true) in
                
            })
            index += 1
            if index == cells.count {
                print("index and cells.count is equal")
                UIView.animate(withDuration: 0.60, delay: 0.75, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    progress.setProgress(1.0, animated: true)
                    progress.alpha = 1.0
                    progress.backgroundColor = UIColor.black
                })
            }
        }
    } else {
        tableView.alpha = 1
    }
}

/// animate imageView or View (parallax Effect)
public func addParallaxEffectOnView<T>(_ view: T, _ relativeMotionValue: Int) {
    let relativeMotionValue = relativeMotionValue
    let verticalMotionEffect : UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y",
                                                                                         type: .tiltAlongVerticalAxis)
    verticalMotionEffect.minimumRelativeValue = -relativeMotionValue
    verticalMotionEffect.maximumRelativeValue = relativeMotionValue
    
    let horizontalMotionEffect : UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x",
                                                                                           type: .tiltAlongHorizontalAxis)
    horizontalMotionEffect.minimumRelativeValue = -relativeMotionValue
    horizontalMotionEffect.maximumRelativeValue = relativeMotionValue
    
    let group : UIMotionEffectGroup = UIMotionEffectGroup()
    group.motionEffects = [horizontalMotionEffect, verticalMotionEffect]
    
    if let view = view as? UIView {
        view.addMotionEffect(group)
    } else {
        print("unable to add parallax Effect on View / ImageView")
    }
    
}

/// removes motionEffects (on view), if any
public func removeParallaxEffectOnView(_ view: UIView) {
    let motionEffects = view.motionEffects
    for motion in motionEffects {
        view.removeMotionEffect(motion)
    }
}

/// argument **String** of **#HEX** returns **UIColor** value
public func hexStringToUIColor (_ hex:String, _ alpha: Float? = 1.0) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: (NSCharacterSet.whitespacesAndNewlines as NSCharacterSet) as CharacterSet).uppercased()
    
    if (cString.hasPrefix("#")) {
        // let index: String.Index = cString.index(cString.startIndex, offsetBy: 1)
        // cString = cString.substring(from: index) // "Stack"
        cString.removeFirst()// String(cString[index...cString.endIndex])
    }
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(alpha!)
    )
}

// Color Constants
let SHADOW_GRAY: CGFloat = 120.0 / 255.0
let BLACK_SOLID = UIColor.black
let GRAY_SOLID = UIColor.gray

let WHITE_SOLID = hexStringToUIColor("#FFFFFF")
let WHITE_ALPHA = hexStringToUIColor("#FFFFFF", 0.3)

// Nanny Colors
let PINK_SOLID = hexStringToUIColor("#cc00cc")
let PINK_DARK_SOLID = hexStringToUIColor("#660033")
let PINK_DARK_SHARP = hexStringToUIColor("#FF3191") // FF3191

let ORANGE_SOLID = hexStringToUIColor("#cc3300")
let RED_SOLID = hexStringToUIColor("#cc0000")
let RED_SHARP_SOLID = hexStringToUIColor("#FF0D23")
let RED_SHARP_ALPHA = hexStringToUIColor("#FF0D23", 0.5)

let RED_PINK_SOLID = hexStringToUIColor("#FF294C")

let PINK_NANNY_LOGO = hexStringToUIColor("#ff3366")
let ORANGE_NANNY_LOGO = hexStringToUIColor("#ff6633")

let PINK_TABBAR_SELECTED = hexStringToUIColor("#FC2F92")
let PINK_TABBAR_UNSELECTED = hexStringToUIColor("#FF85FF")

let LIGHT_GREY = hexStringToUIColor("#EBEBEB")
let LIGHT_PINK = hexStringToUIColor("#FF72C8")
let LIGHT_BLUE = hexStringToUIColor("#0096FF")

let AQUA_BLUE = hexStringToUIColor("#0096FF")
let STRAWBERRY = hexStringToUIColor("#FF2F92")
let SILVER     = hexStringToUIColor("#D6D6D6")
