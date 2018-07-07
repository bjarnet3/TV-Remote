//
//  ChannelsViewController.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 27.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit
import AudioToolbox

class ChannelsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var backView: UXView!
    @IBOutlet weak var remoteView: UXView!
    
    @IBOutlet weak var forceTouchView: ForceTouchView!
    
    // Testing out force Touch
    // -----------------------
    
    private let maxScaleFactor: CGFloat = 0.3 //the maximum scale of the visual feedback effect
    private let pressDurationBeforeFired = 0.5 //used when no force touch capability is available
    private let forcePercentageBeforeFired: CGFloat = 0.9 //used when force touch capability is available
    
    //create the needed layers
    private var feedbackLayer = CALayer()
    private var pinkLayer = CALayer()
    
    //this property with an observer highlights the view as long as it is pressed down
    private var pressed: Bool = false {
        willSet{
            pinkLayer.backgroundColor = newValue ? PINK_TABBAR_UNSELECTED.cgColor : PINK_TABBAR_SELECTED.cgColor
        }
    }
    
    private var longPressRecognizer: UILongPressGestureRecognizer?
    private var forceTouchRecognizer: ForceGestureRecognizer?
    private var timer: Timer!
    // -----------------------
    // -----------------------
    
    /// **Hostname** followed by **.local** ie ( **family-iMac.local** )
    private var hostname = "TV-Remote.local"
    private var ipAddress = "192.168.10.120"
    private var portNumber = "3000"
    private var SSL: Bool = false
    
    private var remoteIsHidden = true
    
    private var lastRemote: Remote?
    private var remotes: [Remote] = [
        Remote(remoteName: "Samsung", remoteType: "Samsung_AH59"),
        Remote(remoteName: "Sony", remoteType: "Sony")
    ]
    
    private var channels: [Channel] = [
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
            hapticButton(.medium)
        }
        dismissKeyboard()
    }

    @IBAction func showHideRemote(_ sender: UIButton) {
        if remoteIsHidden {
            hapticButton(.medium)
            // SHOW REMOTE
            UIView.animate(withDuration: 0.58, delay: 0.022, usingSpringWithDamping: 0.50, initialSpringVelocity: 0.34, options: .curveEaseOut, animations: {
                self.remoteView.frame = CGRect(x: 0, y: 347.0, width: 375.0, height: 320.0)
            })
            self.remoteIsHidden = false
        } else {
            hapticButton(.medium)
            // HIDE REMOTE
            UIView.animate(withDuration: 0.58, delay: 0.022, usingSpringWithDamping: 0.50, initialSpringVelocity: 0.34, options: .curveEaseOut, animations: {
                self.remoteView.frame = CGRect(x: 0, y: 575.0, width: 375.0, height: 92.0)
            })
            self.remoteIsHidden = true
        }
    }
    
    private func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: - FUNCTIONS:
    // ----------------------------------------
    // Remote Send Action
    private func returnChannelNumber(from: String) {
        for channel in channels {
            if channel._channelName == from {
                self.returnChannelString(from: channel._channelNumber)
            }
        }
    }
    
    private func returnChannelString(from: Int) {
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
    
    // Send IR signal to Server
    private func sendHTTP(keyName: String) {
        // get remoteType from remoteList
        let remote = self.remotes[0].remoteType // remotes[remoteList.title] else { return }
        
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
    
    // Settings & Setup
    private func getIPAddress(from: String) {
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
                        ipAddress = numAddress
                    }
                }
            }
        }
    }
    
    private func setProgress(progress: Float = 1.0, animated: Bool = true, alpha: CGFloat = 1.0) {
        if let progressView = self.progressView {
            if animated {
                progressView.setProgress(progress, animated: animated)
                UIView.animate(withDuration: 0.60, delay: 0.75, usingSpringWithDamping: 0.70, initialSpringVelocity: 0.3, options: .curveEaseOut, animations: {
                    progressView.alpha = alpha
                })
            } else {
                progressView.setProgress(progress, animated: animated)
                progressView.alpha = alpha
            }
        }
    }
    
    private func setupRemoteView() {
        self.remoteView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.remoteView.layer.cornerRadius = 26.0
        self.remoteView.layer.borderColor = UIColor.black.cgColor
        self.remoteView.layer.borderWidth = 0.75
        self.remoteView.layer.masksToBounds = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // NETWORK TESTING
        getIPAddress(from: hostname)
        setupRemoteView()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset.top = 40.0
        
        // Force Touch TESTING
        // -------------------
        if #available(iOS 9, *){
            
            if traitCollection.forceTouchCapability == .available{
                print("force touch capability on this device")
                forceTouchRecognizer = ForceGestureRecognizer(target: self, action: #selector(forceTouchAction(gesture:)))
                forceTouchView.addGestureRecognizer(forceTouchRecognizer!)
            }
            else {
                print("no force touch capability on this device")
                longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(gesture:)))
                longPressRecognizer!.minimumPressDuration = 0.0001
                forceTouchView.addGestureRecognizer(longPressRecognizer!)
            }
        }
        
        //give our layers rounded corners
        pinkLayer.cornerRadius = 20
        feedbackLayer.cornerRadius = 20
        
        //color our layers and make the feedbacklayer slightly transparant
        feedbackLayer.backgroundColor = PINK_TABBAR_SELECTED.cgColor
        pinkLayer.backgroundColor = PINK_TABBAR_SELECTED.cgColor
        feedbackLayer.opacity = 0.8
        
        //add a sublayer that acts as our 'normal' state layer and put the feebbacklayer behind this
        forceTouchView.layer.addSublayer(pinkLayer)
        forceTouchView.layer.insertSublayer(feedbackLayer, below: pinkLayer)
        

        
        // Force Touch TESTING
        // -------------------
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // observeMessagesOnce()
        self.tableView.alpha = 0
    }
    
    var i = 0
    @objc func tapped() {
        i += 1
        print("Running \(i)")
        
        switch i {
        case 1:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
        case 2:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
        case 3:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            
        case 4:
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
        case 5:
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
        case 6:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
        default:
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
            i = 0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setProgress(progress: 0.0, animated: false, alpha: 1.0)
        animateCellsWithProgress(in: self.tableView, true, progress: self.progressView, completion: {
            print("animateCellsWithProgress completion")
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 9, *){
            //3D touch capability changed, so react to this change accordingly
            if traitCollection.forceTouchCapability != previousTraitCollection?.forceTouchCapability {
                
                //3D touch capability is now turned on
                if traitCollection.forceTouchCapability == .available{
                    
                    if let ftr = forceTouchRecognizer{
                        //the recognizer already existed but was disabled. Enable it.
                        ftr.isEnabled = true
                    }
                    else {
                        //the app apparently started without 3D touch enabled, so the 3D touch gestureRecognizer was never initialized. Do this now.
                        forceTouchRecognizer = ForceGestureRecognizer(target: self, action: #selector(forceTouchAction(gesture:)))
                        forceTouchView.addGestureRecognizer(forceTouchRecognizer!)
                    }
                    //disable long press recognizer
                    if let lpr = longPressRecognizer { lpr.isEnabled = false }
                }
                    
                    //3D touch capability is now turned off.
                else {
                    
                    //the recognizer already existed but was disabled. Enable it
                    if let lpr = longPressRecognizer {
                        lpr.isEnabled = true
                    }
                    else{
                        //the app apparently started with 3D touch enabled, so the longPress gestureRecognizer was never initialized. Do this now.
                        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(gesture:)))
                        longPressRecognizer!.minimumPressDuration = 0.0001
                        forceTouchView.addGestureRecognizer(longPressRecognizer!)
                    }
                    //disable 3D touch recognizer
                    if let ftr = forceTouchRecognizer { ftr.isEnabled = false }
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pinkLayer.frame = forceTouchView.bounds
        feedbackLayer.frame = forceTouchView.bounds
    }
    
    // Long Press Action (objective-c)
    // -------------------------------
    @objc func longPressAction(gesture: UILongPressGestureRecognizer) {
        switch gesture.state{
        case .began:
            //start a timer when the user starts holding down on the view and call timerAction every 0.05 seconds
            timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(timerAction), userInfo: NSDate.timeIntervalSinceReferenceDate, repeats: true)
            pressed = true
            
        case .ended:
            //invalidate the timer when the user lifts off
            print("Long press ended")
            timer.invalidate()
            giveVisualFeedbackForPercentage(percentage: 0)
            pressed = false
        default: break
        }
    }
    
    // Force Touch Action (objective-c)
    // --------------------------------
    @objc func forceTouchAction(gesture: ForceGestureRecognizer) {
        //a force of 1 counts as 'normal' pressure. We only want visual feedback when the pressure is more than normal.
        print("force applied: \(gesture.forceValue)")
        if gesture.forceValue > 1{
            
            pressed = true
            let percentage = gesture.forceValue / gesture.maxValue
            print("percentage is \(percentage)")
            giveVisualFeedbackForPercentage(percentage: percentage)
            
            if percentage > forcePercentageBeforeFired{
                
                //give taptic feedback. Caution: this is a private API!
                AudioServicesPlaySystemSound(1520)
                
                //reset the visual state to normal condition and disable the gesture recognizer
                gesture.isEnabled = false
                giveVisualFeedbackForPercentage(percentage: 0)
                pressed = false
                
                //enable the gesture again for the 'next' round
                gesture.isEnabled = true
            }
        }
        
        if gesture.state == .ended{
            //reset the visual state to normal condition in case user lifts finger before hitting the force target
            giveVisualFeedbackForPercentage(percentage: 0)
            pressed = false
        }
    }
    
    // Timer Action
    // ------------
    @objc func timerAction() {
        if let startTimeInterval = timer.userInfo as? TimeInterval{
            
            let now = NSDate.timeIntervalSinceReferenceDate
            let secondsPassed = now - startTimeInterval
            let percentage = (secondsPassed / pressDurationBeforeFired)
            print("secondspassed: \(secondsPassed)")
            giveVisualFeedbackForPercentage(percentage: CGFloat(percentage))
            
            if percentage > 1 {
                giveVisualFeedbackForPercentage(percentage: 0)
                longPressRecognizer!.state = .ended
            }
        }
    }
    
    ///scales the feedbackLayer to a given percentage.
    private func giveVisualFeedbackForPercentage(percentage: CGFloat) {
        let scaleFactor = 1 + (percentage * maxScaleFactor)
        
        //feedbackLayer is a stored CALayer property
        feedbackLayer.transform = CATransform3DMakeScale(scaleFactor, scaleFactor, 1)
    }
}

extension ChannelsViewController: UITableViewDelegate, UITableViewDataSource {
    
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
