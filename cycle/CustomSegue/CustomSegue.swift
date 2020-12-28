//
//  CustomSegue.swift
//  cycle
//
//  Created by SSG on 2020/12/28.
//

import Foundation
import UIKit

class CustomSegue : UIStoryboardSegue{
    
    override func perform() {
        if identifier == "voidListView" {
            let dvc = self.destination as! VodListController
            let ovc = self.source
            ovc.navigationController?.pushViewController(dvc, animated: false)
        }
        else{
            
            
        }
        
    }
}
