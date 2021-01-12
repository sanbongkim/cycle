//
//  SettingTableViewCell.swift
//  Boxing
//
//  Created by altedge on 2020/07/16.
//  Copyright © 2020 mtome. All rights reserved.
//

import UIKit
//나리나리 개나리

class SettingTableViewCell: UITableViewCell {

    @IBOutlet weak var levelButton: UIButton!
    @IBOutlet weak var levelTextView: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
