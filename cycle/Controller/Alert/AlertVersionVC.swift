//
//  AlertVersionVC.swift
//  cycle
//
//  Created by SSG on 2020/12/23.
//

import Foundation
import UIKit

class AlertVersionVC : UIViewController{
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var close: UIButton!
    override func viewDidLoad() {
        version.text =  "Version " + Util.getAppversion()
       
        super.viewDidLoad()
    }
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}
