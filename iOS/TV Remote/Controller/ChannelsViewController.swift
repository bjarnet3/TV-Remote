//
//  ChannelsViewController.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 27.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit
import AudioToolbox
import Alamofire

class ChannelsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var backView: UXView!
    @IBOutlet weak var remoteView: UXView!
    
    // Remote Button Outlets
    @IBOutlet weak var remoteUpButton: UIButton!
    @IBOutlet weak var remoteLeftButton: UIButton!
    @IBOutlet weak var remoteRightButton: UIButton!
    @IBOutlet weak var remoteDownButton: UIButton!
    @IBOutlet weak var remoteOKButton: UIButton!
    
    @IBOutlet weak var remotePowerButton: UIButton!
    @IBOutlet weak var remoteSourceButton: UIButton!
    @IBOutlet weak var remoteMinimizeButton: UIButton!

    @IBOutlet weak var remoteRedButton: UIButton!
    @IBOutlet weak var remoteGreenButton: UIButton!
    @IBOutlet weak var remoteYellowButton: UIButton!
    @IBOutlet weak var remoteBlueButton: UIButton!

    private var timer = Timer()

    private var remoteHandler: RemoteHandler?
    private var remoteIsHidden = true
    private let remoteViewTopHeight: CGFloat = 43.0
    private var remoteViewAnimationDistance: CGFloat {
        return remoteView.frame.height - remoteViewTopHeight - navigationBarHeight
    }

    private var scrollViewDraggingOffset: CGFloat = 0.0
    private var scrollViewDraggingDistance: CGFloat = 0.0

    private var scrollContentOffset : CGFloat = 0.0
    private var navigationBarHeight: CGFloat {
        return navigationController?.navigationBar.frame.height ?? 49.0
    }

    private var remotes: [Remote] = [
        Remote(name: "Samsung", type: .ir),
        Remote(name: "Sony", type: .smart, ip: "192.168.1.7", key: "0000")
    ]
    
    private var channels: [Channel] = [
        Channel(channelName: "TV2", channelNumber: 3, channelImageName: "tv2-norge.png", channelCategory: "Tabloid", channelURL: "www.tv2.no"),
        Channel(channelName: "TV2 Sport 1", channelNumber: 12, channelImageName: "tv2_sport1.png", channelCategory: "Sport", channelURL: "www.tv2.no"),
        Channel(channelName: "TV2 Sport 2", channelNumber: 13, channelImageName: "tv2_sport2.png", channelCategory: "Sport", channelURL: "www.tv2.no"),
        Channel(channelName: "Nyhetskanalen", channelNumber: 22, channelImageName: "tv2-nyhetskanalen.png", channelCategory: "Nyheter", channelURL: "www.tv2.no"),
        Channel(channelName: "TV2 Zebra", channelNumber: 7, channelImageName: "zebra.png", channelCategory: "Blogging", channelURL: "www.tv2.no"),
        Channel(channelName: "TV2 Livstil", channelNumber: 8, channelImageName: "tv2_livstil.png", channelCategory: "Blogging", channelURL: "www.tv2.no"),
        Channel(channelName: "NRK", channelNumber: 1, channelImageName: "nrk.png", channelCategory: "Propaganda", channelURL: "www.nrk.no"),
        Channel(channelName: "NRK2", channelNumber: 2, channelImageName: "nrk2.png", channelCategory: "Propaganda", channelURL: "www.nrk.no"),
        Channel(channelName: "TVNorge", channelNumber: 4, channelImageName: "tvnorge.png", channelCategory: "Tabloid", channelURL: "www.tvnorge.no"),
        Channel(channelName: "TV3", channelNumber: 5, channelImageName: "tv3.png", channelCategory: "Tabloid", channelURL: "www.tv3.no"),
        Channel(channelName: "NRK Super", channelNumber: 6, channelImageName: "nrk_super.png", channelCategory: "Propaganda", channelURL: "www.nrk.no"),
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
        Channel(channelName: "TV6", channelNumber: 19, channelImageName: "tv6.png", channelCategory: "Tabloid", channelURL: "www.tvnorge.no"),
        Channel(channelName: "BBC World News", channelNumber: 55, channelImageName: "bbcworld.png", channelCategory: "News", channelURL: "www.bbc.com"),

        Channel(channelName: "Viasport 1", channelNumber: 26, channelImageName: "viasport1.png", channelCategory: "Sport", channelURL: "www.bbc.com"),
        Channel(channelName: "Eurosport", channelNumber: 29, channelImageName: "eurosport.png", channelCategory: "Sport", channelURL: "www.bbc.com"),
        Channel(channelName: "Eurosport Norge", channelNumber: 30, channelImageName: "eurosport_n.png", channelCategory: "Sport", channelURL: "www.bbc.com"),

        Channel(channelName: "Disney Channel", channelNumber: 31, channelImageName: "disney.png", channelCategory: "Children", channelURL: "www.bbc.com"),
        Channel(channelName: "Disney Junior", channelNumber: 32, channelImageName: "disney_junior.png", channelCategory: "Children", channelURL: "www.bbc.com"),
        Channel(channelName: "SVT 1", channelNumber: 44, channelImageName: "svt.png", channelCategory: "News", channelURL: "www.bbc.com"),
        Channel(channelName: "TV2 Sport Premium", channelNumber: 81, channelImageName: "tv2_sport_premium.png", channelCategory: "Sport", channelURL: "www.tv2.no"),
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
        guard let remote = self.remoteHandler
            else {
                print("Unable to set remoteHandler")
            return
        }
        guard let keyString = sender.accessibilityIdentifier else {
            print("Unable to get sender.accessibilityIdentifier" )
            return
        }

        remote.send(keyString: keyString)
        hapticButton(.medium)
        dismissKeyboard()
    }

    @IBAction func showHideRemote(_ sender: UIButton) {
        remoteAnimation()
    }
    
    private func dismissKeyboard(dismissView: UIView? = nil) {
        if let dismissView = dismissView {
            dismissView.endEditing(true)
        } else {
            self.view.endEditing(true)
        }
    }
    
    // MARK: - Functions:
    // ----------------------------------------
    // Remote Send Action

    // MARK: - Setup Handler / View / Effects

    private func setupData() {
        self.channels = channels.sorted { $0._channelNumber < $1._channelNumber }
        let remote = Remote(name: "Sony Remote", type: .smart, ip: "192.168.1.7", key: "0000")
        self.remoteHandler = RemoteHandler(remote: remote)
    }

    private func setupView() {
        self.remoteView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.remoteView.layer.cornerRadius = 26.0
        self.remoteView.layer.borderColor = UIColor.darkGray.cgColor
        self.remoteView.layer.borderWidth = 0.55
        self.remoteView.layer.masksToBounds = true
        self.hideRemoteView(animated: false)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.68, execute: {
            self.showRemoteView()
        })
    }

    private func setupParallaxEffect() {
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
        addParallaxEffectOnView(self.progressView, 9)

        // Distance Very Far
        addParallaxEffectOnView(self.tableView, 2)
    }

    // MARK: - View Load Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupData()
        setupView()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset.top = 40.0
        tableView.contentInset.bottom = 20.0
        
        setupParallaxEffect()
        let sorted = channels.sorted { $0._channelName < $1._channelName }
        
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
// MARK: - Animations & Effects
// --------------------------
extension ChannelsViewController {

