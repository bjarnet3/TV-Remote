//
//  SimpleTableCell.swift
//  TV Remote
//
//  Created by Bjarne Tvedten on 01/02/2020.
//  Copyright © 2020 Digital Mood. All rights reserved.
//

import UIKit

class SimpleTableCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func setupCell(title: String) {
        self.titleLabel.text = title
    }

}
