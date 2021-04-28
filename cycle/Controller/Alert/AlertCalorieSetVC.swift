//
//  AlertCarorieSetVC.swift
//  cycle
//
//  Created by SSG on 2021/01/17.
//

import Foundation
import UIKit
class AlertCalorieSetVC : UIViewController{
    
    @IBOutlet weak var sensorSet: UIButton!
    @IBOutlet weak var calorieSet: UIButton!
    @IBOutlet weak var sensorDel: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func sensorSetAction(_ sender: Any) {
        
        performSegue(withIdentifier: "segueCaribration", sender: nil)
    }
    @IBAction func calorieSetAction(_ sender: Any) {
        
    }
    @IBAction func sensorDelAction(_ sender: Any) {
        
    }
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueCaribration" {
            if let destiVC = segue.destination as? SensorSettingHelpViewController{
                self.present(destiVC, animated:false, completion: nil)
            }
        }
    }
}
