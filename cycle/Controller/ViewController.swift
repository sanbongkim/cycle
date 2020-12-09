//
//  ViewController.swift
//  cycle
//
//  Created by SSG on 2020/11/23.
//

import UIKit
import SideMenu
class ViewController: UIViewController {
    var menu:SideMenuNavigationController?
    override func viewDidLoad() {
       super.viewDidLoad()
       // Do any additional setup after loading the view.
       let board = UIStoryboard(name: "Main", bundle: nil)
       let vc = board.instantiateViewController(withIdentifier: "leftViewController")
       menu = SideMenuNavigationController(rootViewController:vc)
       menu?.leftSide = true
       menu?.setNavigationBarHidden(true, animated: false)
       menu?.settings = makeSettings()
       SideMenuManager.default.leftMenuNavigationController = menu
       SideMenuManager.default.addPanGestureToPresent(toView: self.view)
   }
   private func makeSettings() -> SideMenuSettings{
       var presentationStyle = SideMenuPresentationStyle()
       presentationStyle = .viewSlideOutMenuIn
       presentationStyle.backgroundColor = .clear
       presentationStyle.onTopShadowOpacity = 0.5
       presentationStyle.onTopShadowRadius = 5
       presentationStyle.onTopShadowColor = .black
       presentationStyle.presentingEndAlpha = 0.6
       var settings = SideMenuSettings()
       settings.presentationStyle = presentationStyle
       settings.menuWidth = view.bounds.width - 100
       return settings
   }
   @IBAction func didTabMenu(){
        present(menu!,animated: true)
   }
}
