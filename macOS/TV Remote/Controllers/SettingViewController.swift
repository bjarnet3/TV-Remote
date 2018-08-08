//
//  ViewController.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 18.01.2018.
//  Copyright © 2018 Bjarne Tvedten. All rights reserved.
//

import Cocoa
import CoreWLAN
import NotificationCenter

class SettingViewController: NSViewController, URLSessionDelegate {
    
    // MARK: - IBOutlet: Connection to Storyboard
    // ----------------------------------------
    @IBOutlet weak var channelList: NSComboBox!
    @IBOutlet weak var channelNumber: NSTextField!
    @IBOutlet weak var channelName: NSTextField!
    @IBOutlet weak var remoteList: NSPopUpButton!
    
    @IBOutlet weak var ipTextField: NSTextField!
    @IBOutlet weak var portTextField: NSTextField!
    
    @IBOutlet weak var ssidTextField: NSTextField!
    @IBOutlet weak var hostTextField: NSTextField!
    
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var typeTextField: NSTextField!
    
    // MARK: - Properties: Array and Varables
    // ----------------------------------------
    private var remotes = [Remote]()
    private var channels: [String: Int] = [:]
    private var selectedRemote: Remote?
    
    // MARK: - IBAction: Methods connected to UI
    // ----------------------------------------
    @IBAction func addChannel(_ sender: NSButton) {
        let channelNumberTitle = channelNumber.stringValue
        let channelNameTitle = channelName.stringValue
        if let channelNumberInt = Int(channelNumberTitle) {

            self.channels.updateValue(channelNumberInt, forKey: channelNameTitle)
            self.remotes[self.remoteList.indexOfSelectedItem].remoteChannels = self.channels
            
            saveChannels()
            clearChannels()
            completeSettings()
        }
    }
    
    // When remoteList changesValue
    @IBAction func remoteChanged(_ sender: NSPopUpButton) {
        let remote = remotes[remoteList.indexOfSelectedItem]
        // Set Value On Remote
        self.nameTextField.stringValue = remote._remoteName
        
        setTextField(for: remote)
        setChannels(for: remote)
    }
    
    // Save and Load REMOTE
    // --------------------
    @IBAction func addRemote(_ sender: NSButton) {
        let remote = returnRemote()
        self.remotes.append(remote)
        self.remoteList.addItem(withTitle: remote.remoteName)
        
        completeSettings()
    }
    
    @IBAction func editRemote(_ sender: NSButton) {
        if remoteList.isTransparent {
            remoteList.isTransparent = false
            remoteList.isEnabled = true
        } else {
            remoteList.isTransparent = true
            remoteList.isEnabled = false
        }
    }
    
    @IBAction func saveRemote(_ sender: NSButton) {
        encodeRemotes()
        completeSettings()
    }

    @IBAction func clearRemote(_ sender: NSButton) {
        completeSettings()
    }
    
    @IBAction func deleteRemote(_ sender: Any) {
        let index = remoteList.indexOfSelectedItem
        self.remotes.remove(at: index)
        remoteList.removeItem(at: index)
        
        encodeRemotes()
    }
    
    @IBAction func resetRemote(_ sender: Any) {
        removeAllRemotes()
        self.decodeRemotes()
    }
    
    @IBAction func setupRemote(_ sender: NSButton) {
        setupTestRemotes()
    }
    
    // Network SSID & IP
    // -----------------
    @IBAction func getSSID(_ sender: NSButton) {
        getSSID()
    }
    
    @IBAction func getIP(_ sender: NSButton) {
        getIP()
    }
    // -----------------
    
    
    // MARK: - Functions, Database & Animation
    // ----------------------------------------
    private func setTextField(for remote: Remote) {
        self.ipTextField.stringValue = remote._remoteIP ?? ""
        self.portTextField.stringValue = remote._remotePort ?? ""
        self.ssidTextField.stringValue = remote._remoteSSID ?? ""
        self.nameTextField.stringValue = remote._remoteName
        self.typeTextField.stringValue = remote._remoteType
        self.hostTextField.stringValue = remote._remoteHost ?? ""
        
        self.selectedRemote = remote
    }
    
    private func returnRemote() -> Remote {
        let remote = Remote(remoteName: self.nameTextField.stringValue,
                            remoteType: self.typeTextField.stringValue,
                            remoteCommands: nil,
                            remoteChannels: self.channels,
                            remoteSSID: self.ssidTextField.stringValue,
                            remoteHost: self.hostTextField.stringValue,
                            remoteIP: self.ipTextField.stringValue,
                            remotePort: self.portTextField.stringValue)
        return remote
    }
    
    private func clearTextField() {
        self.ipTextField.stringValue = ""
        self.portTextField.stringValue = ""
        self.ssidTextField.stringValue = ""
        self.nameTextField.stringValue = ""
        self.typeTextField.stringValue = ""
        self.hostTextField.stringValue = ""
    }

