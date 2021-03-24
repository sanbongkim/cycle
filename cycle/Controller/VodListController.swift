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
    @IBOutlet weak var vrButton: UIButton!
    @IBOutlet weak var nonVrBtton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var info: UIButton!
    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var noVrCheck: UIButton!
    var videoInfo = [InfoData]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let nibName = UINib(nibName: "VodListCell", bundle: nil)
        tableview.register(nibName, forCellReuseIdentifier: "VodListCell")
        tableview.delegate = self
        tableview.dataSource = self
        vrButton.isSelected = true
        noVrCheck.isHidden = true
        checkLabel.text = "Users 360VRFit Goggle"
        self.tableview .reloadData()
        getVodList()
    }
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func nonVrcheckAction(_ sender: Any) {
        let button = sender as! UIButton
        noVrCheck.isSelected = !button.isSelected
        
    }
    @IBAction func infoAction(_ sender: Any) {
        let board = UIStoryboard(name: "Main", bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: "AletViewVodHelpVC") as! AletViewVodHelpVC
        self.navigationController!.view.addSubview(vc.view)
        self.navigationController!.addChild(vc)
        self.didMove(toParent: vc)
        
    }
    @IBAction func checkButtonAction(_ sender: Any) {
        let button = sender as! UIButton
        button.isSelected = !button.isSelected
    }
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
    }
    @IBAction func nonVrButtonAction(_ sender: Any) {
        let click = sender as! UIButton
        if nonVrBtton.isSelected == true {return}
        nonVrBtton.isSelected = !click.isSelected
        vrButton.isSelected = false
        checkButton.isHidden = true
        noVrCheck.isHidden = false
        self.videoInfo.removeAll()
        self.videoInfo =  DatabaseManager.getInstance().selectVideoData2d()
        checkLabel.text = "vr 아니아니"
        tableview.reloadData()
    }
    @IBAction func vrButtonAction(_ sender: Any) {
        let click = sender as! UIButton
        if vrButton.isSelected == true {return}
        vrButton.isSelected = !click.isSelected
        nonVrBtton.isSelected = false
        noVrCheck.isHidden = true
        checkButton.isHidden = false
        checkLabel.text = "Users 360VRFit Goggle"
        self.videoInfo.removeAll()
        self.videoInfo =  DatabaseManager.getInstance().selectVideoData360()
        tableview.reloadData()
    }
    func getVodList(){
        var parameters: [String: Any] = [:]
        if  let version = UserDefaults.standard.string(forKey: "version"),version.count > 0 {
            parameters["version"] = version
        }else {  parameters["version"] = "0.0.0"}
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
                        //TODO: 테스트 하기위해 우선 FAIL 을 위해
                        if json.result == "FAIL"{

                            for Infodata in json.data!.values{
                                self.videoInfo.append(Infodata)
                            }
                            self.videoInfo.sort {
                                $0.title!.localizedCaseInsensitiveCompare($1.title!) == ComparisonResult.orderedAscending
                            }
                           
                            _ = DatabaseManager.getInstance().saveVodInfo(modelInfo:videoInfo)
                            self.videoInfo.removeAll()
                            videoInfo = DatabaseManager.getInstance().selectVideoData360()
                            self.tableview .reloadData()
                            UserDefaults.standard.setValue(json.version, forKey: "version")
                            UserDefaults.standard.synchronize()
                     
                        }else{
                            self.videoInfo.removeAll()
                            videoInfo = DatabaseManager.getInstance().selectVideoData360()
                            self.tableview .reloadData()
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
    func makeUrl(type:Int,fileName:String)->String{
        var url : String! = Constant.VRFIT_DOWNLOAD
        switch(type){
        case 0:
            url.append("download?file=")
            break
        case 1:
            url.append("download_2k?file=")
            break
        case 2:
            url.append("download_4k?file=")
            break
        default: break
            
        }
        url.append(fileName)
        url.append(".mp4")
       return url
    }
    func downloadUsingAlamofire(url: URL, fileName: String ,completionHandler:@escaping (CGFloat?, NSError?,Bool?) -> Void) {
        let manager = Alamofire.SessionManager.default
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent(fileName + ".mp4")
            print(documentsURL)
            return (documentsURL,[.removePreviousFile])
        }
        manager.download(url, to: destination)
            .downloadProgress(queue: .main,closure: { (progress) in
                let comp = CGFloat(progress.fractionCompleted) * 100
                // self.downloadPercent.text = String(Int(comp)) + "%"
                print("comp" + "\(comp)")
                completionHandler(comp, nil,false)
            })
            .responseData { response in
                
                switch response.result{
                case .success:
                    if let statusCode = response.response?.statusCode{
                       if statusCode == 200 {
                       _ = DatabaseManager.getInstance().saveDownLoadComplate(fileName:fileName)
                                      // self.removeFromParent()
                                            //self.view.removeFromSuperview()
                        completionHandler(nil, nil,true)
                                            
                       }
                        
                    }
                    break
                case .failure(let e):
                    completionHandler(nil, e as NSError,false)
                    break
                }
//                if response.destinationURL != nil {
//                if let statusCode = response.response?.statusCode{
//                    if statusCode == 200 {
//                        _ = DatabaseManager.getInstance().saveDownLoadComplate(fileName:fileName)
//                       // self.removeFromParent()
//                        //self.view.removeFromSuperview()
//                        completionHandler(nil, nil,true)
//
//                    }
//                    else{
//                    }
//                }
//            }else{
//                completionHandler(nil, nil,false)
//            }
          
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
        if videoInfo.download == true {
            cell.lowqul.isHidden = true
            cell.hiqul.isHidden = true
            cell.progressbar.isHidden = true
            cell.percent.isHidden = true
            cell.downhigh.isHidden = true
            cell.downlow.isHidden = true
            cell.playView.isHidden = false
            
        }else{
            cell.lowqul.isHidden = false
            cell.hiqul.isHidden = false
            cell.downlow.isHidden = false
            cell.downhigh.isHidden = false
            cell.playView.isHidden = true
            cell.percent.isHidden = true
            
        }
        cell.title.text = videoInfo.aviname
        cell.lowqul.text = "Low quality " +  Units(bytes: Int64(Int(videoInfo.length))).getReadableUnit()
        cell.hiqul.text = "Hight quality " + Units(bytes: Int64(Int(videoInfo.length_2k))).getReadableUnit()
        cell.downlow.addTarget(self, action:#selector(downAction),for:.touchUpInside)
        cell.downlow.tag = indexPath.row
        cell.downhigh.addTarget(self, action:#selector(downAction),for:.touchUpInside)
        cell.downhigh.tag = indexPath.row
        cell.removeVideo.addTarget(self, action: #selector(removeVideoActon), for: .touchUpInside)
        cell.removeVideo.tag = indexPath.row
        cell.playGame.addTarget(self, action: #selector(playGame), for: .touchUpInside)
        
        var time:String?
        if let play = videoInfo.pay {
            Util.hmsFrom(seconds:Int(play) ?? 0) { hours, minutes, seconds in
                let minutes = Util.getStringFrom(seconds: minutes)
                let seconds = Util.getStringFrom(seconds: seconds)
                time = minutes+":"+seconds
            }
        }
        cell.playTime.text = time
        if  let image = videoInfo.image{
            cell.thumNail.image = Util.convertBase64StringToImage(imageBase64String:image)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
      
    }
    @objc func playGame(){
        
        print("playGame")
        
    }
    @objc func removeVideoActon(snder:UIButton){
        
        let button = snder as UIButton
        let videoInfo = self.videoInfo[button.tag]
        self.deleteFile(fileName: videoInfo.title!+".mp4")
        DatabaseManager.getInstance().removeVod(string: videoInfo.title!)
        self.videoInfo.removeAll()
        if vrButton.isSelected == true{
            self.videoInfo =  DatabaseManager.getInstance().selectVideoData360()
        }else {
            self.videoInfo =  DatabaseManager.getInstance().selectVideoData2d()
        }
        self.tableview.reloadData()
    }
    @objc func downAction(snder:UIButton){
        let button = snder as UIButton
        var videoInfo = self.videoInfo[button.tag]
        let indexPath = IndexPath(row:button.tag, section: 0)
        let cell = self.tableview.cellForRow(at: indexPath) as? VodListCell
        if  cell != nil {
        if let encoded = makeUrl(type: 0, fileName: videoInfo.title!).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let myURL = URL(string: encoded) {
            cell!.progressbar.isHidden = false
            cell!.lowqul.isHidden = true
            cell!.hiqul.isHidden = true
            cell!.downlow.isHidden = true
            cell!.downhigh.isHidden = true
            cell!.percent.isHidden = false
            self.view.isUserInteractionEnabled = false
           downloadUsingAlamofire(url: myURL, fileName: videoInfo.title!) { progress,error,success in
            if progress != nil{
               cell!.progressbar.progress = Float(progress!)/100
               cell!.percent.text = String(Int(progress!)) + "%"
            }
            else{
                if success == true {
                    videoInfo.download = true
                    cell!.progressbar.progress = 0
                    cell!.percent.text = "0%"
                    self.videoInfo.removeAll()
                    if self.vrButton.isSelected == true{
                        self.videoInfo =  DatabaseManager.getInstance().selectVideoData360()
                    }else {
                        self.videoInfo =  DatabaseManager.getInstance().selectVideoData2d()
                    }
                    self.view.isUserInteractionEnabled = true
                    self.tableview.reloadData()
                }
            }
            if error != nil{
                self.view.isUserInteractionEnabled = true
                cell!.progressbar.progress = 0
                cell!.percent.text = "0%"
               
                self.videoInfo.removeAll()
                if self.vrButton.isSelected == true{
                    self.videoInfo =  DatabaseManager.getInstance().selectVideoData360()
                }else {
                    self.videoInfo =  DatabaseManager.getInstance().selectVideoData2d()
                }
                self.view.isUserInteractionEnabled = true
                self.tableview.reloadData()
            }
          }
        }
      }
        print("button" + "\(button.tag)")
    }
    func hideCellList(bool : Bool){
        
    }
    func deleteFile(fileName : String){
        let fileNameToDelete = fileName
        var filePath = ""
        let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        if dirs.count > 0 {
            let dir = dirs[0] //documents directory
            filePath = dir.appendingFormat("/" + fileNameToDelete)
            print("Local path = \(filePath)")
        } else {
            print("Could not find local directory to store file")
            return
        }
        do {
            let fileManager = FileManager.default
            // Check if file exists
            if fileManager.fileExists(atPath: filePath) {
                // Delete file
                try fileManager.removeItem(atPath: filePath)
            } else {
                print("File does not exist")
            }
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
    }
}
