//
//  Util.swift
//  Boxing
//
//  Created by altedge on 2020/05/25.
//  Copyright © 2020 mtome. All rights reserved.
//

import Foundation
import UIKit

struct ActivityIndicator {
    
    let viewForActivityIndicator = UIView()
    let backgroundView = UIView()
    let view: UIView
    let navigationController: UINavigationController?
    let tabBarController: UITabBarController?
    let activityIndicatorView = UIActivityIndicatorView()
    let loadingTextLabel = UILabel()
    //네비게이션 bar 높이계산 현재는 숨겼기 때문에 필요 없어 0.0 으로 세팅
    var navigationBarHeight: CGFloat {
        //navigationController?.navigationBar.frame.size.height ?? 0.0
        return 0.0
    }
    var tabBarHeight: CGFloat { return tabBarController?.tabBar.frame.height ?? 0.0 }
    func showActivityIndicator(text: String) {
        viewForActivityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 100, height: 100)
        viewForActivityIndicator.center = CGPoint(x: self.view.frame.size.width / 2.0, y: (self.view.frame.size.height - tabBarHeight - navigationBarHeight) / 2.0)
        viewForActivityIndicator.layer.cornerRadius = 10
        viewForActivityIndicator.backgroundColor = .darkGray
        backgroundView.addSubview(viewForActivityIndicator)
        activityIndicatorView.center = CGPoint(x: viewForActivityIndicator.frame.size.width / 2.0, y: (viewForActivityIndicator.frame.size.height - tabBarHeight - navigationBarHeight) / 2.0 )
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.style = .whiteLarge
        viewForActivityIndicator.addSubview(activityIndicatorView)
        backgroundView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        backgroundView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        view.addSubview(backgroundView)
        activityIndicatorView.startAnimating()
    }
    func stopActivityIndicator() {
        viewForActivityIndicator.removeFromSuperview()
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
        backgroundView.removeFromSuperview()
    }
}
public struct Units {
  
  public let bytes: Int64
  
  public var kilobytes: Double {
    return Double(bytes) / 1_024
  }
  
  public var megabytes: Double {
    return kilobytes / 1_024
  }
  
  public var gigabytes: Double {
    return megabytes / 1_024
  }
  
  public init(bytes: Int64) {
    self.bytes = bytes
  }
  
  public func getReadableUnit() -> String {
    
    switch bytes {
    case 0..<1_024:
      return "\(bytes) bytes"
    case 1_024..<(1_024 * 1_024):
      return "\(String(format: "%.0f", kilobytes)) KB"
    case 1_024..<(1_024 * 1_024 * 1_024):
      return "\(String(format: "%.0f", megabytes)) MB"
    case (1_024 * 1_024 * 1_024)...Int64.max:
      return "\(String(format: "%.0f", gigabytes)) GB"
    default:
      return "\(bytes) bytes"
    }
  }
}

class Util: NSObject{
    
