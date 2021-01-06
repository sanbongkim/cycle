//
//  LiveInfoCell.swift
//  daview
//
//  Created by ksb on 10/07/2019.
//  Copyright © 2019 ksb. All rights reserved.
//

import UIKit

class MusicSetCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var play: UIImageView!
    @IBOutlet weak var removeAnddownload: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var singer: UILabel!
    var isPlaying:Bool?
    override func awakeFromNib() {
        super.awakeFromNib()
        isPlaying=false
        // Initialization code
    }
}
