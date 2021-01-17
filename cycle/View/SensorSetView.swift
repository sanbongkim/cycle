//
//  SensorSetView.swift
//  cycle
//
//  Created by SSG on 2021/01/17.
//

import UIKit

class SensorSetView: UIView {
    override init(frame: CGRect) {
       
        super.init(frame: frame)
        let nib = UINib(nibName: "logoView", bundle: Bundle.main)
        guard let xibView = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        xibView.frame = self.bounds
        self.addSubview(xibView)
    }
    required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
