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
    override func viewDidLoad() {
        
        super.viewDidLoad()
        vodlist.register(UINib(nibName: "DownVodInfoCell", bundle: nil), forCellReuseIdentifier: "DownVodInfoCell")
        vodlist.delegate = self
        vodlist.dataSource = self
        vodlist.tag = 0
        videoInfo =  DatabaseManager.getInstance().selectDownLoaded()
        self.vodlist .reloadData()
    }
    @IBAction func backAction(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
    }
    @IBAction func tutorialAciton(_ sender: Any) {
        let board = UIStoryboard(name: "Main", bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: "AletViewVodHelpVC") as! AletViewVodHelpVC
        self.navigationController!.view.addSubview(vc.view)
        self.navigationController!.addChild(vc)
        self.didMove(toParent: vc)
    }
}
extension VodSettingViewController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.videoInfo.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.height/8
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownVodInfoCell", for:indexPath) as! DownVodInfoCell
        let vodinfo = videoInfo[indexPath.row]
        cell.title.text = vodinfo.title
        cell.palytime.text = vodinfo.pay
        cell.check.isHidden = !vodinfo.vodcheck!
        if let image = vodinfo.image{
           cell.thumbNail.image = Util.convertBase64StringToImage(imageBase64String:image)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        videoInfo[indexPath.row].vodcheck  =  !videoInfo[indexPath.row].vodcheck!
        DatabaseManager.getInstance().saveVodPlayCheck(fileName: videoInfo[indexPath.row].title!, check:videoInfo[indexPath.row].vodcheck!)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
