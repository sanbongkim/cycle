//
//  CyCleWebViewController.swift
//  cycle
//
//  Created by SSG on 2020/12/21.
//

import Foundation
import UIKit
import WebKit
class CycleWebViewController : UIViewController,WKNavigationDelegate,WKUIDelegate{
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var backButton: UIButton!
    var url : URL!
    var activityIndicator : ActivityIndicator!
    override func viewDidLoad() {
        webView.navigationDelegate = self
        let requestUrl = URLRequest(url: url!)
        webView.load(requestUrl)
        activityIndicator = ActivityIndicator(view: view, navigationController: self.navigationController, tabBarController: nil)
        activityIndicator.showActivityIndicator(text: Util.localString(st: "loding"))
    }
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func webView(_ webView: WKWebView, didCommit navigaiton: WKNavigation!){
        
        
    }
    func webView(_ webView: WKWebView, didFinish navigaiton: WKNavigation!){
        activityIndicator.stopActivityIndicator()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopActivityIndicator()
    }
    
}
