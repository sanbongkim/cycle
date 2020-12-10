//
//  Protocol.swift
//  Boxing
//
//  Created by altedge on 2020/04/04.
//  Copyright © 2020 mtome. All rights reserved.
//
protocol HomeControllerDelegate {
    func toogleSideMenu()
    func showDarkview()

}
protocol MenuControllerDelegate{
    func closeSideMenu()
}
protocol LoginControllerDelegate{
    func saveWeight(weight:Int)
    func signIn()
    func alertWeight()
}
protocol ScanTableViewDelegate{
    
    func closePopup()
    
}
protocol TutorialPageViewDelegate{
    
    func closePopup()
    
}
protocol TutorialControllerDelegate{
     func closeTutorial()
}
