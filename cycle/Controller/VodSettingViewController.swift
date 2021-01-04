//
//  VodSettingViewController.swift
//  cycle
//
//  Created by SSG on 2021/01/04.
import Foundation
import UIKit

class VodSettingViewController : UIViewController{
    var videoInfo = [InfoData]()
    
    @IBOutlet weak var vodlist: UITableView!
    @IBOutlet weak var vodcustom: UITableView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        vodlist.register(UINib(nibName: "DownVodInfoCell", bundle: nil), forCellReuseIdentifier: "DownVodInfoCell")
        vodlist.delegate = self
        vodlist.dataSource = self
        vodlist.tag = 0
       
        vodcustom.register(UINib(nibName: "UserVodInfoCell", bundle: nil), forCellReuseIdentifier: "UserVodInfoCell")
        vodcustom.delegate = self
        vodcustom.dataSource = self
        vodcustom.tag = 1
        
        videoInfo =  DatabaseManager.getInstance().selectDownLoaded()
        
        self.vodlist .reloadData()
    }
    @IBAction func backAction(_ sender: Any) {
        
    }
    @IBAction func tutorialAciton(_ sender: Any) {
        
    }
}
extension VodSettingViewController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return self.videoInfo.count
        }else{ return self.videoInfo.count }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DownVodInfoCell", for:indexPath) as! DownVodInfoCell
            let vodinfo = videoInfo[indexPath.row]
            cell.title.text = vodinfo.title
            cell.palytime.text = vodinfo.pay
            if let image = vodinfo.image{
                cell.thumbNail.image = Util.convertBase64StringToImage(imageBase64String:image)
            }
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserVodInfoCell", for:indexPath) as! UserVodInfoCell
            let vodinfo = videoInfo[indexPath.row]
            cell.title.text = vodinfo.title
            cell.palytime.text = vodinfo.pay
            if let image = vodinfo.image{
                cell.thumbNail.image = Util.convertBase64StringToImage(imageBase64String:image)
            }
            return cell
        }
    }
}
