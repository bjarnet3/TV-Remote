//
//  NetworkService.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 08.08.2018.
//  Copyright © 2018 Bjarne Tvedten. All rights reserved.
//

import Cocoa
import CoreWLAN

class Network {
    static let instance = Network()
    
    // https://forums.developer.apple.com/thread/50302
    func getSSID() -> [String] {
        let client = CWWiFiClient.shared()
        return client.interfaces()?.compactMap{ interface in
            return interface.ssid()
            } ?? []
    }
    
    func returnSSID() -> String? {
        return getSSID().first
    }
    
    func returnIPAddress(from: String) -> String? {
        // Instansiate host with "name"
        let host = CFHostCreateWithName(nil,from as CFString).takeRetainedValue()
        // Start resolution
        CFHostStartInfoResolution(host, .addresses, nil)
        // success is false
        var success: DarwinBoolean = false
        // get addresses from CFHostGetAddressing, and get the firstObject
        if let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray?,
            // Get last object // firstObject
            let theAddress = addresses.lastObject as? NSData {
            // Instansiate hostname
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            // Get host brain / engine
            if getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length),
                           &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                // Set Address as readable String from [CChar]
                let numAddress = String(cString: hostname)
                return numAddress
                // print(numAddress)
            }
        }
        return nil
    }

}
