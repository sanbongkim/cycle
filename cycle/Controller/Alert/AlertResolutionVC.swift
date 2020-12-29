//
//  AlertResolution.swift
//  cycle
//
//  Created by SSG on 2020/12/16.
//

import Foundation
import UIKit



class AlertResolutionVC: UIViewController{
    
    @IBOutlet weak var close: UIButton!
    @IBOutlet weak var down: UIButton!
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var downAction: UIButton!
    @IBOutlet weak var cancelAction: UIButton!
    @IBOutlet weak var low: UIButton!
    @IBOutlet weak var middle: UIButton!
    @IBOutlet weak var high: UIButton!
    var url : String!
    var fileName : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func closeAction(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    @IBAction func cancelAction(_ sender: Any) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    @IBAction func downAction(_ sender: Any) {
        
        let board = UIStoryboard(name: "Main", bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: "AlerVodDown") as! AlertVodDownVC
        vc.url = self.url
        vc.fileName = self.fileName
        if low.isSelected {vc.vodresolution = resolution.low }
        else if middle.isSelected {vc.vodresolution = resolution.middle }
        else if high.isSelected {vc.vodresolution = resolution.high }
        
        self.navigationController!.view.addSubview(vc.view)
        self.navigationController!.addChild(vc)
        
        self.didMove(toParent: vc)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    @IBAction func lowAction(_ sender: Any) {
        
        let button = sender as! UIButton
        button.isSelected = !button.isSelected
        middle.isSelected = false
        high.isSelected = false
        
    }
    @IBAction func middleAction(_ sender: Any) {
        let button = sender as! UIButton
        button.isSelected = !button.isSelected
        low.isSelected = false
        high.isSelected = false
    }
    @IBAction func high(_ sender: Any) {
        let button = sender as! UIButton
        button.isSelected = !button.isSelected
        middle.isSelected = false
        low.isSelected = false
    }
}
