//
//  LeftViewController.swift
//  cycle
//
//  Created by SSG on 2020/11/26.
//
import UIKit
import Foundation

class LeftViewController : UIViewController{


    @IBOutlet weak var goBack: UIButton!
    @IBOutlet weak var record: UIButton!
    @IBOutlet weak var rank: UIButton!
    @IBOutlet weak var moviedn: UIButton!
    @IBOutlet weak var vrsetting: UIButton!
    @IBOutlet weak var musicSetting: UIButton!
    @IBOutlet weak var tutorial: UIButton!
    @IBOutlet weak var version: UIButton!
    @IBOutlet weak var sencerBuy: UIButton!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        record.setImage(UIImage(named:Util.localString(st: "ham_record")), for: .normal)
        rank.setImage(UIImage(named:Util.localString(st: "ham_rank")), for: .normal)
        moviedn.setImage(UIImage(named:Util.localString(st: "ham_moviedn")), for: .normal)
        vrsetting.setImage(UIImage(named:Util.localString(st: "ham_setting")), for: .normal)
        musicSetting.setImage(UIImage(named:Util.localString(st: "ham_music")), for: .normal)
        tutorial.setImage(UIImage(named:Util.localString(st: "ham_tutorial")), for: .normal)
        version.setImage(UIImage(named:Util.localString(st: "ham_version")), for: .normal)
        sencerBuy.setImage(UIImage(named:Util.localString(st: "ham_buy")), for: .normal)
    }
    @IBAction func goBackAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func recordAction(_ sender: Any) {
        
    }
    @IBAction func rankAction(_ sender: Any) {
    
    }
    @IBAction func movieDnAciton(_sender: Any){
        
    }
    @IBAction func verSetAction(_sender: Any){
        
    }
    @IBAction func turotialAction(_sender: Any){
        
    }
    @IBAction func musicSetAction(_sender: Any){
        
    }
    @IBAction func versionAction(_sender: Any){
        
    }
    @IBAction func sencerBuyAction(_sender: Any){
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecordWebView"{
            let vc = segue.destination as! CycleWebViewController
            let userid =  UserDefaults.standard.string(forKey:"userid")
            vc.url = URL(string:Constant.VRFIT_RECORD+"\(userid!)"+"&language="+Util.getlan())
        }
        else if(segue.identifier == "RankWebView"){
            let vc = segue.destination as! CycleWebViewController
            let userid =  UserDefaults.standard.string(forKey:"userid")
            vc.url = URL(string:Constant.VRFIT_RANKING+"\(userid!)"+"&language="+Util.getlan())
            
        }
        else if(segue.identifier == "PayWebView"){
            let vc = segue.destination as! CycleWebViewController
            vc.url = URL(string:Constant.VRFIT_PAY_MTOME)
            
        }
    }
}
