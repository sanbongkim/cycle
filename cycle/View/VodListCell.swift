//
//  VodListCell.swift
//  cycle
//
//  Created by SSG on 2020/12/26.
//

import Foundation
import UIKit

class VodListCell : UITableViewCell{
    
    @IBOutlet weak var thumNail: UIImageView!
    @IBOutlet weak var playTime: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var lowqul: UILabel!
    @IBOutlet weak var hiqul: UILabel!
    @IBOutlet weak var downhigh: UIButton!
    
    @IBOutlet weak var lowstack: UIStackView!
    @IBOutlet weak var downlow: UIButton!
    @IBOutlet weak var percent: UILabel!
    @IBOutlet weak var progressbar: UIProgressView!
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var highstack: UIStackView!
    
    @IBOutlet weak var playGame: UIButton!
    @IBOutlet weak var removeVideo: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       
    }
    
}
