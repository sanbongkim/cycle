//
//  SensorSettingHelpViewController.swift
//  cycle
//
//  Created by SSG on 2021/02/15.
//

import Foundation
import UIKit
class SensorSettingHelpViewController: UIViewController{
    

    @IBOutlet weak var cabStartButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var countLabel: UILabel!
    
    @IBOutlet weak var typeButton1: UIButton!
    @IBOutlet weak var typeButton2: UIButton!
    @IBOutlet weak var typeButton3: UIButton!
    @IBOutlet weak var typeButton4: UIButton!
    
    
    override func viewDidLoad() {
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: "locationNoti"),object:"",userInfo: ["notivalue" : 1000])
        super.viewDidLoad()
    }
    @IBAction func backAction(_ sender: Any) {
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: "locationNoti"),object:"",userInfo: ["notivalue" : 2000])
        self.dismiss(animated: false, completion: {
        })
    }
    @IBAction func cabStartAction(_ sender: Any) {
        
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: "locationNoti"),object:"",userInfo: ["notivalue" : 100])
    }
    @IBAction func type1Action(_ sender: Any) {
        
        let button = sender as! UIButton
        typeButton1.backgroundColor = !button.isSelected ? UIColor.systemYellow : UIColor.white
        typeButton1.isSelected = !button.isSelected
        typeButton2.isSelected = false
        typeButton2.backgroundColor = .white
        typeButton3.isSelected = false
        typeButton3.backgroundColor = .white
        typeButton4.isSelected = false
        typeButton4.backgroundColor = .white
        
        
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: "locationNoti"),object:"",userInfo: ["notivalue" : 101])
    }
    @IBAction func type2(_ sender: Any) {
        let button = sender as! UIButton
        typeButton2.backgroundColor = !button.isSelected ? UIColor.systemYellow : UIColor.white
        typeButton2.isSelected = !button.isSelected
        typeButton1.isSelected = false
        typeButton1.backgroundColor = .white
        typeButton3.isSelected = false
        typeButton3.backgroundColor = .white
        typeButton4.isSelected = false
        typeButton4.backgroundColor = .white
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: "locationNoti"),object:"",userInfo: ["notivalue" : 102])
    }
    @IBAction func type3(_ sender: Any) {
        let button = sender as! UIButton
        typeButton3.backgroundColor = !button.isSelected ? UIColor.systemYellow : UIColor.white
        typeButton3.isSelected = !button.isSelected
        typeButton1.isSelected = false
        typeButton1.backgroundColor = .white
        typeButton2.isSelected = false
        typeButton2.backgroundColor = .white
        typeButton4.isSelected = false
        typeButton4.backgroundColor = .white
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: "locationNoti"),object:"",userInfo: ["notivalue" : 103])
    }
    @IBAction func type4(_ sender: Any) {
        let button = sender as! UIButton
        typeButton4.backgroundColor = !button.isSelected ? UIColor.systemYellow : UIColor.white
        typeButton4.isSelected = !button.isSelected
        typeButton1.isSelected = false
        typeButton1.backgroundColor = .white
        typeButton2.isSelected = false
        typeButton2.backgroundColor = .white
        typeButton3.isSelected = false
        typeButton3.backgroundColor = .white
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: "locationNoti"),object:"",userInfo: ["notivalue" : 104])
    }
    @IBAction func startButton(_ sender: Any) {
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: "locationNoti"),object:"",userInfo: ["notivalue" : 105])
    }
}

