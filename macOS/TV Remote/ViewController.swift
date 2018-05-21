//
//  ViewController.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 18.01.2018.
//  Copyright © 2018 Bjarne Tvedten. All rights reserved.
//

import Cocoa
import CoreWLAN

class ViewController: NSViewController, URLSessionDelegate {
    
    // LIST OF DEVICES / INTERFACES
    // https://stackoverflow.com/questions/25626117/how-to-get-ip-address-in-swift
    // Thank You
    func getIFAddresses() -> [String] {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        guard let firstAddr = ifaddr else { return [] }
        
        // For each interface ...
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            let addr = ptr.pointee.ifa_addr.pointee
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    
                    if (getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        let address = String(cString: hostname)
                        addresses.append(address)
                    }
                }
            }
        }
        freeifaddrs(ifaddr)
        return addresses
    }
    
    // Return IP address of WiFi interface (en1) as a String, or `nil`
    func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            
            // For each interface ...
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                let interface = ptr?.pointee
                
                // Check for IPv4 or IPv6 interface:
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                    
                    // Check interface name:
                    if String(cString: (interface?.ifa_name)!) == "en1" {
                        
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
        }
        freeifaddrs(ifaddr)
        return address
    }
    
    // https://stackoverflow.com/questions/25890533/how-can-i-get-a-real-ip-address-from-dns-query-in-swift
    // Thanx to Martin R (https://stackoverflow.com/users/1187415/martin-r)
    func getIPAddress(from: String) {
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
                print(numAddress)
            }
        }
    }
    
    // https://forums.developer.apple.com/thread/50302
    /* Probably iOS
    func currentSSID() -> [String] {
        guard let interfaceNames = CNCopySupportedInterfaces() as? [String] else {
            return []
        }
        return interfaceNames.flatMap { name in
            guard let info = CNCopyCurrentNetworkInfo(name as CFString) as? [String:AnyObject] else {
                return nil
            }
            guard let ssid = info[kCNNetworkInfoKeySSID as String] as? String else {
                return nil
            }
            return ssid
        }
    }
    */
    
    // https://forums.developer.apple.com/thread/50302
    func currentSSIDs() -> [String] {
        let client = CWWiFiClient.shared()
        return client.interfaces()?.compactMap{ interface in
            return interface.ssid()
            } ?? []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let SSIDs = currentSSIDs()
        for SSID in SSIDs {
            print(SSID)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}
