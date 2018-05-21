//
//  ViewController.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 21.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    /// **Hostname** followed by **.local** ie ( **family-iMac.local** )
    var hostname = "TV-Remote.local"
    var ipAddress = "192.168.10.120"
    var portNumber = "3000"
    var SSL: Bool = false
    
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

}

// MARK: - View Controller Lifecycle / View Did Load / Xib Implementations
// ----------------------------------------
extension ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
