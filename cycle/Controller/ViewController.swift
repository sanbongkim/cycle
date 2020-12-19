//
//  ViewController.swift
//  cycle
//
//  Created by SSG on 2020/11/23.
import UIKit
import SideMenu
import Alamofire
import SwiftyJSON
class ViewController: UIViewController {
    var logo : UIView!
    var menu:SideMenuNavigationController?
    var loginViewConroller : LoginViewController!
    var alertVodDownvc : AlertVodDownVC!
    override func viewDidLoad() {
       super.viewDidLoad()
       // Do any additional setup after loading the view.
       let board = UIStoryboard(name: "Main", bundle: nil)
       let vc = board.instantiateViewController(withIdentifier: "leftViewController")
       menu = SideMenuNavigationController(rootViewController:vc)
       menu?.leftSide = false
       menu?.setNavigationBarHidden(true, animated: false)
       menu?.settings = makeSettings()
       SideMenuManager.default.leftMenuNavigationController = menu
       SideMenuManager.default.addPanGestureToPresent(toView: self.view)
       logo = (Bundle.main.loadNibNamed("logoView", owner: self, options: nil)![0] as! UIView)
       logo.frame = self.view.bounds
       self.view.addSubview(logo)
       checkVersion()
//       alertVodDownvc =  (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AlertVodDownVC") as! AlertVodDownVC)
//       //loginViewConroller.delegate = self
//       view.addSubview(alertVodDownvc.view)
//       addChild(alertVodDownvc)
//       alertVodDownvc.didMove(toParent: self)
   }
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(true)
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
   func checkVersion(){
        var parameters: [String: Any] = [:]
        parameters["version"]    =  Util.getAppversion()
        print(parameters)
        let manager = Alamofire.SessionManager.default
            manager.session.configuration.timeoutIntervalForRequest = 15
            manager.request(Constant.VRFIT_VERSION_CHECK, method: .post, parameters:parameters, encoding:URLEncoding.httpBody)
                .responseJSON { [self] response in
//                    self.activityIndicator.stopActivityIndicator()
                    switch(response.result) {
                    case.success:
                        
                        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8){
                            print("Data: \(utf8Text)") // original server data as UTF8 string
                            do{
                                // Get json data
                                let json = try JSON(data: data)
                                if let reqcode = json["result"].string{
                                    if(reqcode == "SUCCESS"){
                                        logo.removeFromSuperview()
                                        configureHomeController()
                                    }
                                    else if reqcode == "FAIL"{
                                        let alert = UIAlertController(title: Util.localString(st: "alert"), message:Util.localString(st:"version_not_match"), preferredStyle: .alert)
                                        let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
                                            self.showAppStoreModal()
                                        }
                                        alert.addAction(OKAction)
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                }
                            }catch{
                                print("Unexpected error: \(error).")
                            }
                        }
                    case.failure:
                        let alert = UIAlertController(title: Util.localString(st: "alert"), message:Util.localString(st:"wifi_fail"), preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
                        }
                        alert.addAction(OKAction)
                        self.present(alert, animated: true, completion: nil)
                   
            }
        }
    }
    func showAppStoreModal(){
        
        if let url = URL(string: "itms-apps://itunes.apple.com/app/1534551390"),
            UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:],  completionHandler: {
                                 (success) in
                    exit(0)
                                 
               })
            } else { UIApplication.shared.openURL(url) } }
    }
