//
//  Remote.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 07.07.2018.
//  Copyright © 2018 Bjarne Tvedten. All rights reserved.
//

import Foundation
import MapKit

struct Coordinate: Codable {
    var latitude: Double
    var longitude: Double
}

struct Remote: Codable {
    private (set) public var _remoteName: String
    private (set) public var _remoteType: String
    private (set) public var _remoteCommands: [String]?
    private (set) public var _remoteChannels: [String:Int]?
    private (set) public var _remoteLocation: Coordinate?
    private (set) public var _remoteSSID: String?
    private (set) public var _remoteHost: String?
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
    
    init(remoteName: String, remoteType: String, remoteCommands: [String]?, remoteChannels: [String:Int]?, remoteSSID: String, remoteHost: String, remoteIP: String, remotePort: String) {
        self._remoteName = remoteName
        self._remoteType = remoteType
        self._remoteCommands = remoteCommands
        self._remoteChannels = remoteChannels
        self._remoteSSID = remoteSSID
        self._remoteHost = remoteHost
        self._remoteIP = remoteIP
        self._remotePort = remotePort
    }
}
