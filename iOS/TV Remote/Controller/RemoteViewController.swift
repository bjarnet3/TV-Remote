//
//  ViewController.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 21.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

public enum BasicCommands: String {
    case mute = "KEY_MUTE"
    case power = "KEY_POWER"
}

class RemoteViewController: UIViewController {
    
    // MARK: - IBOutlet: Connection to View "xib"
    // ----------------------------------------
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var remotePicker: UIPickerView!
    
    /// **Hostname** followed by **.local** ie ( **family-iMac.local** )
    var hostname = "TV-Remote.local"
    var ipAddress = "192.168.10.120"
    var portNumber = "3000"
    var SSL: Bool = false
    
    var remote = Remote(remoteName: "Samsung", remoteCommand: "Samsung_AH59")
    var remotes: [Remote] = [
        Remote(remoteName: "Samsung", remoteCommand: "Samsung_AH59"),
        Remote(remoteName: "Samsung 2", remoteCommand: "Samsung_AH59"),
        Remote(remoteName: "Sony", remoteCommand: "Sony AE3"),
    ]
    
    var channels: [Channel] = [
        Channel(channelName: "TV2", channelNumber: 3, channelImageName: "tv2-norge.png", channelCategory: "Tabloid", channelURL: "www.tv2.no"),
        Channel(channelName: "Nyhetskanalen", channelNumber: 12, channelImageName: "tv2-nyhetskanalen.png", channelCategory: "Nyheter", channelURL: "www.tv2.no"),
        Channel(channelName: "TV2 Zebra", channelNumber: 7, channelImageName: "zebra.png", channelCategory: "Blogging", channelURL: "www.tv2.no"),
        Channel(channelName: "NRK", channelNumber: 1, channelImageName: "nrk.png", channelCategory: "Propaganda", channelURL: "www.nrk.no"),
        Channel(channelName: "NRK2", channelNumber: 2, channelImageName: "nrk2.png", channelCategory: "Propaganda", channelURL: "www.nrk.no"),
        Channel(channelName: "TVNorge", channelNumber: 4, channelImageName: "tvnorge.png", channelCategory: "Tabloid", channelURL: "www.tvnorge.no"),
        Channel(channelName: "TV3", channelNumber: 5, channelImageName: "tv3.png", channelCategory: "Tabloid", channelURL: "www.tv3.no"),
        Channel(channelName: "Viasat 4", channelNumber: 9, channelImageName: "viasat4", channelCategory: "Tabloid", channelURL: "www.viasat.no"),
        Channel(channelName: "Fem", channelNumber: 10, channelImageName: "fem.png", channelCategory: "Tabloid", channelURL: "www.tvnorge.no"),
        Channel(channelName: "BBC Brit", channelNumber: 11, channelImageName: "bbcbrit.png", channelCategory: "Propaganda", channelURL: "www.bbc.com"),
        Channel(channelName: "MAX", channelNumber: 14, channelImageName: "max.png", channelCategory: "Tabloid", channelURL: "www.tvnorge.no"),
        Channel(channelName: "VOX", channelNumber: 15, channelImageName: "vox.png", channelCategory: "Tabloid", channelURL: "www.tvnorge.no"),
        Channel(channelName: "Discovery", channelNumber: 16, channelImageName: "discovery.png", channelCategory: "Science", channelURL: "www.discovery.com"),
        Channel(channelName: "TLC Norge", channelNumber: 17, channelImageName: "tlc.png", channelCategory: "Tabloid", channelURL: "www.tvnorge.no"),
        Channel(channelName: "Fox", channelNumber: 18, channelImageName: "fox.png", channelCategory: "Tabloid", channelURL: "www.fox.com"),
        Channel(channelName: "National Geographics", channelNumber: 20, channelImageName: "nationalgeo.png", channelCategory: "Nature", channelURL: "www.nationalgeographics.com"),
        Channel(channelName: "History", channelNumber: 21, channelImageName: "history.png", channelCategory: "History", channelURL: "www.historychannel.com"),
        Channel(channelName: "TV6", channelNumber: 37, channelImageName: "tv6.png", channelCategory: "Tabloid", channelURL: "www.tvnorge.no"),
        Channel(channelName: "BBC World", channelNumber: 38, channelImageName: "bbcworld.png", channelCategory: "News", channelURL: "www.bbc.com"),
    ]
    
    // MARK: - IBAction:
    // ----------------------------------------
    @IBAction func buttonAction(_ sender: UIButton) {
        if let keyName = sender.accessibilityIdentifier {
            sendHTTP(keyName: keyName)
        }
        dismissKeyboard()
    }
    
    @IBAction func buttonDownAction(_ sender: UIButton) {
        hapticButton(.medium)
    }
    
    // KEYBOARD
    @IBAction func touchedBackground(_ sender: Any) {
        // Dissmiss
        dismissKeyboard()
    }
    
    private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: - FUNCTIONS:
    // ----------------------------------------
    
    // Send IR signal to Server
    func sendHTTP(keyName: String) {
        // get remoteType from remoteList
        let remote = self.remote.remoteCommand // remotes[remoteList.title] else { return }
        
        // URL and HTTP POST Request
        // http://raspberrypi.local:3000/remotes/Samsung_AH59/KEY_POWER
        let secureUrl = URL(string: "https://\(self.ipAddress):3001/remotes/\(remote)/\(keyName)")!
        let unsecureUrl = URL(string: "http://\(self.ipAddress):\(self.portNumber)/remotes/\(remote)/\(keyName)")!
        
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
    
    // Remote Send Action
    func returnChannelNumber(from: String) {
        for channel in channels {
            if channel._channelName == from {
                self.returnChannelString(from: channel._channelNumber)
            }
        }
    }
    
    func returnChannelString(from: Int) {
        let channelNumberString = String(from)
        // Break up channelNumber into charaters
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
    
    // Settings & Setup
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
}

extension RemoteViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return remotes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return remotes[row].remoteName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.remote = remotes[row]
    }
}

extension RemoteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "channelTableCell", for: indexPath) as? ChannelTableCell {
            cell.setupView(channel: self.channels[indexPath.row])
            return cell
        } else {
            return ChannelTableCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let channelNumber = channels[indexPath.row]._channelNumber
        returnChannelString(from: channelNumber)
    }
    
}

// MARK: - View Controller Lifecycle / View Did Load / Xib Implementations
// ----------------------------------------
extension RemoteViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // NETWORK TESTING
        getIPAddress(from: hostname)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        remotePicker.delegate = self
        remotePicker.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
