//
//  TodayViewController.swift
//  TV Remote Extension
//
//  Created by Bjarne Tvedten on 18.01.2018.
//  Copyright © 2018 Bjarne Tvedten. All rights reserved.
//

import Cocoa
import CoreWLAN
import MapKit
import NotificationCenter

class TodayViewController: NSViewController, NCWidgetProviding, CLLocationManagerDelegate {
    
    // MARK: - IBOutlet: Connection to View "xib"
    // ----------------------------------------

    // Settings View and Button Outlets
    @IBOutlet weak var keySettingsView: NSView!
    @IBOutlet weak var networkSettingsView: NSView!
    
    // Channel & Remote list
    @IBOutlet weak var channelList: NSComboBox!
    @IBOutlet weak var remoteList: NSPopUpButton!
    
    @IBOutlet weak var setNetworkButton: NSButton!
    @IBOutlet weak var portField: NSTextField!
    @IBOutlet weak var ipAddressField: NSTextField!
    
    @IBOutlet weak var keyField: NSTextField!
    @IBOutlet weak var irCodeField: NSTextField!
    
    // Check Box Button in Settings View
    @IBOutlet weak var buttonHidden: NSButton!
    @IBOutlet weak var onButtonDown: NSButton!
    @IBOutlet weak var keyColorPopUp: NSPopUpButton!
    
    @IBOutlet weak var autoSelect: NSButton!
    
    // MARK: - PROPERTIES
    // ----------------------------------------
    private var lastSelectedButton: CustomButton?
    private var settingsActive = false

    private var remotes = [Remote]()
    private var channels: [String: Int] = [:]
    private var selected = [String: Int?]()
    private var automatic = true
    
    private var selectedRemote: Remote?
    private var locationManager = CLLocationManager()
    private var coordinate: Coordinate?

    private var keyColors = [0: nil, 1: NSColor.red, 2: NSColor.blue, 3: NSColor.green, 4: NSColor.yellow, 5: NSColor.purple, 6:NSColor.black, 7: NSColor.cyan, 8: NSColor.systemPink, 9: NSColor.white]
    
    // MARK: - IBAction:
    // --------------------------------------
    @IBAction func enableAutomatic(_ sender: NSButton) {
        if sender.state == .on {
            enableLocationServices()
            // locationManager.startUpdatingLocation()
            self.automatic = true
            self.encodeAutomatic()
        } else {
            locationManager.stopUpdatingLocation()
            self.automatic = false
            self.encodeAutomatic()
        }
    }
    
    @IBAction func hideKey(_ sender: NSButton) {
        lastSelectedButton?.state = sender.state
        lastSelectedButton?.isTransparent = sender.state == .on ? true : false
        lastSelectedButton?.isEnabled = true
    }
    
    // ALL BUTTON ACTIONS except "Channel List"
    @IBAction func keyAction(_ sender: CustomButton) {
        if !settingsActive {
            if !sender.isTransparent {
                if let remote = self.selectedRemote {
                    let identifier = sender.alternateTitle
                    remote.sendHTTP(keyName: identifier)
                    print(identifier)
                }
            }
        } else {
            lastSelectedButton?.isEnabled = true
            lastSelectedButton?.isTransparent = buttonHidden.state == .on
            // is Hidden CheckBox set to the state of the button
            buttonHidden.state = sender.isTransparent ? .on : .off
            // make button visable anyway
            sender.isEnabled = false
            sender.isTransparent = false
            // Textfields Strings
            keyField.stringValue = sender.title
            irCodeField.stringValue = sender.alternateTitle
            
            onButtonDown.state = sender.buttonDown ? .on : .off
            lastSelectedButton = sender
        }
    }
    
    // KEYBOARD ENTER in CHANNEL BOX
    @IBAction func enterAction(_ sender: NSComboBox) {
        //do whatever when the s key is pressed
        print("Enter key pressed")
        let channelString = channelList.stringValue
        if let channel = channels[channelString] {
            self.returnChannel(from: channel)
        }
    }
    
