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
    var videoInfo = [InfoData]()
    override func viewDidLoad() {
        super.viewDidLoad()
        getVodList()
    }
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func getVodList(){
        var parameters: [String: Any] = [:]
        parameters["version"] = "0.0.0"
        parameters["language"] = Util.getlan()
        let activityIndicator = ActivityIndicator(view: view, navigationController: self.navigationController, tabBarController: nil)
        activityIndicator.showActivityIndicator(text: Util.localString(st: "loding"))
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 15
        manager.request(Constant.VRFIT_MUSIC_LIST, method: .post, parameters:parameters, encoding:URLEncoding.httpBody)
            .responseJSON { response in
                switch(response.result) {
                case.success(let obj):
                     activityIndicator.stopActivityIndicator()
                    do{
                        let jsonData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                        let json = try JSONDecoder().decode(VideoInfo.self,from: jsonData)
                        if json.result == "FAIL"{
                           for Infodata in json.data!.values{
                           
                               self.videoInfo.append(Infodata)
                           }
                            self.videoInfo.sort {
                                $0.title!.localizedCaseInsensitiveCompare($1.title!) == ComparisonResult.orderedAscending
                            }
                            
                        }
                    }
                    catch{
                        print(error.localizedDescription)
                    }
//                    if let data = response.data, let _ = String(data: data, encoding: .utf8){
//                        //print("Data: \(utf8Text)") // original server data as UTF8 string
//                        do{
//                            // Get json data
//                            let json = try JSON(data: data)
//                            if let reqcode = json["result"].string{
//                                if(reqcode == "SUCCESS"){
//                                    print("success")
//                                }
//                                else{
//                                    let json = try JSONDecoder().decode(InfoData.self, from: json["data"])
//
//                                }
//                            }
//                        }catch{
//                            print("Unexpected error: \(error).")
//                        }
//                    }
                   
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