    private func showRemoteView(animated: Bool = true) {
        // SHOW REMOTE
        // -----------
        if animated {
            UIView.animate(withDuration: 0.58, delay: 0.00, usingSpringWithDamping: 0.50, initialSpringVelocity: 0.34, options: .curveEaseOut, animations: {

                self.remoteView.transform = CGAffineTransform(translationX: 0, y: .zero)
                self.remoteView.layer.cornerRadius = 0
            })
            UIView.animate(withDuration: 0.71, delay: 0.034, usingSpringWithDamping: 0.50, initialSpringVelocity: 0.34, options: .curveEaseOut, animations: {
                self.postAnimation()
            })
        } else {
            self.remoteView.transform = CGAffineTransform(translationX: 0, y: .zero)
            self.remoteView.layer.cornerRadius = 0
            self.postAnimation()
        }
        self.remoteIsHidden = false
    }

    private func hideRemoteView(animated: Bool = true) {
        // HIDE REMOTE
        // -----------
        if animated {
            UIView.animate(withDuration: 0.50, delay: 0.00, usingSpringWithDamping: 0.52, initialSpringVelocity: 0.36, options: .curveEaseOut, animations: {
                self.preAnimation()
            })
            UIView.animate(withDuration: 0.65, delay: 0.024, usingSpringWithDamping: 0.55, initialSpringVelocity: 0.36, options: .curveEaseOut, animations: {

                self.remoteView.transform = CGAffineTransform(translationX: 0, y: self.remoteViewAnimationDistance)
                self.remoteView.layer.cornerRadius = 26
            })
        } else {
            self.preAnimation()
            self.remoteView.transform = CGAffineTransform(translationX: 0, y: remoteViewAnimationDistance)
            self.remoteView.layer.cornerRadius = 26
        }
        self.remoteIsHidden = true
    }
    