    // ENTER SETTING VIEW
    @IBAction func displaySettings(_ sender: NSButton) {
        sender.title = sender.title == "▣" ? "⿴" : "▣"
        
        settingsActive = !settingsActive
        
        lastSelectedButton?.isEnabled = true
        lastSelectedButton?.isTransparent = buttonHidden.state == .on

        lastSelectedButton = nil
        
        keySettingsView.isHidden = !(keySettingsView.isHidden)
        channelList.isHidden = !(channelList.isHidden)
        // fastClick.isHidden = !(fastClick.isHidden)
        
        portField.stringValue = ""
        ipAddressField.stringValue = ""
        
        keyField.stringValue = ""
        irCodeField.stringValue = ""
        setNetworkButton.title = "Get"
        
        ipAddressField.placeholderString = "  [ IP adresse ]"
        portField.placeholderString = "[ PORT ]"
    }
    
    // PORT AND IP - ValueChanged
    @IBAction func portIPValueChanged(_ sender: NSTextField) {
        if portField.stringValue.isEmpty && ipAddressField.stringValue.isEmpty {
                ipAddressField.placeholderString = "  [ IP adresse ]"
                portField.placeholderString = "[ PORT ]"
            self.setNetworkButton.title = "Get"
        } else {
            self.setNetworkButton.title = "Set"
        }
    }
    
    // PORT AND IP - Set / Get button
    @IBAction func setPortAndIP(_ sender: NSButton) {
        ipAddressField.isEnabled = true
        portField.isEnabled = true
        var remote = self.selectedRemote
            if sender.title == "Get" {
                ipAddressField.stringValue = remote?._remoteIP ?? ""
                portField.stringValue = remote?._remotePort ?? ""
                sender.title = "Set"
            } else {
                remote?.setIP(ipAdress: ipAddressField.stringValue)
                remote?.setPort(port: portField.stringValue)
                sender.title = "Get"
                ipAddressField.stringValue = ""
                portField.stringValue = ""
            }
        
    }
    
    // IR CODE AND KEY NAME - ValueChanged
    @IBAction func keyIRValueChanged(_ sender: NSTextField) {
        if lastSelectedButton == nil {
            keyField.placeholderString = "[ KEY ]"
            irCodeField.placeholderString = " KLIKK A BUTTON "
        } else {
            keyField.placeholderString = "[ KEY ]"
            irCodeField.placeholderString = "  [ ir code ] to be sent"
        }
    }
    
    // IR CODE AND KEY NAME - Set Button
    @IBAction func setKeyAndIRCode(_ sender: Any) {
        if settingsActive {
            lastSelectedButton?.alternateTitle = irCodeField.stringValue
            lastSelectedButton?.title = keyField.stringValue
            lastSelectedButton?.buttonDown = onButtonDown.state == .on
            
            // Remove value in textFields
            keyField.stringValue = ""
            irCodeField.stringValue = ""

            // lastSelectedButton?.layer?.backgroundColor = keyColors[keyColorSegment.indexOfSelectedItem]!
            lastSelectedButton?.backgroundColor = keyColors[keyColorPopUp.indexOfSelectedItem]!
            lastSelectedButton?.needsLayout = true
            
            lastSelectedButton?.isEnabled = true
            lastSelectedButton?.isTransparent = buttonHidden.state == .on
            
            saveChannels()
            getChannels()
        }
    }
    
    @IBAction func setRemoteAction(_ sender: NSPopUpButton) {
        setRemote(for: sender.indexOfSelectedItem)
        setSelected(index: sender.indexOfSelectedItem)
        
        locationManager.stopUpdatingLocation()
        self.autoSelect.state = .off
    }
    