    // CHANNELS
    // --------
    private func saveChannels() {
        UserDefaults(suiteName: "group.no.digitalmood.TV-Remote")?.set(self.channels, forKey: "channels")
        UserDefaults(suiteName: "group.no.digitalmood.TV-Remote")?.synchronize()
    }
    
    private func setChannels(for remote: Remote) {
        if let channels = remote._remoteChannels {
            self.channels = channels
        }
    }
    
    private func clearChannels() {
        channelNumber.stringValue = ""
        channelName.stringValue = ""
    }
    
    // SAVE REMOTE
    // -----------
    private func saveRemote(for remote: Remote) {
        if let encoded = try? JSONEncoder().encode(remote) {
            UserDefaults(suiteName: "group.no.digitalmood.TV-Remote")?.set(encoded, forKey: remote.remoteType)
            UserDefaults(suiteName: "group.no.digitalmood.TV-Remote")?.synchronize()
        }
    }
    
    private func removeAllRemotes() {
        self.remoteList.removeAllItems()
        self.remotes.removeAll()
        
        completeSettings()
    }
    
    private func completeSettings() {
        remoteList.isTransparent = false
        remoteList.isEnabled = true
        
        clearTextField()
    }
    
    // EncodeRemotes and Save to UserDefaults
    // --------------------------------------
    // https://stackoverflow.com/questions/44441223/encode-decode-array-of-types-conforming-to-protocol-with-jsonencoder
    private func encodeRemotes() {
        // Get SSID from Router
        guard let SSID = Network.instance.returnSSID() else { return }
        // Get array (remotes)
        // --------------------------
        let remotes = self.remotes
        
        // Save array and encode
        // --------------------------
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(remotes) {
            // Save to UserDefaults
            UserDefaults(suiteName: "group.no.digitalmood.TV-Remote")?.set(encoded, forKey: SSID)
            UserDefaults(suiteName: "group.no.digitalmood.TV-Remote")?.synchronize()
        }
    }
    
    // DecodeRemotes and Load in Remote View
    // -------------------------------
    private func decodeRemotes() {
        // Get SSID from Router
        guard let SSID = Network.instance.returnSSID() else { return }
        // Load data from UserDefaults
        // ---------------------------
        if let remoteData = UserDefaults(suiteName: "group.no.digitalmood.TV-Remote")?.value(forKey: SSID) as? Data {
            let decoder = JSONDecoder()
            if let loadRemotes = try? decoder.decode(Array.self, from: remoteData) as [Remote] {
                loadRemotes.forEach {
                    self.remotes.append($0)
                    self.remoteList.addItem(withTitle: $0.remoteName)
                    
                    print($0.remoteName)
                }
            }
        }
    }

    // Setup Test Remotes with channels connected
    // ------------------------------------------
    func setupTestRemotes() {
        let allChannels = [
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
        
        if let channels = UserDefaults(suiteName: "group.no.digitalmood.TV-Remote")?.dictionary(forKey: "channels") as? [String: Int] {
            let remote1 = Remote(remoteName: "TV Remote", remoteType: "Samsung_AH59", remoteCommands: nil, remoteChannels: allChannels, remoteSSID: "Skuteviken", remoteHost: "TV-Remote.local", remoteIP: "192.168.10.120", remotePort: "3000")
            self.remotes.append(remote1)
            self.remoteList.addItem(withTitle: remote1.remoteName)
        }
    }

    // MARK: - ViewDidLoad, ViewWillLoad etc...
    // ----------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.channelList.addItems(withObjectValues: channels)
        channelList.delegate = self
        channelList.dataSource = self
        
        self.decodeRemotes()
    }
    
    
}

// NETWORK
// -------
extension SettingViewController {

    func getSSID() {
        if let ssid = Network.instance.returnSSID() {
            ssidTextField.stringValue = ssid
        }
    }
    
    func getIP() {
        if let host = self.hostTextField.stringValue != "" ? self.hostTextField.stringValue : nil {
            if let ip = Network.instance.returnIPAddress(from: host) {
                self.ipTextField.stringValue = ip
            }
        }
    }
}

// MARK: - EXTENSIONS / COMBOBOX / DELEGATES / DATASOURCES
// ---------------------------------------------------------------------------------------------------------
// Thanx to https://github.com/creekpld/ComboBoxExample/blob/master/ComboBoxExample/ComboBoxDataSource.swift
// ---------------------------------------------------------------------------------------------------------
extension SettingViewController : NSComboBoxDelegate, NSComboBoxDataSource, NSComboBoxCellDataSource {
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

//: Decodable Extension
extension Decodable {
    static func decode(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}

//: Encodable Extension
extension Encodable {
    func encode() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(self)
    }
}
