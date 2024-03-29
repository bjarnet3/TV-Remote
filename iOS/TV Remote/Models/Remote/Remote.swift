//
//  Remote.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 28.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit
import MapKit

enum RemoteType {
    case ir, smart
}

struct Remote {
    private var _remoteName: String
    private var _remoteType: RemoteType
    private var _remoteCommands: [String]?
    private var _remoteLocation: CLLocation?
    private var _remoteSSID: String?
    private var _remoteIP: String?
    private var _remotePin: String?
    private var _remotePort: String?
    private var _remoteSSL: Bool = false

    var remoteName: String {
        return _remoteName
    }

    var remoteType: RemoteType {
        return _remoteType
    }

    var remoteIP: String {
        return _remoteIP ?? "192.168.50.7"
    }

    var remotePin: String {
        return _remotePin ?? "0000"
    }
    
    init(name: String, type: RemoteType, ip: String? = nil, pin: String? = nil) {
        self._remoteName = name
        self._remoteType = type
        self._remoteIP = ip
        self._remotePin = pin
    }
}
