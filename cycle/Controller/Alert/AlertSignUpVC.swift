//
//  AlertSignUpVc.swift
//  cycle
//
//  Created by SSG on 2020/12/21.
//

import Foundation
import UIKit
class AlertSignUpVC: UIViewController{
    @IBOutlet weak var checkBox: UIImageView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var message: UILabel!
    var switcher : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        message.text = Util.localString(st: "signup_success")
        createGesture()
    }
    private func createGesture() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(tappedImageView))
        checkBox.addGestureRecognizer(tap)
    }
    @objc private func tappedImageView() {
        checkBox.isHighlighted = !switcher
            switcher = !switcher
    }
    @IBAction func goAction(_ sender: Any) {
        if switcher{
            self.view .removeFromSuperview()
            self.removeFromParent()
        }
    }
}


