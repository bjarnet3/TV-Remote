//
//  CustomButton.swift
//  TV Remote Extension
//
//  Created by Bjarne Tvedten on 01.02.2018.
//  Copyright © 2018 Bjarne Tvedten. All rights reserved.
//

import Cocoa

// NSButton Subclass that will perform action on .leftMouseDown "instead of default .leftMouseUp"
// ----------------------------------------------------------------------------------------------
class CustomButton: NSButton {
    
    // Make it Customizable in Interface Builder "Attributes Inspector"
    @IBInspectable open var backgroundColor: NSColor?
    @IBInspectable open var buttonDown: Bool = true
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Thanx to https://stackoverflow.com/questions/3651767/nsbutton-mousedown-event
        //
        // if buttonDown { self.sendAction(on: .leftMouseDown) } else { self.sendAction(on: .leftMouseUp) }
        //
        // Ternary Operator
        let mouseEvent = buttonDown ? NSEvent.EventTypeMask.leftMouseDown : NSEvent.EventTypeMask.leftMouseUp
        self.sendAction(on: mouseEvent)
        
        // The Background Color Of Button
        self.layer?.backgroundColor = backgroundColor?.cgColor
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