    private func remoteAnimation() {
        if remoteIsHidden {
            hapticButton(.medium)
            showRemoteView()
        } else {
            hapticButton(.medium)
            hideRemoteView()
        }
    }
    
    private func preAnimation() {
        self.remoteOKButton.alpha = 0.2
        self.remoteLeftButton.alpha = 0.2
        self.remoteRightButton.alpha = 0.2
        self.remoteUpButton.alpha = 0.2
        self.remoteDownButton.alpha = 0.2
        
        self.remotePowerButton.alpha = 0.65
        self.remoteSourceButton.alpha = 0.65
        self.remoteMinimizeButton.alpha = 0.65
        
        self.remoteOKButton.transform = CGAffineTransform(scaleX: 0.53, y: 0.53)
        self.remoteLeftButton.transform = CGAffineTransform(scaleX: 0.53, y: 0.53)
        self.remoteRightButton.transform = CGAffineTransform(scaleX: 0.53, y: 0.53)
        self.remoteUpButton.transform = CGAffineTransform(scaleX: 0.53, y: 0.53)
        self.remoteDownButton.transform = CGAffineTransform(scaleX: 0.53, y: 0.53)
        
        // self.remotePowerButton.transform = CGAffineTransform(scaleX: 0.53, y: 0.53)
        // self.remoteSourceButton.transform = CGAffineTransform(scaleX: 0.53, y: 0.53)
    }
    
    private func postAnimation() {
        self.remoteOKButton.alpha = 1.0
        self.remoteLeftButton.alpha = 1.0
        self.remoteRightButton.alpha = 1.0
        self.remoteUpButton.alpha = 1.0
        self.remoteDownButton.alpha = 1.0
        
        self.remotePowerButton.alpha = 0.65
        self.remoteSourceButton.alpha = 0.65
        self.remoteMinimizeButton.alpha = 0.65
        
        self.remoteOKButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.remoteLeftButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.remoteRightButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.remoteUpButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.remoteDownButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        
        // self.remotePowerButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        // self.remoteSourceButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
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
}

// MARK: - ScrollView Delegate
extension ChannelsViewController: UIScrollViewDelegate {

    func setTimer(timeInterval: TimeInterval, completion: Completion? = nil) {
        self.timer = Timer.scheduledTimer(
            withTimeInterval: timeInterval, repeats: false, block: { time in
                completion?()
        })
    }

    func scrollViewDragging(_ scrollView: UIScrollView) {
        hapticButton(.medium)
        setTimer(timeInterval: 3.0, completion: {
            let distance = scrollView.contentOffset.y - self.scrollViewDraggingOffset
            guard
                scrollView.isDragging,
                distance > 160
                else {
                    return
            }
            self.showRemoteView()
            hapticButton(.success)
        })
    }

    func scrollViewDraggingUpdater(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            let distance = scrollView.contentOffset.y - self.scrollViewDraggingOffset
            scrollViewDraggingDistance = distance

            if distance > 180 || distance < -180 {
                hideRemoteView()
            }
        }
    }
    
    // Did Scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // scrollViewDraggingUpdater(scrollView)

        // hideWhenScrolling(scrollView.contentOffset.y)
        self.scrollContentOffset = scrollView.contentOffset.y
    }

    // Begin Decelerating
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewWillBeginDecelerating")
    }

    // End Decelerating
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
        self.scrollContentOffset = 0.0

        // Drag down
        if scrollView.contentOffset.y <= -80 {
            print("scrollViewDidEndDecelerating and -80 y. offset")
        }
    }

    // Begin Dragging
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.scrollContentOffset = 0.0
        self.scrollViewDraggingDistance = 0.0
        self.scrollViewDraggingOffset = scrollView.contentOffset.y
    }

    // End Draging
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y >= 180 {
            hideRemoteView(animated: true)
        }
        if scrollView.contentOffset.y <= -180 {
            hideRemoteView(animated: true)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("scrollViewDidEndScrollingAnimation")
    }
}

// MARK: - TableView / Delegate / Data
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

        guard let remote = self.remoteHandler else { return }
        let channelNumber = channels[indexPath.row]._channelNumber

        print("\(channelNumber)")
        remote.send(channelNumber: channelNumber)
    }

    
    
    // THE END OF TABLEVIEW DELEGATE EXTENSIONS
    // ----------------------------------------------------
    
}

// MARK: - Haptic Engine
extension ChannelsViewController {

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
}
