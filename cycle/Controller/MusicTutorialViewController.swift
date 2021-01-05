//
//  MusicTutorialViewController.swift
//  cycle
//
//  Created by SSG on 2020/12/23.
//

import UIKit
import Foundation

enum ImageMode{
    case downlaod,setting,tutorial
}
class MusicTutorialViewController : UIViewController{
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var image: UIImageView!
    var mode : ImageMode = ImageMode.tutorial
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        switch mode {
        case .downlaod:
            image.image = UIImage(named:Util.localString(st:"music_instruction1"))
            break
        case .setting:
            image.image = UIImage(named:Util.localString(st:"music_instruction2"))
            break
        case .tutorial:
            image.image = UIImage(named:Util.localString(st:"instruction"))
            break
        }
    }
    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true , completion:nil )
    }
    
    @IBAction func tabGesture(_ sender: Any) {
        
        dismiss(animated: true , completion:nil )
    }
}
