//
//  VodListController.swift
//  cycle
//
//  Created by SSG on 2020/12/24.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
class VodListController:UIViewController{
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var info: UIButton!
    var videoInfo = [InfoData]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibName = UINib(nibName: "VodListCell", bundle: nil)
        tableview.register(nibName, forCellReuseIdentifier: "VodListCell")
        tableview.delegate = self
        tableview.dataSource = self
        tableview.backgroundView = UIImageView(image: UIImage(named: "cycle_background"))
        self.tableview .reloadData()
        getVodList()
    }
    @IBAction func infoAction(_ sender: Any) {
        let board = UIStoryboard(name: "Main", bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: "AletViewVodHelpVC") as! AletViewVodHelpVC
        self.navigationController!.view.addSubview(vc.view)
        self.navigationController!.addChild(vc)
        self.didMove(toParent: vc)
        
    }
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
    }
    func getVodList(){
        var parameters: [String: Any] = [:]
        parameters["version"] = "0.0.0"
        parameters["language"] = Util.getlan()
        let activityIndicator = ActivityIndicator(view: view, navigationController: self.navigationController, tabBarController: nil)
        activityIndicator.showActivityIndicator(text: Util.localString(st: "loding"))
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 15
        manager.request(Constant.VRFIT_VOD_LIST, method: .post, parameters:parameters, encoding:URLEncoding.httpBody)
            .responseJSON { [self] response in
                switch(response.result) {
                case.success(let obj):
                    activityIndicator.stopActivityIndicator()
                    do{
                        let jsonData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                        let json = try JSONDecoder().decode(VideoInfo.self,from: jsonData)
                        print(json)
                        if json.result == "FAIL"{
                            for Infodata in json.data!.values{
                                self.videoInfo.append(Infodata)
                            }
                            self.videoInfo.sort {
                                $0.title!.localizedCaseInsensitiveCompare($1.title!) == ComparisonResult.orderedAscending
                            }
                            self.tableview .reloadData()
                            _ = DatabaseManager.getInstance().saveVodInfo(modelInfo:videoInfo)
                        }else{
                           
                        }
                    }
                    catch{
                        print(error.localizedDescription)
                    }                   
                case.failure(let error):
                    activityIndicator.stopActivityIndicator()
                    if let error = error as? AFError {
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
                        let alert = UIAlertController(title: Util.localString(st: "alert"), message: Util.localString(st:"wifi_fail"), preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
                        }
                        alert.addAction(OKAction)
                        self.present(alert, animated: true, completion: nil)
                        print("Unknown error: \(error)")
                    }
                }
            }
    }
}
extension VodListController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.videoInfo.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier:"VodListCell",for:indexPath) as! VodListCell
        let videoInfo = self.videoInfo[indexPath.row]
        cell.title.text = videoInfo.aviname
        cell.playTime.text = videoInfo.pay
        if  let image = videoInfo.image{
            cell.thumNail.image = Util.convertBase64StringToImage(imageBase64String:image)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        let board = UIStoryboard(name: "Main", bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: "AlertResolution") as! AlertResolutionVC
        let videoInfo = self.videoInfo[indexPath.row]
        vc.fileName = videoInfo.title
        self.navigationController!.view.addSubview(vc.view)
        self.navigationController!.addChild(vc)
        self.didMove(toParent: vc)
        
        //    let window = UIApplication.shared.keyWindow!
        
        
        //    window.rootViewController!.addChild(vc)
        //    window.rootViewController!.view.addSubview(vc.view)
        //    self.didMove(toParent: vc)
    }
}
