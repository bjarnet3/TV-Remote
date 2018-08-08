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
    var Address: String
    var Room: String
    
    var latitude: Double
    var longitude: Double
}

struct Remote: Codable {
    private (set) public var _remoteName: String
    private (set) public var _remoteType: String
    private (set) public var _remoteCommands: [String]?
    private (set) public var _remoteChannels: [String:Int]?
    private (set) public var _remoteLocation: Coordinate?
    private (set) public var _remoteSelected = false
    private (set) public var _remoteSSID: String?
    private (set) public var _remoteHost: String?
    private (set) public var _remoteIP: String?
    private (set) public var _remotePort: String?
    private (set) public var _remoteSSL = false
    
    var remoteType: String {
        return _remoteType
    }
    var remoteName : String {
        return _remoteName
    }

    var remoteChannels: [String: Int]? {
        set {
            self._remoteChannels = newValue
        } get {
            return _remoteChannels
        }
    }
    
    mutating func setIP(ipAdress: String) {
        self._remoteIP = ipAdress
    }
    
    mutating func setPort(port: String) {
        self._remotePort = port
    }
    
    mutating func setSelected(selected: Bool) {
        self._remoteSelected = selected
    }
    
    // Send IR signal to Server
    func sendHTTP(keyName: String) {
        // get remoteType from remoteList
        let remote = _remoteType
        guard let ip = _remoteIP else { return }
        // guard let host = self.host else { return }
        guard let port = _remotePort else { return }
        
        // URL and HTTP POST Request
        // http://raspberrypi.local:3000/remotes/Samsung_AH59/KEY_POWER
        let secureUrl = URL(string: "https://\(ip):\(port)/remotes/\(remote)/\(keyName)")!
        let unsecureUrl = URL(string: "http://\(ip):\(port)/remotes/\(remote)/\(keyName)")!
        
        // You can test with Curl in Terminal
        // curl -d POST http://192.168.10.120:3000/remotes/Samsung_AH59/KEY_MUTE (or raspberrypi.local:3000)
        
        let url = _remoteSSL ? secureUrl : unsecureUrl
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    // NOT IN USE YET
    // --------------
    func returnChannel(from: Int) {
        let channelNumberString = String(from)
        for (idx, channel) in channelNumberString.enumerated() {
            let keyString = "KEY_\(channel)"
            if (idx + 1) == channelNumberString.count {
                sendHTTP(keyName: keyString)
                sendHTTP(keyName: "KEY_OK")
            } else {
                sendHTTP(keyName: keyString)
            }
        }
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
