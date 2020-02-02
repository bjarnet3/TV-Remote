//
//  ChannelsViewController.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 27.05.2018.
//  Copyright © 2018 Digital Mood. All rights reserved.
//

import UIKit

class TVViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    // MARK: - View Load Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // tableView.delegate = self
        // tableView.dataSource = self
    }

}

// MARK: - TableView / Delegate / Data
extension TVViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "simpleTableCell", for: indexPath) as? UITableViewCell {
            return cell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

}
