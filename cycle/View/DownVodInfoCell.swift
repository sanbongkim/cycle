//
//  DownVodInfoCell.swift
//  cycle
//
//  Created by SSG on 2021/01/04.
//

import Foundation
import UIKit

class DownVodInfoCell : UITableViewCell {
    
    @IBOutlet weak var thumbNail: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var palytime: UILabel!
    @IBOutlet weak var check:UIImageView!
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool){
        super.setSelected(selected, animated: animated)
        if selected == true {
        }
        
    }
    
}
