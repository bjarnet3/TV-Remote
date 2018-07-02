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
    private (set) public var _remoteType: String
    private (set) public var _remoteCommands: [String]?
    private (set) public var _remoteLocation: CLLocation?
    private (set) public var _remoteSSID: String?
    private (set) public var _remoteIP: String?
    private (set) public var _remotePort: String?
    private (set) public var _remoteSSL: Bool = false
    
    var remoteType: String {
        return _remoteType
    }
    var remoteName : String {
        return _remoteName
    }
    
    init(remoteName: String, remoteType: String) {
        self._remoteName = remoteName
        self._remoteType = remoteType
    }
}
