//
//  SensorSetView.swift
//  cycle
//
//  Created by SSG on 2021/01/17.
//

import UIKit

class AlertSensorSetViewVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func noAction(_sender:Any){
        
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func yesAction(_sender:Any){
        self.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func close(_sender:Any){
        
        self.dismiss(animated: true, completion: nil)
//        let customViewController = self.presentingViewController as? AlertCalorieSetVC
//        self.dismiss(animated: false) {
//           customViewController?.dismiss(animated: false, completion: nil)
//        }
    }
}
