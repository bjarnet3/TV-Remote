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
    var selectedRemote: Remote?
    
    // MARK: - IBAction: Methods connected to UI
    // ----------------------------------------
    
    // ALL BUTTON ACTIONS except "Channel List"
    @IBAction func keyAction(_ sender: CustomButton) {
        let identifier = sender.alternateTitle
        if let remote = self.selectedRemote {
            remote.sendHTTP(keyName: identifier)
        }
        // sendHTTP(keyName: identifier)
    }
    
    @IBAction func setRemoteAction(_ sender: NSPopUpButton) {
        setRemote()
    }
    
    // MARK: - Functions, Database & Animation
    // ----------------------------------------
    func setRemote() {
        let index = remoteList.indexOfSelectedItem
        let remote = remotes[index]
        setChannels(for: remote)
        self.selectedRemote = remote
    }
    
    func setChannels(for remote: Remote) {
        if let channels = remote._remoteChannels {
            self.channels = channels
        }
    }
    
    // DecodeRemotes and Load in Remote View
    // -------------------------------
    func decodeRemotes() {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.channelList.addItems(withObjectValues: channels)
        channelList.delegate = self
        channelList.dataSource = self
        
        self.decodeRemotes()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
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
