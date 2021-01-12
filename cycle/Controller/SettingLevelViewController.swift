//
//  SettingLevelViewController.swift
//  Boxing
//
//  Created by altedge on 2020/07/11.
//  Copyright © 2020 mtome. All rights reserved.
import UIKit
class SettingLevelViewController : UIViewController{
    var sourceVc : ViewController? = nil
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var backButton: UIButton!
    var levelValue = [Int]()
//  var listValue =   ["목표펀치횟수는 350회 입니다.",
//                     "목표펀치횟수는 700회 입니다.",
//                     "목표펀치횟수는 1000회 입니다.",
//                     "목표펀치횟수는 1400회 입니다.",
//                     "목표펀치횟수는 2000회 입니다."]
    var listValue :[String] = []
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.tableView.backgroundColor = .clear
        //
        listValue.append(Util.localString(st:"goal1")+"\(levelValue[0]/60)"+Util.localString(st: "goal2"))
        listValue.append(Util.localString(st:"goal1")+"\(levelValue[1]/60)"+Util.localString(st: "goal2"))
        listValue.append(Util.localString(st:"goal1")+"\(levelValue[2]/60)"+Util.localString(st: "goal2"))
        listValue.append(Util.localString(st:"goal1")+"\(levelValue[3]/60)"+Util.localString(st: "goal2"))
        listValue.append(Util.localString(st:"goal1")+"\(levelValue[4]/60)"+Util.localString(st: "goal2"))
    }
    @IBAction func tabBackAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        if sourceVc != nil{
           sourceVc!.leveTextReflash()
        }
    }
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        if sourceVc != nil{
           sourceVc!.leveTextReflash()
        }
    }
}
extension SettingLevelViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listValue.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "levelCell", for: indexPath) as! SettingTableViewCell
        cell.levelTextView.text = listValue[indexPath.row]
        cell.levelButton.tag = indexPath.row
        switch indexPath.row {
         case 0:
            cell.levelButton.setTitle(Util.localString(st:"user_lvl1"), for: .normal) //titleLabel?.text = "\(indexPath.row)" + "단계"
           break
         case 1:
            cell.levelButton.setTitle(Util.localString(st:"user_lvl2"), for: .normal)
            break
         case 2:
            cell.levelButton.setTitle(Util.localString(st:"user_lvl3"), for: .normal)
            break
         case 3:
            cell.levelButton.setTitle(Util.localString(st:"user_lvl4"), for: .normal)
            break
         case 4:
            cell.levelButton.setTitle(Util.localString(st:"user_lvl5"), for: .normal)
            break
        default:
            break
        
        }
        cell.levelButton.addTarget(self, action: #selector(levelButtonAction), for: .touchUpInside)
        return cell
    }
    @objc func levelButtonAction(sender: UIButton){
        let button = sender
        switch button.tag {
            case 0:
                Util.Toast.show(message: Util.localString(st:"user_ex_level_1"), controller: self)
                UserDefaults.standard.set(levelValue[0], forKey: "level")
                break
            case 1:
                Util.Toast.show(message: Util.localString(st:"user_ex_level_2"), controller: self)
                UserDefaults.standard.set(levelValue[1], forKey: "level")
                break
            case 2:
                Util.Toast.show(message: Util.localString(st:"user_ex_level_3"), controller: self)
                UserDefaults.standard.set(levelValue[2], forKey: "level")
                break
            case 3:
                Util.Toast.show(message: Util.localString(st:"user_ex_level_4"), controller: self)
                UserDefaults.standard.set(levelValue[3], forKey: "level")
                break
            case 4:
                Util.Toast.show(message: Util.localString(st:"user_ex_level_5"), controller: self)
                UserDefaults.standard.set(levelValue[4], forKey: "level")
                break
            default:
                break
        }
        
    }
    
    
}
