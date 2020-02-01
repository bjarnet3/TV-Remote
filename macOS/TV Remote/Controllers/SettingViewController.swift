//
//  ViewController.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 18.01.2018.
//  Copyright © 2018 Bjarne Tvedten. All rights reserved.
//

import Cocoa
import CoreWLAN
import MapKit
import NotificationCenter

enum Auto {
    case on
    case off
}

class SettingViewController: NSViewController, URLSessionDelegate, CLLocationManagerDelegate {
    
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
    
    @IBOutlet weak var locationLong: NSTextField!
    @IBOutlet weak var locationLat: NSTextField!
    
    @IBOutlet weak var remoteSelected: NSSegmentedControl!
    
    // MARK: - Properties: Array and Varables
    // ----------------------------------------
    private var remotes = [Remote]()
    private var channels: [String: Int] = [:]
    private var selected = [String: Int?]()
    private var automatic = true
    
    private var selectedRemote: Remote?
    private var locationManager = CLLocationManager()
    // private var coordinate: Coordinate?
    
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
            
            encodeRemotes()
            completeSettings()
            
            self.channelList.reloadData()
        }
    }
    
    @IBAction func removeChannel(_ sender: NSButton) {
        let channelNameTitle = channelName.stringValue
        self.channels.removeValue(forKey: channelNameTitle)
        self.remotes[self.remoteList.indexOfSelectedItem].remoteChannels = self.channels
        
        saveChannels()
        clearChannels()
        
        encodeRemotes()
        completeSettings()
        
        self.channelList.reloadData()
    }
    
    @IBAction func autoLocation(_ sender: NSSegmentedControl) {
        if sender.isSelected(forSegment: 1) {
            self.enableLocationServices()
            self.setSelected(index: nil)
            setAutomatic()
        } else {
            self.locationManager.stopUpdatingLocation()
            self.setSelected(index: self.remoteList.indexOfSelectedItem)
            setAutomatic()
        }
    }
    
    @IBAction func getLocation(_ sender: NSButton) {
        if let location = locationManager.location {
            self.locationLong.stringValue = String(location.coordinate.longitude)
            self.locationLat.stringValue = String(location.coordinate.latitude)
        }
    }
    
    // When remoteList changesValue
    @IBAction func remoteChanged(_ sender: NSPopUpButton) {
        self.locationManager.stopUpdatingLocation()
        self.remoteSelected.setSelected(true, forSegment: 0)
        
        let remoteIndex = remoteList.indexOfSelectedItem
        let remote = remotes[remoteIndex]
        
        self.setSelected(index: remoteIndex)
        self.selectedRemote = remote
        // Set Value On Remote
        self.nameTextField.stringValue = remote._remoteName
        
        setTextField(for: remote)
        setChannels(for: remote)
        setAutomatic()
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
        clearTextField()
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
    private func returnRemote() -> Remote {
        let remote = Remote(remoteName: self.nameTextField.stringValue,
                            remoteType: self.typeTextField.stringValue,
                            remoteCommands: nil,
                            remoteChannels: self.channels,
                            remoteSSID: self.ssidTextField.stringValue,
                            remoteHost: self.hostTextField.stringValue,
                            remoteIP: self.ipTextField.stringValue,
                            remotePort: self.portTextField.stringValue,
                            remoteLocation: returnCoordinate())
        return remote
    }
    
    private func setTextField(for remote: Remote) {
        self.ipTextField.stringValue = remote._remoteIP ?? ""
        self.portTextField.stringValue = remote._remotePort ?? ""
        self.ssidTextField.stringValue = remote._remoteSSID ?? ""
        self.nameTextField.stringValue = remote._remoteName
        self.typeTextField.stringValue = remote._remoteType
        self.hostTextField.stringValue = remote._remoteHost ?? ""
        
        self.locationLong.stringValue = ""
        self.locationLat.stringValue = ""
        
        self.selectedRemote = remote
        
        guard let location = remote._remoteLocation else { return }
        self.locationLong.stringValue = String(location.longitude)
        self.locationLat.stringValue = String(location.latitude)
    }
    
    private func clearTextField() {
        self.ipTextField.stringValue = ""
        self.portTextField.stringValue = ""
        self.ssidTextField.stringValue = ""
        self.nameTextField.stringValue = ""
        self.typeTextField.stringValue = ""
        self.hostTextField.stringValue = ""
        self.locationLong.stringValue = ""
        self.locationLat.stringValue = ""
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
    
    // Helper function in the end over all commands
    private func completeSettings() {
        remoteList.isTransparent = false
        remoteList.isEnabled = true
        
        clearTextField()
    }
    
    private func setRemote(index: Int) {
        self.remoteSelected.setSelected(true, forSegment: 0)
        self.remoteList.selectItem(at: index)
        
        let remote = remotes[index]
        self.selectedRemote = remote
        // Set Value On Remote
        self.nameTextField.stringValue = remote._remoteName
        
        setAutomatic()
        setTextField(for: remote)
        setChannels(for: remote)
    }
    
    private func setSelected(index: Int?) {
        guard let SSID = Network.instance.returnSSID() else { return }
        switch index {
        case nil:
            self.selected = [SSID:nil]
            encodeSelected()
        default:
            self.selected = [SSID:index!]
            encodeSelected()
        }
    }
    
    private func setAutomatic() {
        if remoteSelected.indexOfSelectedItem == 0 {
            self.automatic = false
            self.encodeAutomatic()
        } else {
            self.automatic = true
            self.encodeAutomatic()
        }
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
    
    private func encodeSelected() {
        let selected = self.selected
        UserDefaults.standard.set(selected, forKey: "selected")
        UserDefaults.standard.synchronize()
    }
    
    private func decodeSelected() {
        if let selected = UserDefaults.standard.value(forKey: "selected") as? [String:Int?] {
            self.selected = selected
        }
    }
    
    private func encodeAutomatic() {
        let automatic = self.automatic
        UserDefaults.standard.set(automatic, forKey: "automatic")
        UserDefaults.standard.synchronize()
    }
    
    private func decodeAutomatic() {
        let automatic = UserDefaults.standard.bool(forKey: "automatic")
        self.automatic = automatic

    }

    // MARK: - ViewDidLoad, ViewWillLoad etc...
    // ----------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.channelList.addItems(withObjectValues: channels)
        channelList.delegate = self
        channelList.dataSource = self
        
        self.decodeRemotes()
        self.decodeSelected()
        self.decodeAutomatic()
        
        self.setupSelected()
    }
    
    private func setupSelected() {
        if let SSID = Network.instance.returnSSID() {
            print(automatic)
            if automatic {
                self.enableLocationServices()
            } else {
                if let selected = selected[SSID] {
                    if let index = selected {
                        setRemote(index: index)
                    }
                }
            }
        }
    }

    // ---------------------------
    private func returnCoordinate() -> Coordinate? {
        if let long = Double(self.locationLong.stringValue), self.locationLong.stringValue != "" {
            if let lat = Double(self.locationLat.stringValue), self.locationLat.stringValue != "" {
                let coordinate = Coordinate(Address: "", Room: "", latitude: lat, longitude: long)
                return coordinate
            }
        }
        return nil
    }

    private func enableLocationServices() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        setAutomatic()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print(location)
            /*
            if let selectedLocationDistance = self.remotes[self.remoteList.indexOfSelectedItem].returnLocationDistance(fromLocation: location) {
                for (idx, remote) in remotes.enumerated() {
                    if let remoteReturnDistance = remote.returnLocationDistance(fromLocation: location) {
                        if remoteReturnDistance < selectedLocationDistance {
                            self.remoteList.selectItem(at: idx)
                            
                            let remote = remotes[remoteList.indexOfSelectedItem]
                            self.selectedRemote = remote
                            // Set Value On Remote
                            self.nameTextField.stringValue = remote._remoteName
                            
                            setTextField(for: remote)
                            setChannels(for: remote)
                        }
                    }
                }
            }
            */
        }
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
        let values = channels.values
        for (idx, name) in keys.enumerated() {
            if idx == index {
                for (id, channel) in values.enumerated() {
                    if id == idx {
                        self.channelName.stringValue = name
                        self.channelNumber.stringValue = "\(channel)"
                        return name as Any
                    }
                }
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

extension SettingViewController {
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
        
        let remote1 = Remote(remoteName: "TV Remote", remoteType: "Samsung_AH59", remoteCommands: nil, remoteChannels: allChannels, remoteSSID: "Skuteviken", remoteHost: "TV-Remote.local", remoteIP: "192.168.10.120", remotePort: "3000", remoteLocation: nil)
        self.remotes.append(remote1)
        self.remoteList.addItem(withTitle: remote1.remoteName)
    }
}
