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
    
    @IBOutlet weak var channelNumber: NSTextField!
    @IBOutlet weak var channelName: NSTextField!
    
    // Channel & Remote list
    @IBOutlet weak var channelList: NSComboBox!
    @IBOutlet weak var remoteList: NSPopUpButton!
    
    @IBAction func addChannel(_ sender: NSButton) {
        
        let channelNumberTitle = channelNumber.stringValue
        let channelNameTitle = channelName.stringValue
        
        if let channelNumberInt = Int(channelNumberTitle) {
            // channels = [channelNameTitle:channelNumberInt]
            channels.updateValue(channelNumberInt, forKey: channelNameTitle)
            setChannels()
        }
    }
    
    @IBAction func resetChannel(_ sender: NSButton) {
        channels = [
            "NRK":1,
            "NRK2":2,
            "TV2":3,
            "TVNorge": 4,
            "TV3":5,
            
            "TV2 Zebra":7,
            
            "Viasat 4": 9,
            "Fem": 10,
            "BBC Brit": 11,
            "Nyhetskanalen":12,
            
            "MAX":14,
            "VOX":15,
            "Discovery": 16,
            "TLC Norge": 17,
            "Fox": 18,
            
            "National Geographics": 20,
            "History": 21,
            
            "TV6": 37,
            "BBC World": 38
        ]
    }
    
    var channels: [String: Int] = [:]
    
    func setChannels() {
        UserDefaults(suiteName: "group.no.digitalmood.TV-Remote")?.set(self.channels, forKey: "channels")
        UserDefaults(suiteName: "group.no.digitalmood.TV-Remote")?.synchronize()
        clearChannels()
    }
    
    func getChannels() {
        if let channels = UserDefaults(suiteName: "group.no.digitalmood.TV-Remote")?.dictionary(forKey: "channels") as? [String: Int] {
            self.channels = channels
        }
    }
    
    func clearChannels() {
        channelNumber.stringValue = ""
        channelName.stringValue = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let SSIDs = currentSSIDs()
        for SSID in SSIDs {
            print(SSID)
        }
        
        // self.channelList.addItems(withObjectValues: channels)
        channelList.delegate = self
        channelList.dataSource = self
        
        getChannels()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

// NETWORK
// -------
extension ViewController {
    
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
    // Probably iOS
    /*
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
}

// MARK: - EXTENSIONS / COMBOBOX / DELEGATES / DATASOURCES
// ---------------------------------------------------------------------------------------------------------
// Thanx to https://github.com/creekpld/ComboBoxExample/blob/master/ComboBoxExample/ComboBoxDataSource.swift
// ---------------------------------------------------------------------------------------------------------
extension ViewController : NSComboBoxDelegate, NSComboBoxDataSource, NSComboBoxCellDataSource {
    // Standard Table / List implementation
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return channels.count
    }
    
    // Same as Cell For Row at indexPath
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        let keys = channels.keys
        for (idx, key) in keys.enumerated() {
            if idx == index {
                print("objectValueForItemAt")
                // let cell = comboBox.cell as! CustomComboCell
                // cell.image = NSImage(imageLiteralResourceName: "tv2-norge")
                // cell.title = key
                return key as Any
            }
        }
        print("objectValueForItemAt emtpty")
        return "" as Any
    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        var row = comboBox.indexOfSelectedItem
        let keys = channels.keys
        for (idx, key) in keys.enumerated() {
            if key == string {
                row = idx
                if let channel = channels[key] {
                    print("indexOfItemWithStringValue \(channel)")
                    return row
                }
            }
        }
        return -1
    }
    
    /*
    func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
        for (key,_) in channels {
            // substring must have less characters then stings to search
            if string.count < key.count {
                // only use first part of the strings in the list with length of the search string
                let statePartialStr = key.lowercased()[key.lowercased().startIndex..<key.lowercased().index(key.lowercased().startIndex, offsetBy: string.count)]
                
                if statePartialStr.range(of: string.lowercased()) != nil {
                    print("SubString Match=\(string).")
                    return key
                }
            }
        }
        return ""
    }
    
    func comboBoxSelectionIsChanging(_ notification: Notification) {
        print("comboBoxSelectionIsChanging")
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        print("comboBoxSelectionDidChange")
    }
    
    func comboBoxWillDismiss(_ notification: Notification) {
        print("comboBoxWillDismiss")
        
        let selectedIndex = channelList.indexOfSelectedItem
        print("indexOfSelectedCell : \(selectedIndex)")
        
        if let comboValue = comboBox(self.channelList, objectValueForItemAt: selectedIndex) {
            if let comboString = comboValue as? String {
                if let channel = channels[comboString] {
                    print("returnChannel in comboWillDismiss")
                    self.returnChannel(from: channel)
                    self.channelList.selectText(comboValue)
                }
            }
        }
    }
    */
    
    func comboBoxWillPopUp(_ notification: Notification) {
        print("comboBoxWillPopUp")
    }
}
