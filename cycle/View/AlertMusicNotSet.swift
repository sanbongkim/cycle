//
//  AlertMusicNotSet.swift
//  cycle
//
//  Created by SSG on 2020/12/15.
//

import SwiftUI

class AletMusicNotSet : UIView {
    override init(frame: CGRect) {
            super.init(frame: frame)

            let nib = UINib(nibName: "AlertMusicNotSet", bundle: Bundle.main)
            guard let xibView = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
            
            xibView.frame = self.bounds
            xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addSubview(xibView)

        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
}
