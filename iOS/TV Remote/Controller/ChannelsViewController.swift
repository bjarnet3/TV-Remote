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
    @IBOutlet weak var searchView: UISearchBar!
    
    // Remote Button Outlets
    @IBOutlet weak var remoteUpButton: UIButton!
    @IBOutlet weak var remoteLeftButton: UIButton!
    @IBOutlet weak var remoteRightButton: UIButton!
    @IBOutlet weak var remoteDownButton: UIButton!
    @IBOutlet weak var remoteOKButton: UIButton!
    
    @IBOutlet weak var remotePowerButton: UIButton!
    @IBOutlet weak var remoteSourceButton: UIButton!
    
    @IBOutlet weak var remoteRedButton: UIButton!
    @IBOutlet weak var remoteGreenButton: UIButton!
    @IBOutlet weak var remoteYellowButton: UIButton!
    @IBOutlet weak var remoteBlueButton: UIButton!
    
    /// **Hostname** followed by **.local** ie ( **family-iMac.local** )
    private var hostname = "TV-Remote.local"
    private var ipAddress = "192.168.10.120"
    private var portNumber = "3000"
    private var SSL: Bool = false
    
    private var remoteIsHidden = true
    
    private var scrollContentOffset : CGFloat = 0.0
    // private var downDistance: CGFloat = 0.0
    // private var upDistance : CGFloat = 0.0
    
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
    
    // Taptic & Haptic Support
    let feedbackGenerator: (notification: UINotificationFeedbackGenerator, impact: (light: UIImpactFeedbackGenerator, medium: UIImpactFeedbackGenerator, heavy: UIImpactFeedbackGenerator), selection: UISelectionFeedbackGenerator) = {
        return (notification: UINotificationFeedbackGenerator(), impact: (light: UIImpactFeedbackGenerator(style: .light), medium: UIImpactFeedbackGenerator(style: .medium), heavy: UIImpactFeedbackGenerator(style: .heavy)), selection: UISelectionFeedbackGenerator())
    }()
    
    // Taptic & Haptic Warning Messages
    let sections: [(title: String, options: [String])] = [
        ("Basic", ["Standard Vibration", "Alert Vibration"]),
        ("Taptic Engine", ["Peek", "Pop", "Cancelled", "Try Again", "Failed"]),
        ("Haptic Feedback - Notification", ["Success", "Warning", "Error"]),
        ("Haptic Feedback - Impact", ["Light", "Medium", "Heavy"]),
        ("Haptic Feedback - Selection", ["Selection"])
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
        remoteAnimation()
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
        tableView.contentInset.bottom = 20.0
        
        setParallaxEffectOnView()
        
        // Haptic and Taptic Engine Support
        print("UIDevice.current.platform: \(UIDevice.current.platform.rawValue)")
        print("UIDevice.current.hasTapticEngine: \(UIDevice.current.hasTapticEngine ? "true" : "false")")
        print("UIDevice.current.hasHapticFeedback: \(UIDevice.current.hasHapticFeedback ? "true" : "false")")
        if let feedbackSupportLevel = UIDevice.current.value(forKey: "_feedbackSupportLevel") as? Int {
            print("UIDevice.current _feedbackSupportLevel: \(feedbackSupportLevel)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // observeMessagesOnce()
        self.tableView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setProgress(progress: 0.0, animated: false, alpha: 1.0)
        animateCellsWithProgress(in: self.tableView, true, progress: self.progressView, completion: {
            print("animateCellsWithProgress completion")
        })
        prepareForFeedbackGenerator()
    }
    
    private func prepareForFeedbackGenerator() {
        // Wake up the haptic engine
        // "Informs self that it will likely receive events soon, so that it can ensure minimal latency for any feedback generated. Safe to call more than once before the generator receives an event, if events are still imminently possible."
        feedbackGenerator.selection.prepare()
        feedbackGenerator.notification.prepare()
        feedbackGenerator.impact.light.prepare()
        feedbackGenerator.impact.medium.prepare()
        feedbackGenerator.impact.heavy.prepare()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
// UI, UX, GFX and ANIMATIONS
// --------------------------
extension ChannelsViewController {
    
    private func setParallaxEffectOnView() {
        // Distance Close
        addParallaxEffectOnView(self.remoteUpButton, 22)
        addParallaxEffectOnView(self.remoteLeftButton, 22)
        addParallaxEffectOnView(self.remoteRightButton, 22)
        addParallaxEffectOnView(self.remoteDownButton, 22)
        addParallaxEffectOnView(self.remoteOKButton, 25)
        
        // Distance Middle
        addParallaxEffectOnView(self.remoteRedButton, 15)
        addParallaxEffectOnView(self.remoteGreenButton, 15)
        addParallaxEffectOnView(self.remoteYellowButton, 15)
        addParallaxEffectOnView(self.remoteBlueButton, 15)
        // Distance Far
        addParallaxEffectOnView(self.remoteView, 13)
        addParallaxEffectOnView(self.searchView, 13)
        addParallaxEffectOnView(self.progressView, 9)
        // Distance Very Far
        addParallaxEffectOnView(self.tableView, 2)
        // Distance Base
    }
    
    private func remoteAnimation() {
        if remoteIsHidden {
            hapticButton(.medium)
            // SHOW REMOTE
            // -----------
            UIView.animate(withDuration: 0.58, delay: 0.00, usingSpringWithDamping: 0.50, initialSpringVelocity: 0.34, options: .curveEaseOut, animations: {
                self.remoteView.frame = CGRect(x: 0, y: 337.0, width: 375.0, height: 330.0)
                self.remoteView.layer.cornerRadius = 0
            })
            UIView.animate(withDuration: 0.71, delay: 0.034, usingSpringWithDamping: 0.50, initialSpringVelocity: 0.34, options: .curveEaseOut, animations: {
                self.postAnimation()
            })
            self.remoteIsHidden = false
        } else {
            hapticButton(.medium)
            // HIDE REMOTE
            // -----------
            UIView.animate(withDuration: 0.50, delay: 0.00, usingSpringWithDamping: 0.52, initialSpringVelocity: 0.36, options: .curveEaseOut, animations: {
                self.preAnimation()
            })
            UIView.animate(withDuration: 0.65, delay: 0.024, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.36, options: .curveEaseOut, animations: {
                self.remoteView.frame = CGRect(x: 0, y: 576.0, width: 375.0, height: 92.0)
                self.remoteView.layer.cornerRadius = 26
            })
            self.remoteIsHidden = true
        }
    }
    
    private func preAnimation() {
        self.remoteOKButton.alpha = 0.2
        self.remoteLeftButton.alpha = 0.2
        self.remoteRightButton.alpha = 0.2
        self.remoteUpButton.alpha = 0.2
        self.remoteDownButton.alpha = 0.2
        
        self.remotePowerButton.alpha = 0.0
        self.remoteSourceButton.alpha = 0.0
        
        self.remoteOKButton.transform = CGAffineTransform(scaleX: 0.53, y: 0.53)
        self.remoteLeftButton.transform = CGAffineTransform(scaleX: 0.53, y: 0.53)
        self.remoteRightButton.transform = CGAffineTransform(scaleX: 0.53, y: 0.53)
        self.remoteUpButton.transform = CGAffineTransform(scaleX: 0.53, y: 0.53)
        self.remoteDownButton.transform = CGAffineTransform(scaleX: 0.53, y: 0.53)
        
        self.remotePowerButton.transform = CGAffineTransform(scaleX: 0.53, y: 0.53)
        self.remoteSourceButton.transform = CGAffineTransform(scaleX: 0.53, y: 0.53)
    }
    
    private func postAnimation() {
        self.remoteOKButton.alpha = 1.0
        self.remoteLeftButton.alpha = 1.0
        self.remoteRightButton.alpha = 1.0
        self.remoteUpButton.alpha = 1.0
        self.remoteDownButton.alpha = 1.0
        
        self.remotePowerButton.alpha = 1.0
        self.remoteSourceButton.alpha = 1.0
        
        self.remoteOKButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.remoteLeftButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.remoteRightButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.remoteUpButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.remoteDownButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        
        self.remotePowerButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.remoteSourceButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
}

extension ChannelsViewController: UIScrollViewDelegate {
    
    func returnScrollValue(with scrollOffset: CGFloat, valueOffset: CGFloat) -> CGFloat {
        let value = (((scrollOffset / 100)) / -1) - valueOffset
        
        let valueMin = value < 0.0 ? 0.0 : value
        let valueMax = value > 1.0 ? 1.0 : value
        
        let result = value < valueMin ? valueMin : valueMax
        print(result)
        
        return result
    }
    
    func hideWhenScrolling(_ scrollViewDistance: CGFloat) {
        print(scrollViewDistance)
        if !self.remoteIsHidden {
            if (350.0 < scrollViewDistance) {
                // move up
                self.remoteAnimation()
            } else if (-300 > scrollViewDistance) {
                // move down
                self.remoteAnimation()
            }
            
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.scrollContentOffset = 0.0
        print("scrollViewWillBeginDragging")
    }
    
    // Search for: scrollViewDidScroll UIVisualEffect
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // update the new position acquired
        hideWhenScrolling(scrollView.contentOffset.y)
        self.scrollContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        if scrollView.contentOffset.y <= -80 {
            print("scrollViewWillEndDragging: \(velocity) with -80 in offset ")
            
            
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("scrollViewDidEndDragging")
        print("decelerate: \(decelerate)")
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
            print("scrollViewWillBeginDecelerating")
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollContentOffset = 0.0
        
        // Drag down
        if scrollView.contentOffset.y <= -80 {
            print("scrollViewDidEndDecelerating and -80 y. offset")
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("scrollViewDidEndScrollingAnimation")
        
        
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
    
    // Prepared Haptic Feedback Implementation in TableView
    // ----------------------------------------------------
    func hapticTitle(in tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = sections[section].title
        
        let supported = " (SUPPORTED)"
        let unsupported = " (UNSUPPORTED)"
        switch section {
        case 0:
            // < iPhone 6S
            break
        case 1:
            // iPhone 6S Taptic Engine
            if UIDevice.current.hasTapticEngine {
                title.append(supported)
            } else {
                title.append(unsupported)
            }
        case 2, 3, 4:
            // iPhone 7 Haptic Feedback
            if UIDevice.current.hasHapticFeedback {
                title.append(supported)
            } else {
                title.append(unsupported)
            }
        default:
            break
        }
        return title
    }
    
    func hapticImplementation(in tableView: UITableView, indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            // < iPhone 6S
            switch indexPath.row {
            case 0:
                // Standard vibration
                let standard = SystemSoundID(kSystemSoundID_Vibrate) // 4095
                AudioServicesPlaySystemSoundWithCompletion(standard, {
                    print("did standard vibrate")
                })
            case 1:
                // Alert vibration
                let alert = SystemSoundID(1011)
                AudioServicesPlaySystemSoundWithCompletion(alert, {
                    print("did alert vibrate")
                })
            default:
                break
            }
        case 1:
            // iPhone 6S 1st Generation Taptic Engine
            switch indexPath.row {
            case 0:
                // Peek
                let peek = SystemSoundID(1519)
                AudioServicesPlaySystemSoundWithCompletion(peek, {
                    print("did peek")
                })
            case 1:
                // Pop
                let pop = SystemSoundID(1520)
                AudioServicesPlaySystemSoundWithCompletion(pop, {
                    print("did pop")
                })
            case 2:
                // Cancelled
                let cancelled = SystemSoundID(1521)
                AudioServicesPlaySystemSoundWithCompletion(cancelled, {
                    print("did cancelled")
                })
            case 3:
                // Try Again
                let tryAgain = SystemSoundID(1102)
                AudioServicesPlaySystemSoundWithCompletion(tryAgain, {
                    print("did try again")
                })
            case 4:
                // Failed
                let failed = SystemSoundID(1107)
                AudioServicesPlaySystemSoundWithCompletion(failed, {
                    print("did failed")
                })
            default:
                break
            }
        case 2:
            // UINotificationFeedbackGenerator
            switch indexPath.row {
            case 0:
                // Success
                feedbackGenerator.notification.notificationOccurred(.success)
            case 1:
                // Warning
                feedbackGenerator.notification.notificationOccurred(.warning)
            case 2:
                // Error
                feedbackGenerator.notification.notificationOccurred(.error)
            default:
                break
            }
        case 3:
            // UIImpactFeedbackGenerator
            switch indexPath.row {
            case 0:
                // Light
                feedbackGenerator.impact.light.impactOccurred()
            case 1:
                // Medium
                feedbackGenerator.impact.medium.impactOccurred()
            case 2:
                // Heavy
                feedbackGenerator.impact.heavy.impactOccurred()
            default:
                break
            }
        case 4:
            // UISelectionFeedbackGenerator
            switch indexPath.row {
            case 0:
                // Selection
                feedbackGenerator.selection.selectionChanged()
            default:
                break
            }
        default:
            break
        }
    }
    
    
    // THE END OF TABLEVIEW DELEGATE EXTENSIONS
    // ----------------------------------------------------
    
}
