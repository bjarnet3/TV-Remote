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
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - IBAction:
    // ----------------------------------------
    
    private func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