    class func getAppversion() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        return "\(version)"
    }

    class func hmsFrom(seconds: Int, completion: @escaping (_ hours: Int, _ minutes: Int, _ seconds: Int)->()) {
        completion(seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    class func getStringFrom(seconds: Int) -> String {
        
         return seconds < 10 ? "0\(seconds)" : "\(seconds)"
    }
    class func localString(st:String)->String{
        
        let localString = String(format: NSLocalizedString(st, comment: ""))
        return localString
    }
    class func getPath(_ fileName:String)->String{
         let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
         let fileUrl = documentDirectory.appendingPathComponent(fileName)
         print( fileUrl.path)
         return fileUrl.path
     }
    class func copyDatabase(_ filename: String){
         let dbPatch = getPath(filename)
         let fileManager = FileManager.default
         var error:NSError?
         if !fileManager.fileExists(atPath: dbPatch){
             let bundle = Bundle.main.bundleURL
            let file = bundle.appendingPathComponent(filename)
             do{
                try fileManager.copyItem(atPath: (file.path), toPath: dbPatch)
             }catch let error1 as NSError{
                 error = error1
             }
             if error == nil{
                 print("success")
             }else{
                 print("fail")
             }
         }
     }
    static func convertBase64StringToImage (imageBase64String:String) -> UIImage {
        let imageData = Data.init(base64Encoded: imageBase64String, options: .init(rawValue: 0))
        let image = UIImage(data: imageData!)
        return image!
    }
    class func getlan()->String{
        
        let localeID = Locale.preferredLanguages.first
        let deviceLocale = (Locale(identifier: localeID!).languageCode)!
        return deviceLocale
    }
   class func timeZoneOffsetInHours() -> Int {
       let offset = TimeZone.current.secondsFromGMT() / 3600
       return offset
    }

    class func getBleName(name:String)->String{
        
        let arrayName = name.split(separator: "-")
        if arrayName.count == 0 {return ""}
        let calName = arrayName[0]+arrayName[1]+arrayName[2]
        return String(calName)
        
    }
    class func getTotalDate(year:Int,month:Int)->Int{
        //  choose the month and year you want to look
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        let calendar = Calendar.current
        let datez = calendar.date(from: dateComponents)
        //  change .month into .year to see the days available in the year
        let interval = calendar.dateInterval(of: .month, for: datez!)!
        let days = calendar.dateComponents([.day], from: interval.start, to: interval.end).day!
        return days
    }
    class Toast {
        static func show(message: String, controller: UIViewController){
            let toastContainer = UIView(frame: CGRect())
            toastContainer.backgroundColor = .darkGray
            toastContainer.alpha = 0.0
            toastContainer.layer.cornerRadius = 10;
            toastContainer.clipsToBounds  =  true
            let toastLabel = UILabel(frame: CGRect())
            toastLabel.textColor = UIColor.white
            toastLabel.textAlignment = .center;
            toastLabel.font.withSize(12.0)
            toastLabel.text = message
            toastLabel.clipsToBounds  =  true
            toastLabel.numberOfLines = 0
            toastContainer.addSubview(toastLabel)
            controller.view.addSubview(toastContainer)
            toastLabel.translatesAutoresizingMaskIntoConstraints = false
            toastContainer.translatesAutoresizingMaskIntoConstraints = false
            let a1 = NSLayoutConstraint(item: toastLabel, attribute: .leading, relatedBy: .equal, toItem: toastContainer, attribute: .leading, multiplier: 1, constant: 15)
            let a2 = NSLayoutConstraint(item: toastLabel, attribute: .trailing, relatedBy: .equal, toItem: toastContainer, attribute: .trailing, multiplier: 1, constant: -15)
            let a3 = NSLayoutConstraint(item: toastLabel, attribute: .bottom, relatedBy: .equal, toItem: toastContainer, attribute: .bottom, multiplier: 1, constant: -15)
            let a4 = NSLayoutConstraint(item: toastLabel, attribute: .top, relatedBy: .equal, toItem: toastContainer, attribute: .top, multiplier: 1, constant: 15)
            toastContainer.addConstraints([a1, a2, a3, a4])
            let c1 = NSLayoutConstraint(item: toastContainer, attribute: .leading, relatedBy: .equal, toItem: controller.view, attribute: .leading, multiplier: 1, constant: 65)
            let c2 = NSLayoutConstraint(item: toastContainer, attribute: .trailing, relatedBy: .equal, toItem: controller.view, attribute: .trailing, multiplier: 1, constant: -65)
            let c3 = NSLayoutConstraint(item: toastContainer, attribute: .centerY, relatedBy: .equal, toItem: controller.view, attribute: .centerY, multiplier: 1, constant:0)
            controller.view.addConstraints([c1, c2, c3])
            UIView.animate(withDuration: 0, delay: 0.0, options: .curveEaseIn, animations: {
                toastContainer.alpha = 1.0
            }, completion: { _ in
                UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                    toastContainer.alpha = 0.0
                }, completion: {_ in
                    toastContainer.removeFromSuperview()
                })
            })
        }
    }
}

