//
//  AlertVodDownVC.swift
//  cycle
//
//  Created by SSG on 2020/12/15.
//

import Foundation
import UIKit
class AlertVodDownVC : UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
