//
//  logoView.swift
//  cycle
//
//  Created by SSG on 2020/12/19.
//

import Foundation
import UIKit
class logoView : UIView{
    
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
}
