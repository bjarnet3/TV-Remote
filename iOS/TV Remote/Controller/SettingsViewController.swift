//
//  ChannelsViewController.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 27.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ipTextField: UITextField!
    @IBOutlet weak var pinTextField: UITextField!

    var remoteHandler: RemoteHandler?
    var remoteCommands: [RemoteCommand]? = RemoteCommand.allCases.map({ $0 })

    // MARK: - View Load Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        getRemote()

        tableView.reloadData()
    }

    @IBAction func setRemote(_ sender: Any) {
        if let ip = ipTextField.text {
            UserDefaults.standard.set(ip, forKey: "ip")
        }
        if let pin = pinTextField.text {
            UserDefaults.standard.set(pin, forKey: "pin")
        }
    }

    @IBAction func testRemote(_ sender: Any) {
        getRemote()

        if let remoteHandler = remoteHandler {
            remoteHandler.send(command: .mute)
        }

    }

    @IBAction func send(_ sender: Any) {
        getRemote()

        if let remoteHandler = remoteHandler {
            remoteHandler.send()
        }
    }

    @IBAction func request(_ sender: Any) {
        getRemote()

        if let remoteHandler = remoteHandler {
            remoteHandler.request()
        }
    }



    func getRemote() {
        let ip = UserDefaults.standard.string(forKey: "ip") ?? "192.168.50.7"
        let pin = UserDefaults.standard.string(forKey: "pin") ?? "0000"

        ipTextField.text = ip
        pinTextField.text = pin
        
        let remote = Remote(name: "Sony TV", type: .smart, ip: ip, pin: pin)
        remoteHandler = RemoteHandler(remote: remote)
    }

}

// MARK: - TableView / Delegate / Data
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return remoteCommands?.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "simpleTableCell", for: indexPath) as? SimpleTableCell {

            guard let remoteCommand = remoteCommands?[indexPath.row] else { return SimpleTableCell() }

            cell.setupCell(title: remoteCommand.name)
            return cell
        } else {
            return SimpleTableCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let remote = self.remoteHandler
            else { return }

        guard let remoteCommand = remoteCommands?[indexPath.row]
            else { return }

        remote.send(command: remoteCommand)
        hapticButton(.selection)
    }

}

extension SettingsViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }

}