    // MARK: - FUNCTIONS:
    // ----------------------------------------
    private func returnChannel(from: Int) {
        if let remote = self.selectedRemote {
            let channelNumberString = String(from)
            for (idx, channel) in channelNumberString.enumerated() {
                let keyString = "KEY_\(channel)"
                if (idx + 1) == channelNumberString.count {
                    remote.sendHTTP(keyName: keyString)
                    remote.sendHTTP(keyName: "KEY_ENTER")
                } else {
                    remote.sendHTTP(keyName: keyString)
                }
            }
        }
        
    }
    
    private func saveChannels() {
        UserDefaults(suiteName: "group.no.digitalmood.TV-Remote")?.set(self.channels, forKey: "channels")
        UserDefaults(suiteName: "group.no.digitalmood.TV-Remote")?.synchronize()
    }
    
    private func setChannels(for remote: Remote) {
        if let channels = remote._remoteChannels {
            self.channels = channels
        }
    }
    
    private func getChannels() {
        if let channels = UserDefaults(suiteName: "group.no.digitalmood.TV-Remote")?.dictionary(forKey: "channels") as? [String: Int] {
            self.channels = channels
        }
    }
    
    private func setValue(for remote: Remote) {
        setChannels(for: remote)
    }
    
    private func setRemote(for index: Int? = nil) {
        let index = index ?? remoteList.indexOfSelectedItem
        self.remoteList.selectItem(at: index)

        self.selectedRemote = remotes[index]
        remotes[index].setSelected(selected: true)
        
        // self.lastSelectedRemoteIndex = index
        remotes[index].setSelected(selected: false)
        
        setValue(for: remotes[index])
        encodeRemotes()
        
        self.setSelected(index: index)
        self.automatic = false
        
        encodeSelected()
        encodeAutomatic()
    }
    
    // EncodeRemotes and Save to UserDefaults
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
                }
            }
        }
    }
    
    // Local Storage With UserDefaults
    // ------------------------------
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
    
    // MARK: - View Controller Lifecycle / View Did Load / Xib Implementations
    // ----------------------------------------
    override func viewDidLoad() {
        channelList.delegate = self
        channelList.dataSource = self
        
        // New Setup
        // setupRemotes()
        self.remoteList.removeAllItems()
        self.remotes.removeAll()
        
        // self.decodeLocation()
        self.decodeRemotes()
        
        self.decodeSelected()
        self.decodeAutomatic()
        
        self.setupRemote()
    }
    
    private func setupRemote() {
        if self.automatic {
            self.autoSelect.state = .on
            self.enableLocationServices()
        } else {
            self.autoSelect.state = .off
            if let SSID = Network.instance.returnSSID() {
                if let selectedIndex = self.selected[SSID] {
                    if let index = selectedIndex {
                        self.setRemote(for: index)
                    }
                }
            }
        }
    }
    
    // LocationManager
    private func enableLocationServices() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print(location)
            if let selectedLocationDistance = self.remotes[self.remoteList.indexOfSelectedItem].returnLocationDistance(fromLocation: location) {
                for (idx, remote) in remotes.enumerated() {
                    if let remoteReturnDistance = remote.returnLocationDistance(fromLocation: location) {
                        if remoteReturnDistance < selectedLocationDistance {
                            setRemote(for: idx)
                        }
                    }
                }
            }
        }
    }
    
    override var nibName: NSNib.Name? {
        return NSNib.Name("TodayViewController")
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        print("widgetPerfomUpdate")
        // Update your data and prepare for a snapshot. Call completion handler when you are done
        // with NoData if nothing has changed or NewData if there is new data since the last
        // time we called you
        completionHandler(.noData)
    }
}

// MARK: - EXTENSIONS / COMBOBOX / DELEGATES / DATASOURCES
// ---------------------------------------------------------------------------------------------------------
// Thanx to https://github.com/creekpld/ComboBoxExample/blob/master/ComboBoxExample/ComboBoxDataSource.swift
// ---------------------------------------------------------------------------------------------------------
extension TodayViewController : NSComboBoxDelegate, NSComboBoxDataSource, NSComboBoxCellDataSource {
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
    
    func comboBoxWillPopUp(_ notification: Notification) {
        print("comboBoxWillPopUp")
    }
}
