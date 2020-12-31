//
//  AlertViewVodHelpVC.swift
//  cycle
//
//  Created by SSG on 2020/12/31.
//

import Foundation
import UIKit

class AletViewVodHelpVC:UIViewController{
    
    @IBOutlet weak var close: UIButton!
    @IBOutlet weak var message: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        message.text = Util.localString(st: "custom_vr_down_info")
        
    }
    @IBAction func closeAction(_ sender: Any) {
        self.view .removeFromSuperview()
        self.removeFromParent()
    }
}
