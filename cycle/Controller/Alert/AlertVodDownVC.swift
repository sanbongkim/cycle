//
//  AlertVodDownVC.swift
//  cycle
//
//  Created by SSG on 2020/12/15.
//

import Foundation
import UIKit

enum resolution{
    
    case low,middle,high
}

class AlertVodDownVC : UIViewController{
    @IBOutlet weak var close: UIButton!
    @IBOutlet weak var downloadPercent: UILabel!
    @IBOutlet weak var message: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func cancelAciton(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
}
@IBDesignable extension UIButton {

    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = self.frame.height / newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
