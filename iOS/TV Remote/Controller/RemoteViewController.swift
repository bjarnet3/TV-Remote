//
//  ViewController.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 21.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class RemoteViewController: UIViewController {
    
    // MARK: - IBOutlet: Connection to View "xib"
    // ----------------------------------------
    @IBOutlet weak var channelsPicker: UIPickerView!
    
    /// **Hostname** followed by **.local** ie ( **family-iMac.local** )
    var hostname = "TV-Remote.local"
    var ipAddress = "192.168.10.120"
    var portNumber = "3000"
    var SSL: Bool = false
    
    var remotes = ["Samsung" : "Samsung_AH59"]
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
    
    // MARK: - IBAction:
    // ----------------------------------------
    @IBAction func buttonAction(_ sender: UIButton) {
        if let keyName = sender.accessibilityIdentifier {
            sendHTTP(keyName: keyName)
        }
    }
    
    @IBAction func buttonDownAction(_ sender: UIButton) {
        hapticButton(.medium)
    }
    
    // MARK: - FUNCTIONS:
    // ----------------------------------------
    
    // Send IR signal to Server
    func sendHTTP(keyName: String) {
        // get remoteType from remoteList
        let remote = "Samsung_AH59" // remotes[remoteList.title] else { return }
        
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
        if let channel = channels[from] {
            self.returnChannelString(from: channel)
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
        return channels.keys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(channels.keys)[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let channelNumber = Array(channels.values)[row]
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
        
        channelsPicker.delegate = self
        channelsPicker.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
