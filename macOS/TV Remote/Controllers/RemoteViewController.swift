//
//  RemoteViewController.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 12.07.2018.
//  Copyright © 2018 Bjarne Tvedten. All rights reserved.
//

import Cocoa
import CoreWLAN
import NotificationCenter

class RemoteViewController: NSViewController, URLSessionDelegate {
    
    // MARK: - IBOutlet: Connection to Storyboard
    // ----------------------------------------
    @IBOutlet weak var channelList: NSComboBox!
    @IBOutlet weak var remoteList: NSPopUpButton!
    
    // MARK: - Properties: Array and Varables
    // ----------------------------------------
    var remotes = [Remote]()
    var channels: [String: Int] = [:]
    // var lastRemote: Remote?
    
    var ssid: String?
    var host: String?
    var ip: String?
    var port: String?
    var SSL: Bool = false
    
    var remoteName: String?
    var remoteType: String?
    
    // MARK: - IBAction: Methods connected to UI
    // ----------------------------------------
    
    // ALL BUTTON ACTIONS except "Channel List"
    @IBAction func keyAction(_ sender: CustomButton) {
        let identifier = sender.alternateTitle
        sendHTTP(keyName: identifier)
    }
    
    @IBAction func setRemoteAction(_ sender: NSPopUpButton) {
        setRemote()
    }

    func getSSID() {
        if let ssid = self.currentSSIDs().first {
            self.ssid = ssid
            // ssidTextField.stringValue = ssid
        }
    }
    
    func getIP() {
        if let host = self.host != "" ? self.host : nil {
            if let ip = returnIPAddress(from: host) {
                self.ip = ip
                // self.ipTextField.stringValue = ip
            }
        }
    }
    
    // MARK: - Functions, Database & Animation
    // ----------------------------------------
    func setValue(for remote: Remote) {
        self.ip = remote._remoteIP ?? ""
        self.port = remote._remotePort ?? "3000"
        self.ssid = remote._remoteSSID ?? ""
        self.host = remote._remoteHost ?? ""
        
        self.remoteName = remote.remoteName
        self.remoteType = remote.remoteType

        getChannels(from: remote)
    }
    
    func setRemote() {
        let index = remoteList.indexOfSelectedItem
        setValue(for: remotes[index])
    }
    
    func setChannels() {
        UserDefaults(suiteName: "group.no.digitalmood.TV-Remote")?.set(self.channels, forKey: "channels")
        UserDefaults(suiteName: "group.no.digitalmood.TV-Remote")?.synchronize()
    }
    
    func getChannels(from remote: Remote) {
        if let channels = remote._remoteChannels {
            self.channels = channels
        }
    }
    
    func loadRemoteValue(from remoteType: String) {
        if let remoteData = UserDefaults(suiteName: "group.no.digitalmood.TV-Remote")?.data(forKey: remoteType),
            let remote = try? JSONDecoder().decode(Remote.self, from: remoteData) {
            
            setValue(for: remote)
            dump(remote)
        }
    }
    
    // Send IR signal to Server
    func sendHTTP(keyName: String) {
        // get remoteType from remoteList
        guard let remote = self.remoteType else { return }
        guard let ip = self.ip else { return }
        // guard let host = self.host else { return }
        guard let port = self.port else { return }
        
        // URL and HTTP POST Request
        // http://raspberrypi.local:3000/remotes/Samsung_AH59/KEY_POWER
        let secureUrl = URL(string: "https://\(ip):\(port)/remotes/\(remote)/\(keyName)")!
        let unsecureUrl = URL(string: "http://\(ip):\(port)/remotes/\(remote)/\(keyName)")!
        
        print(unsecureUrl)
        print(secureUrl)
        
        // You can test with Curl in Terminal
        // curl -d POST http://192.168.10.120:3000/remotes/Samsung_AH59/KEY_MUTE (or raspberrypi.local:3000)
        
        let url = self.SSL ? secureUrl : unsecureUrl
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
    
    // DecodeRemotes and Load in Remote View
    // -------------------------------
    func decodeRemotes() {
        // Get SSID from Router
        guard let SSID = returnCurrentSSID() else { return }
        self.ssid = SSID
        // Load data from UserDefaults
        // ---------------------------
        if let remoteData = UserDefaults(suiteName: "group.no.digitalmood.TV-Remote")?.value(forKey: SSID) as? Data {
            let decoder = JSONDecoder()
            if let loadRemotes = try? decoder.decode(Array.self, from: remoteData) as [Remote] {
                loadRemotes.forEach {
                    self.remotes.append($0)
                    self.remoteList.addItem(withTitle: $0.remoteName)
                }
            }
        }
    }
    
    // Setup Test Remotes with channels connected
    // ------------------------------------------
    func setupTestRemotes() {
        for remote in self.remotes {
            self.remoteList.addItem(withTitle: remote.remoteName)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.channelList.addItems(withObjectValues: channels)
        channelList.delegate = self
        channelList.dataSource = self
        
        // New Setup
        // setupRemotes()
        self.remoteList.removeAllItems()
        self.remotes.removeAll()
        
        self.decodeRemotes()
        
        let remoteAtIndex = self.remotes[self.remoteList.indexOfSelectedItem]
        getChannels(from: remoteAtIndex)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
}

// NETWORK
// -------
extension RemoteViewController {
    
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
    
    // https://forums.developer.apple.com/thread/50302
    func currentSSIDs() -> [String] {
        let client = CWWiFiClient.shared()
        return client.interfaces()?.compactMap{ interface in
            return interface.ssid()
            } ?? []
    }
    
    func returnCurrentSSID() -> String? {
        return currentSSIDs().first
    }
}

extension RemoteViewController : NSComboBoxDelegate, NSComboBoxDataSource, NSComboBoxCellDataSource {
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
    
    func comboBoxWillPopUp(_ notification: Notification) {
        print("comboBoxWillPopUp")
    }
}
