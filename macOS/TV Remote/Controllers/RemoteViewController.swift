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
    
    // MARK: - Functions, Database & Animation
    // ----------------------------------------
    func setValue(for remote: Remote) {
        self.ip = remote._remoteIP ?? ""
        self.port = remote._remotePort ?? "3000"
        self.ssid = remote._remoteSSID ?? ""
        self.host = remote._remoteHost ?? ""
        
        self.remoteName = remote.remoteName
        self.remoteType = remote.remoteType

        setChannels(for: remote)
    }
    
    func setRemote() {
        let index = remoteList.indexOfSelectedItem
        setValue(for: remotes[index])
    }
    
    func setChannels(for remote: Remote) {
        if let channels = remote._remoteChannels {
            self.channels = channels
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
        setChannels(for: remoteAtIndex)
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
