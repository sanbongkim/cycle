//
//  MusicListController.swift
//  Boxing
//
//  Created by altedge on 2020/04/15.
//  Copyright © 2020 mtome. All rights reserved.

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation
import AVKit
import FMDB
import GradientCircularProgress
class MusicListController : UIViewController{
    @IBOutlet weak var mInfo: UIButton!
    @IBOutlet weak var tableview: UITableView!
    var dataBase : FMDatabase? = nil
    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    var divView:UIView?
    @IBOutlet weak var musicDownload: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var musicSetting: UIButton!
    @IBOutlet weak var mEasyButton: UIButton!
    var currentPlay: Int = 10000
    var progress : GradientCircularProgress?
    var progressView : UIView?
    var bombSoundEffect: AVAudioPlayer?
    let difficult = ["easy","normal","hard"]
    var musicSort = [MusicInfo]()
    var musicInfos = [MusicInfo]()
    override func viewDidLoad() {
        let nibName = UINib(nibName: "LiveInfoCell", bundle: nil)
        tableview.register(nibName, forCellReuseIdentifier: "LiveInfoCell")
        self.getMusicList()
        musicDownload.isSelected = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
    }
    @IBAction func musicDownloadAction(_ sender: Any) {
        let button = sender as! UIButton
        if button.isSelected == true{return}
        button.isSelected = !button.isSelected
        musicDownload.isSelected = true
        musicDownload.isSelected = false
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MusicTutorialViewController"{
            let vc = segue.destination as! MusicTutorialViewController
            if musicDownload.isSelected{
                vc.mode = ImageMode.downlaod
            }else{
                vc.mode = ImageMode.setting
            }
        }
    }
    @IBAction func musicSettingAction(_ sender: Any) {
        let button = sender as! UIButton
        if button.isSelected == true{return}
        button.isSelected = !button.isSelected
        musicDownload.isSelected = false
        musicSetting.isSelected = true
    }
    func sortDifficult(value:String){
        for music in musicInfos {
            if music.difficulty == value{
                musicSort.append(music)
            }
        }
    }
    @IBAction func backButtonAction(_ sender: Any) {
        NotificationCenter.default.post(
                 name: NSNotification.Name(rawValue: "musicClose"),
                 object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    func getMusicList(){
        var parameters: [String: Any] = [:]
        parameters["version"] = "0.0.0"
        let activityIndicator = ActivityIndicator(view: view, navigationController: self.navigationController, tabBarController: nil)
        activityIndicator.showActivityIndicator(text: Util.localString(st: "loding"))
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 15
        manager.request(Constant.VRFIT_MUSIC_LIST, method: .post, parameters:parameters, encoding:URLEncoding.httpBody)
            .responseJSON { response in
                switch(response.result) {
                case.success:
                     activityIndicator.stopActivityIndicator()
                    if let data = response.data, let _ = String(data: data, encoding: .utf8){
                        //print("Data: \(utf8Text)") // original server data as UTF8 string
                        do{
                            // Get json data
                            let json = try JSON(data: data)
                            if let reqcode = json["result"].string{
                                if(reqcode == "SUCCESS"){
                                }
                                else{
                                }
                            }
                            for (_, subJson) in json["data"]{
                                // Display country name
                                let product = MusicInfo()
                                print(subJson)
                                if let title = subJson["title"].string {
                                    product?.title = title
                                    product?.isDownload = self.checkFile(title:title+".mp3") ? true : false
                                }
                                if let composer = subJson["composer"].string {
                                    product?.composer = composer
                                }
                                if let singer = subJson["singer"].string {
                                    product?.singer=singer
                                }
                                if let music_bit = subJson["music_bit"].string {
                                    product?.music_bit = music_bit
                                }
                                if let music_note = subJson["music_note"].int32 {
                                    product?.music_note = music_note
                                }
                                if let music_bpm = subJson["music_bpm"].int32 {
                                    product?.music_bpm = music_bpm
                                }
                                if let playtime = subJson["playtime"].int32 {
                                    product?.playSec = playtime
                                    var time:String? = nil
                                    Util.hmsFrom(seconds:Int(playtime)) { hours, minutes, seconds in
                                        let minutes = Util.getStringFrom(seconds: minutes)
                                        let seconds = Util.getStringFrom(seconds: seconds)
                                        time = minutes+":"+seconds
                                    }
                                    product?.playtime = time
                                }
                                if let h_playtime = subJson["h_playtime"].int32 {
                                    product?.h_playtime = h_playtime
                                }
                                if let length = subJson["length"].int32 {
                                    product?.length = length
                                }
                                if let difficulty = subJson["difficulty"].string {
                                    product?.difficulty = difficulty
                                }
                                self.musicInfos.append(product!)
                            }
                            self.musicInfos.sort {
                                $0.title!.localizedCaseInsensitiveCompare($1.title!) == ComparisonResult.orderedAscending
                            }
                            _ = DatabaseManager.getInstance().saveAllData(modelInfo: self.musicInfos)
                            
                            self.sortDifficult(value: "easy")
                            self.tableview.reloadData()
                            
                        }catch{
                            print("Unexpected error: \(error).")
                        }
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
    func checkFile(title:String) -> Bool{
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(title) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                return true
            } else {
                return false
            }
        }else {
            return false
        }
    }
    func tostMessage(message : String){
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 150, y: view.frame.size.height-100, width: 300,  height : 35))
        toastLabel.backgroundColor = .darkGray
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = NSTextAlignment.center;
        view.addSubview(toastLabel)
        toastLabel.text = message
        toastLabel.font = UIFont.boldSystemFont(ofSize: 18)
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        UIView.animate(withDuration: 1.0, animations: {
            toastLabel.alpha = 0.0
        }, completion: {
            (isBool) -> Void in
            toastLabel.removeFromSuperview()
        })
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
    func cancelSepcificDownloadTask(byUrl url:URL) {
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
        for task in downloadTasks {
                if task.originalRequest?.url == url {
                task.cancel()
            }
        }
      }
    }
    func downloadUsingAlamofire(url: URL, fileName: String,index : Int) {
        let manager = Alamofire.SessionManager.default
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent(fileName)
            print(documentsURL)
            return (documentsURL,[.removePreviousFile])
        }
        manager.download(url, to: destination)
            .downloadProgress(queue: .main, closure: { (progress) in
                //progress closure
                self.progress!.updateRatio(CGFloat(progress.fractionCompleted))
                print(progress.fractionCompleted)
            })
            .validate { request, response, temporaryURL, destinationURL in
                return .success
        }
        .responseData { response in
            if let destinationUrl = response.destinationURL {
                print(destinationUrl)
                if let statusCode = response.response?.statusCode{
                    self.progress!.dismiss(progress: self.progressView! ,completionHandler:{
                        self.divView?.removeFromSuperview()
                    })
                    if statusCode == 200 {
                        DispatchQueue.main.async() {
                            let minfo = self.musicSort[index]
                            minfo.isDownload = true
                            _ = DatabaseManager.getInstance().saveData(model:minfo)
                            self.tableview.reloadData()
                        }
                    }else{
                         self.progress!.dismiss(progress: self.progressView! ,completionHandler:{
                         self.divView?.removeFromSuperview()
                        })
                    }
                }
            }else {
                 self.progress!.dismiss(progress: self.progressView! ,completionHandler:{
                 self.divView?.removeFromSuperview()
                })
            }
        }
    }
}
extension MusicListController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicSort.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LiveInfoCell", for: indexPath) as! LiveInfoCell
        let tapGestureRecognizerThumb = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        let tapGestureRecognizerDown = UITapGestureRecognizer(target: self, action: #selector(downloadTapped(_:)))
        let cInfo : MusicInfo = musicSort[indexPath.row]
        cell.title.text = cInfo.title
        cell.bit.text = String(cInfo.music_bpm!)
        cell.time.text = cInfo.playtime!
        cell.note.text = String(cInfo.music_note!)
        cell.removeAnddownload.image = cInfo.isDownload ? UIImage(named: "music_remove") : UIImage(named: "music_down")
        cell.removeAnddownload.restorationIdentifier = cInfo.isDownload ? "music_remove" : "music_down"
        cell.removeAnddownload.tag = indexPath.row;
        cell.removeAnddownload.addGestureRecognizer(tapGestureRecognizerDown)
        cell.removeAnddownload.isUserInteractionEnabled = true
        cell.play.image = cInfo.isPlaying ? UIImage(named: "music_pause") : UIImage(named: "music_preplay")
        cell.play.addGestureRecognizer(tapGestureRecognizerThumb)
        cell.play.tag = indexPath.row
        cell.play.isUserInteractionEnabled = true
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    @objc func downloadTapped(_ gesture: UITapGestureRecognizer) {
        let v = gesture.view! as! UIImageView
        let tag = v.tag
        print("tag"+String(tag))
        let mInfo:MusicInfo = musicSort[tag]
        if v.restorationIdentifier == "music_remove"{
            let alert = UIAlertController.init(title: Util.localString(st: "alert"), message: Util.localString(st: "music_remove") + "[\(mInfo.title ?? "")]", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                DispatchQueue.main.async() {
                    self.deleteFile(fileName: mInfo.title!+".mp3")
                    mInfo.isDownload=false
                    _ = DatabaseManager.getInstance().saveData(model:mInfo)
                    self.tableview.reloadData()
                    Util.Toast.show(message: Util.localString(st: "remove_music_success"), controller: self)
                }
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
                
            })
            alert.addAction(ok)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        else{
            let alert = UIAlertController.init(title: Util.localString(st: "alert"), message: Util.localString(st: "music_down") + "[\(mInfo.title ?? "")]", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                DispatchQueue.main.async() {
                    let fileUrl = Constant.VRFIT_BOXING_MUSIC_URL+mInfo.title!+".mp3"
                    if let encoded  = fileUrl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),let myURL = URL(string: encoded){
                        self.divView = UIView.init(frame:self.view.frame)
                        self.divView!.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                        self.view.addSubview(self.divView!)
                        let rect = CGRect(x:0,y:0,width:200,height:200)
                        self.progress = GradientCircularProgress()
                        self.progressView = self.progress!.showAtRatio(frame: rect, display: true, style: MyStyle())
                        self.progressView!.center = self.view.center
                        self.progressView?.layer.cornerRadius = 10
                        self.progressView?.layer.masksToBounds = true
                        self.view.addSubview(self.progressView!)
                        self.downloadUsingAlamofire(url:myURL ,fileName:mInfo.title!+".mp3",index:tag)
                    }
                }
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            })
            alert.addAction(ok)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    @objc func imageTapped(_ gesture: UITapGestureRecognizer) {
        let v = gesture.view!
        let tag = v.tag
        print("tag"+String(tag))
        let mInfo:MusicInfo = musicSort[tag]
        mInfo.isPlaying = !mInfo.isPlaying
        self.tableview.reloadData()
        if currentPlay == tag && mInfo.isPlaying == false{
            player?.replaceCurrentItem(with: nil)
            currentPlay = 10000
        }
        else{
            if mInfo.title!.count > 0{
                playAudio(murl:Constant.VRFIT_BOXING_MUSIC_URL + mInfo.title! + ".mp3",tag:tag)
            }
        }
    }
    func playAudio(murl:String,tag:Int){
        player?.replaceCurrentItem(with: nil)
        if let encoded  = murl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed),
            let myURL = URL(string: encoded)
        {
            let playerItem:AVPlayerItem = AVPlayerItem(url: myURL)
            player = AVPlayer(playerItem: playerItem)
            let playerLayer=AVPlayerLayer(player: player!)
            playerLayer.frame=CGRect(x:0, y:0, width:10, height:50)
            self.view.layer.addSublayer(playerLayer)
            NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
            player?.play()
            if currentPlay != 10000{
                let mInfo:MusicInfo = musicSort[currentPlay]
                mInfo.isPlaying = false
            }
            currentPlay = tag
        }
    }
    @objc func playerDidFinishPlaying(note: NSNotification) {
        if currentPlay != 10000{
            let mInfo:MusicInfo = musicSort[currentPlay]
             mInfo.isPlaying = false
            player?.replaceCurrentItem(with: nil)
            currentPlay = 10000
        }
        self.tableview .reloadData()
     }
}
