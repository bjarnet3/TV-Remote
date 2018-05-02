//
//  TodayViewController.swift
//  TV Remote Extension
//
//  Created by Bjarne Tvedten on 18.01.2018.
//  Copyright © 2018 Bjarne Tvedten. All rights reserved.
//

import Cocoa
import NotificationCenter

class TodayViewController: NSViewController, NCWidgetProviding {
    
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
    
    // MARK: - PROPERTIES
    // ----------------------------------------
    var lastSelectedButton: CustomButton?
    var settingsActive = false

    /// **Hostname** followed by **.local** ie ( **family-iMac.local** )
    var hostname = "TV-Remote.local"
    var ipAddress = "192.168.10.120"
    var portNumber = "3000"
    var SSL: Bool = false
    // var selectedRemote = "Samsung_AH59"
    
    // Dictionary of channels,, just add name and channel number if you want more channels on the list
    var channels = [
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
    
    var remotes = ["Samsung" : "Samsung_AH59"]
    var keyColors = [0: nil, 1: NSColor.red, 2: NSColor.blue, 3: NSColor.green, 4: NSColor.yellow, 5: NSColor.purple, 6:NSColor.black, 7: NSColor.cyan, 8: NSColor.systemPink, 9: NSColor.white]
    
    // MARK: - IBAction:
    // ----------------------------------------
    
    @IBAction func hideKey(_ sender: NSButton) {
        lastSelectedButton?.state = sender.state
        lastSelectedButton?.isTransparent = sender.state == .on ? true : false
        lastSelectedButton?.isEnabled = true
    }
    
    // ALL BUTTON ACTIONS except "Channel List"
    @IBAction func keyAction(_ sender: CustomButton) {
        if !settingsActive {
            if !sender.isTransparent {
                let identifier = sender.alternateTitle
                sendHTTP(keyName: identifier)
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
            if self.ipAddress.isEmpty || self.portNumber.isEmpty {
                ipAddressField.placeholderString = "  [ IP adresse ]"
                portField.placeholderString = "[ PORT ]"
            }
            self.setNetworkButton.title = "Get"
        } else {
            self.setNetworkButton.title = "Set"
        }
    }
    
    // PORT AND IP - Set / Get button
    @IBAction func setPortAndIP(_ sender: NSButton) {
        ipAddressField.isEnabled = true
        portField.isEnabled = true
        if sender.title == "Get" {
            ipAddressField.stringValue = ipAddress
            portField.stringValue = portNumber
            sender.title = "Set"
        } else {
            self.ipAddress = ipAddressField.stringValue
            self.portNumber = portField.stringValue
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
            
            // If fastClick
            // Checked = action will run on [Button Down] else [Button Up]
            // Uncheck = action will run on [Button Up]
            
            lastSelectedButton?.buttonDown = onButtonDown.state == .on
            
            // Remove value in textFields
            keyField.stringValue = ""
            irCodeField.stringValue = ""

            // lastSelectedButton?.layer?.backgroundColor = keyColors[keyColorSegment.indexOfSelectedItem]!
            lastSelectedButton?.backgroundColor = keyColors[keyColorPopUp.indexOfSelectedItem]!
            lastSelectedButton?.needsLayout = true
            
            lastSelectedButton?.isEnabled = true
            lastSelectedButton?.isTransparent = buttonHidden.state == .on
        }
    }
    
    // MARK: - FUNCTIONS:
    // ----------------------------------------
    
    // Send IR signal to Server
    func sendHTTP(keyName: String) {
        // get remoteType from remoteList
        guard let remote = remotes[remoteList.title] else { return }
        
        // URL and HTTP POST Request
        // http://raspberrypi.local:3000/remotes/Samsung_AH59/KEY_POWER
        let secureUrl = URL(string: "https://\(self.ipAddress):3001/remotes/\(remote)/\(keyName)")!
        let unsecureUrl = URL(string: "http://\(self.ipAddress):\(self.portNumber)/remotes/\(remote)/\(keyName)")!
        
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
    
    func getIPAddress(from: String) {
        let host = CFHostCreateWithName(nil,from as CFString).takeRetainedValue()
        CFHostStartInfoResolution(host, .addresses, nil)
        
        var success: DarwinBoolean = false
        if let addresses = CFHostGetAddressing(host, &success)?.takeUnretainedValue() as NSArray? {
            for case let theAddress as NSData in addresses {

                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo(theAddress.bytes.assumingMemoryBound(to: sockaddr.self), socklen_t(theAddress.length),
                               &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 {
                    let numAddress = String(cString: hostname)
                    // Filter out IPV4
                    if numAddress.count == 14 {
                        self.ipAddress = numAddress
                        print(numAddress)
                    }
                }
            }
        }
    }
    
    // MARK: - View Controller Lifecycle / View Did Load / Xib Implementations
    // ----------------------------------------
    override func viewDidLoad() {
        // self.channelList.addItems(withObjectValues: channels)
        channelList.delegate = self
        channelList.dataSource = self
        
        // NETWORK TESTING
        getIPAddress(from: hostname)
        
        // SET BUTTON (TEST)
        setButtons()
        
        // REMOTE TESTING
        remoteList.removeAllItems()
        for key in remotes.keys {
            remoteList.addItem(withTitle: key)
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
