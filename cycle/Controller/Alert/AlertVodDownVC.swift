//
//  AlertVodDownVC.swift
//  cycle
//
//  Created by SSG on 2020/12/15.
//

import Foundation
import UIKit
import Alamofire
enum resolution{
    
    case low,middle,high
}

class AlertVodDownVC : UIViewController{
    var url: String!
    var fileName : String!
    var downloadUrl : URL!
    var vodresolution: resolution = resolution.low
    
    @IBOutlet weak var close: UIButton!
    @IBOutlet weak var downloadPercent: UILabel!
    @IBOutlet weak var message: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        if let encoded = makeUrl().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let myURL = URL(string: encoded) {
            downloadUsingAlamofire(url: myURL, fileName: fileName+".mp4")
        }

    }
    @IBAction func closeAction(_ sender: Any) {
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
    @IBAction func cancelAciton(_ sender: Any) {
        let sessionManager = Alamofire.SessionManager.default
                sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
                    dataTasks.forEach { $0.cancel() }
                    uploadTasks.forEach { $0.cancel() }
                    downloadTasks.forEach { $0.cancel() }
            
                }
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
    func makeStringKoreanEncoded(_ string: String) -> String {
        return string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? string
    }
    func makeUrl()->String{
        var url : String! = Constant.VRFIT_DOWNLOAD
        switch(vodresolution){
        case .low:
            url.append("download?file=")
            break
        case .middle:
            url.append("download_2k?file=")
            break
        case .high:
            url.append("download_4k?file=")
            break
        }
        url.append(fileName)
        url.append(".mp4")
       return url
    }
    func downloadUsingAlamofire(url: URL, fileName: String) {
        let manager = Alamofire.SessionManager.default
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            documentsURL.appendPathComponent(fileName)
            print(documentsURL)
            return (documentsURL,[.removePreviousFile])
        }
        manager.download(url, to: destination)
            .downloadProgress(queue: .main, closure: { (progress) in
                
                let comp = CGFloat(progress.fractionCompleted) * 100
                self.downloadPercent.text = String(Int(comp)) + "%"
            })
            .responseData { response in
                
            self.removeFromParent()
            self.view.removeFromSuperview()
            if let destinationUrl = response.destinationURL {
                print(destinationUrl)
                if let statusCode = response.response?.statusCode{
                    if statusCode == 200 {
                        DispatchQueue.main.async() {
                            
                            
                        }
                    }else{
                    }
                }
            }else{
            }
        }
    }
}
@IBDesignable extension UIButton {

    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = self.frame.height / newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