//        let storeViewController = SKStoreProductViewController()
//        storeViewController.delegate = self
//            // 앱스토어에 있는 앱 id값으로 연결된 SKStoreProductParameterITunesItemIdentifier 키로 초기화
//            let parameters = [SKStoreProductParameterITunesItemIdentifier: 1085123968]
//            // 뷰 컨트롤러에 로드 되고 성공하면 표시된다.
//                storeViewController.loadProduct(withParameters: parameters, completionBlock: {result, error in
//                if result {
//                    self.present(storeViewController, animated: true, completion: nil)
//                }
//            })
//        }
    func configureHomeController(){
 
        let saveid = UserDefaults.standard.string(forKey: "userid")
        if (saveid != nil) {
            var parameters: [String: Any] = [:]
            parameters["id"]    =  UserDefaults.standard.string(forKey: "userid")
            parameters["pw"]    =  UserDefaults.standard.string(forKey: "userpw")
            parameters["timezone"] = Util.timeZoneOffsetInHours()
            print(parameters)
            Alamofire.request(Constant.VRFIT_MEMBER_LOGIN_ADDRESS, method: .post, parameters:parameters, encoding:URLEncoding.httpBody)
                .responseJSON { [self] response in
                    switch(response.result) {
                    case.success:
                        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8){
                            print("Data: \(utf8Text)") // original server data as UTF8 string
                            do{
                                // Get json data
                                let json = try JSON(data: data)
                                if let reqcode = json["result"].string{
                                    if(reqcode == "SUCCESS"){
                                        
                                    }
                                }
                            }catch{
                                print("Unexpected error: \(error).")
                            }
                        }
                    case.failure(let error):
                        if let error = error as? AFError {
                            let alert = UIAlertController(title: Util.localString(st: "alert"), message:Util.localString(st:"wifi_fail"), preferredStyle: .alert)
                           let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
                       }
                           alert.addAction(OKAction)
                           self.present(alert, animated: true, completion: nil)
                            switch error {
                            case .invalidURL(let url):
                                print("Invalid URL: \(url) - \(error.localizedDescription)")
                            case .parameterEncodingFailed(let reason):
                                print("Parameter encoding failed: \(error.localizedDescription)")
                                print("Failure Reason: \(reason)")
                            case .multipartEncodingFailed(let reason):
                                print("Multipart encoding failed: \(error.localizedDescription)")
                                print("Failure Reason: \(reason)")
                            case .responseValidationFailed(let reason):
                                print("Response validation failed: \(error.localizedDescription)")
                                print("Failure Reason: \(reason)")
                                switch reason {
                                case .dataFileNil, .dataFileReadFailed:
                                    print("Downloaded file could not be read")
                                case .missingContentType(let acceptableContentTypes):
                                    print("Content Type Missing: \(acceptableContentTypes)")
                                case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                                    print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                                case .unacceptableStatusCode(let code):
                                    print("Response status code was unacceptable: \(code)")
                                }
                            case .responseSerializationFailed(let reason):
                                print("Response serialization failed: \(error.localizedDescription)")
                                print("Failure Reason: \(reason)")
                            }
                        } else if let error = error as? URLError {
                            print("URLError occurred: \(error)")
                        } else {
                            print("Unknown error: \(error)")
                        }
                    }
            }
        }
        else{
            loginViewConroller =  (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController)
            loginViewConroller.delegate = self
            view.addSubview(loginViewConroller.view)
            addChild(loginViewConroller)
            loginViewConroller.didMove(toParent: self)
        }
    }
}
extension ViewController : LoginControllerDelegate{
    func alertWeight() {
//        self.openAlertView()
    }
    
    func saveWeight(weight: Int) {
//        self.homeController.mWeight = Float(weight)
    }
    func showDarkview() {
        
    }
    func toogleSideMenu() {
//        configureMenuController()
//        isExpend = !isExpend
//        showMenuController(shouldExpend: isExpend)
    }
    func closeSideMenu(){
        toogleSideMenu()
    }
    func signIn(){
        self.view .removeFromSuperview()
        self.removeFromParent()
//        homeController.reflashUserid()
//        homeController.getData()
//        if self.loginViewConroller != nil{
//            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations:{
//                       self.loginViewConroller.view.alpha = 0.1
//                   }, completion: { finished in
//                       self.loginViewConroller.view.removeFromSuperview()
//                       self.loginViewConroller.removeFromParent()
//                   })
//        }
    }
}

