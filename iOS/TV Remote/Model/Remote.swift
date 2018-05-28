//
//  Remote.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 28.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit
import MapKit

struct Remote {
    private (set) public var _remoteName: String
    private (set) public var _remoteCommand: String
    private (set) public var _remoteLocation: CLLocation?
    
    var remoteCommand : String {
        return _remoteCommand
    }
    var remoteName : String {
        return _remoteName
    }
    
    init(remoteName: String, remoteCommand: String) {
        self._remoteName = remoteName
        self._remoteCommand = remoteCommand
    }
}
