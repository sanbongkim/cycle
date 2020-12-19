//
//  LoginViewController.swift
//  daview
//
//  Created by ksb on 23/07/2019.
//  Copyright © 2019 ksb. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class LoginViewController: UIViewController {
    var activityindi : ActivityIndicator!
    var delegate: LoginControllerDelegate?
    var textField: UITextField?
    var activeTextField : UITextField? = nil
    
    @IBOutlet weak var userid: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var pwd: UITextField!
    @IBOutlet weak var signup: UIButton!
    @IBOutlet weak var notMemberLabel: UILabel!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.userid.tag = 100
        self.pwd.tag = 101
//        self.userid.placeholder = Util.localString(st: "ph_user_id")
//        self.pwd.placeholder = Util.localString(st: "ph_user_pwd")
//        self.signup.setTitle(Util.localString(st:"ph_join_now"), for:.normal)
        // call the 'keyboardWillShow' function when the view controller receive the notification that a keyboard is going to be shown
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        //self.pwd.addBottomBorder()
        // call the 'keyboardWillHide' function when the view controlelr receive notification that keyboard is going to be hidden
        // Do any additional setup after loading the view.
    }
    /*
     * 오토레이 아웃시 프레임 사이즈 레이아웃 표출후
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //self.userid.addBottomBorder()
     
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
    }
    @IBAction func tabAction(_ sender: Any) {
           view.endEditing(true)
    }
    @IBAction func goLogin(_ sender: Any) {
        
        
     
        
        
        let button = sender as! UIButton
        if ((button.currentImage?.isEqual(UIImage(named: "login_btn"))) != nil){
            guard let _ = userid.text, userid.text?.count != 0 else{
                let alert = UIAlertController(title:Util.localString(st: "alert") , message: Util.localString(st: "id_not_input"), preferredStyle: .alert)
                let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
                }
                alert.addAction(OKAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
            guard let _ = pwd.text, pwd.text?.count != 0 else{
                let alert = UIAlertController(title: Util.localString(st: "alert"), message: Util.localString(st: "pwd_not_input"), preferredStyle: .alert)
                let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
                }
                alert.addAction(OKAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
                var parameters: [String: Any] = [:]
                     parameters["id"]    = userid.text
                     parameters["pw"] = pwd.text
                    parameters["timezone"] = Util.timeZoneOffsetInHours()
                     print(parameters)
                     activityindi = ActivityIndicator(view: self.view,navigationController: self.navigationController,tabBarController: nil)
                     activityindi.showActivityIndicator(text:"")
                     Alamofire.request(Constant.VRFIT_MEMBER_LOGIN_ADDRESS, method: .post, parameters:parameters, encoding:URLEncoding.httpBody)
                         .responseJSON { response in
                            self.activityindi.stopActivityIndicator()
                             switch(response.result) {
                             case.success:
                                 if let data = response.data, let utf8Text = String(data: data, encoding: .utf8){
                                     print("Data: \(utf8Text)") // original server data as UTF8 stringㅇ
                                     do{
                                         // Get json data
                                         let json = try JSON(data: data)
                                         if let reqcode = json["result"].string{
                                             if(reqcode == "SUCCESS"){
                                                let uid = self.userid.text!
                                                let pwd = self.pwd.text!
                                                 UserDefaults.standard.set(uid, forKey: "userid")
                                                 UserDefaults.standard.synchronize()
                                                 UserDefaults.standard.set(pwd, forKey: "userpw")
                                                 UserDefaults.standard.synchronize()
                                                 self.delegate?.signIn()
                                                
                                             }
                                             else{
                                                 if let reqcode = json["reason"].string{
                                                     if(reqcode == "Service_err_000"){
                                                        let alert = UIAlertController(title: Util.localString(st: "alert"), message:Util.localString(st: "version_check_error"), preferredStyle: .alert)
                                                         let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
                                                          }
                                                         alert.addAction(OKAction)
                                                         self.present(alert, animated: true, completion: nil)
                                                     }
                                                     else if(reqcode == "service_err_001"){
                                                        let alert = UIAlertController(title: Util.localString(st: "alert"), message:Util.localString(st: "login_id_fail"), preferredStyle: .alert)
                                                         let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
                                                         }
                                                         alert.addAction(OKAction)
                                                         self.present(alert, animated: true, completion: nil)
                                                     }
                                                     else if(reqcode == "service_err_002"){
                                                         let alert = UIAlertController(title: Util.localString(st: "alert"), message: Util.localString(st: "login_pw_fail"), preferredStyle: .alert)
                                                         let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
                                                         }
                                                         alert.addAction(OKAction)
                                                         self.present(alert, animated: true, completion: nil)
                                                     }
                                                     else if(reqcode == "service_err_003"){
                                                         let alert = UIAlertController(title: Util.localString(st: "alert"), message: Util.localString(st: "login_email_check_fail"), preferredStyle: .alert)
                                                         let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
                                                         }
                                                         alert.addAction(OKAction)
                                                         self.present(alert, animated: true, completion: nil)
                                                     }
                                                     else if(reqcode == "service_err_005"){
                                                         let alert = UIAlertController(title: Util.localString(st: "alert"), message: Util.localString(st: "version_not_match"), preferredStyle: .alert)
                                                         let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
                                                         }
                                                         alert.addAction(OKAction)
                                                         self.present(alert, animated: true, completion: nil)
                                                     }
                                                     else if(reqcode == "service_err_007"){
                                                        let alert = UIAlertController(title: Util.localString(st: "alert"), message: Util.localString(st: "signup_id_duplication"), preferredStyle: .alert)
                                                         let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
                                                         }
                                                         alert.addAction(OKAction)
                                                         self.present(alert, animated: true, completion: nil)
                                                     }
                                                     else if(reqcode == "service_err_015"){
                                                         let alert = UIAlertController(title: Util.localString(st: "alert"), message:Util.localString(st: "input_weight_range"), preferredStyle: .alert)
                                                         let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
                                                         }
                                                         alert.addAction(OKAction)
                                                         self.present(alert, animated: true, completion: nil)
                                                     }
                                                 }
                                             }
                                         }
                                     }catch{
                                         print("Unexpected error: \(error).")
                                     }
                                 }
                             case.failure(let error):
                                 if let error = error as? AFError {
                                    let alert = UIAlertController(title: Util.localString(st: "alert"), message: Util.localString(st: "wifi_fail"), preferredStyle: .alert)
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
            
        }
//    @objc func keyboardWillShow(notification: NSNotification) {
//
//        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
//           // if keyboard size is not available for some reason, dont do anything
//           return
//        }
//
//      // move the root view up by the distance of keyboard height
//
//
//      self.view.frame.origin.y = 0 - keyboardSize.height
//    }
//
    }
    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
      self.view.frame.origin.y = 0
    }
    @objc func keyboardWillShow(notification: NSNotification) {

      guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {

        // if keyboard size is not available for some reason, dont do anything
        return
      }

      var shouldMoveViewUp = false

      // if active text field is not nil
      if let activeTextField = activeTextField {

        let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY;
        
        let topOfKeyboard = self.view.frame.height - keyboardSize.height

        // if the bottom of Textfield is below the top of keyboard, move up
        if bottomOfTextField > topOfKeyboard {
          shouldMoveViewUp = true
        }
      }

      if(shouldMoveViewUp) {
        self.view.frame.origin.y = 0 - keyboardSize.height
      }
    }
    func configurationTextField(textField: UITextField!) {
        if (textField) != nil {
               self.textField = textField!        //Save reference to the UITextField
               self.textField?.placeholder = "kg"
               self.textField?.keyboardType = .numberPad
           }
        }
      func openAlertView() {
        let alert = UIAlertController(title: Util.localString(st: "alert"), message: Util.localString(st:"input_weight") + "\n" + Util.localString(st:"input_weight_range"), preferredStyle: UIAlertController.Style.alert)
             alert.addTextField(configurationHandler: configurationTextField)
             alert.addAction(UIAlertAction(title: Util.localString(st: "ok"), style: .default, handler:{ (UIAlertAction) in
              let weight = Int(self.textField!.text!)
                   if weight == nil{
                        self.openAlertView()
                   }else{
                      if weight! >= 20 && weight! <= 180 {
                         self.sendWeight()
                      }
                       else{
                          self.openAlertView()
                       }
                   }
              }))
             self.present(alert, animated: true, completion: nil)
         }
    func checkEmailid()->Bool{
        let emailReg = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailReg)
        if emailTest.evaluate(with: self.userid.text) == false {return false}
        else{return true}
    }
    @IBAction func signupAction(_ sender: Any) {
        
    }
    func sendWeight(){
        var parameters: [String: Any] = [:]
        parameters["id"]       = UserDefaults.standard.string(forKey: "userid")
        let weight = Int(self.textField!.text!)
        parameters["weight"]    = weight
        print(parameters)
        Alamofire.request(Constant.VRFIT_MEMBER_INPUT_WEIGHT, method: .post, parameters:parameters, encoding:URLEncoding.httpBody)
            .responseJSON { response in
                switch(response.result) {
                case.success:
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8){
                        print("Data: \(utf8Text)") // original server data as UTF8 string
                        do{
                            // Get json data
                            let json = try JSON(data: data)
                            if let reqcode = json["result"].string{
                                if(reqcode == "SUCCESS"){
                                    print("sendServerSuccess")
                                    self.delegate?.saveWeight(weight:weight!)
                                }
                                else{
                                    print("sendServerFail")
                                }
                            }
                        }catch{
                            print("Unexpected error: \(error).")
                        }
                    }
                case.failure(let error):
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
                        print("URLError occurred: \(error)")
                    } else {
                        print("Unknown error: \(error)")
                    }
                }
        }
    }
    
    /*
     * 포스트 소스
     */
    /*
     @IBAction func post(_ sender: UIButton) {
     // 1. 전송할 값 준비
     let userId = (self.userId.text)!
     let name = (self.name.text)!
     let param = "userId=\(userId)&name=\(name)" // key1=value&key2=value...
     let paramData = param.data(using: .utf8)
     // 2. URL 객체 정의
     let url = URL(string: "http://swiftapi.rubypaper.co.kr:2029/practice/echo")
     // 3. URLRequest 객체를 정의하고, 요청 내용을 담는다.
     var request = URLRequest(url: url!)
     request.httpMethod = "POST"
     request.httpBody = paramData
     // 4. HTTP 메세지 헤더 설정
     request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
     request.setValue(String(paramData!.count), forHTTPHeaderField: "Content-Length")
     
     // 5. URLSession 객체를 통해 전송 및 응답값 처리 로직 작성
     
     let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
     
     // 5-1. 서버가 응답이 없거나 통신이 실패했을 때
     if let e = error {
     NSLog("An error has occurred : \(e.localizedDescription)")
     return
     }
     print("Response Data=\(String(data: data!, encoding: .utf8)!)")
     // 5-2. 응답 처리 로직이 여기에 들어갑니다.
     // 1) 메인 스레드에서 비동기로 처리되도록 한다.
     DispatchQueue.main.async(){
     do {
     let object = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
     guard let jsonObject = object else { return }
     // 2) JSON 결과값을 추출한다.
     let result = jsonObject["result"] as? String
     let timestamp = jsonObject["timestamp"] as? String
     let userId = jsonObject["userId"] as? String
     let name = jsonObject["name"] as? String
     
     // 3) 결과가 성공일 때에만 텍스트 뷰에 출력한다.
     if result == "SUCCESS" {
     
     self.responseView.text = "아이디 : \(userId!)" + "\n"
     + "이름 : \(name!)" + "\n"
     + "응답결과 : \(result!)" + "\n"
     + "응답방식 : \(timestamp!)" + "\n"
     + "요청방식 : x-www-form-urlencoded"
     }
     } catch let e as NSError {
     print ("An error has occurred while parsing JSONObject : \(e.localizedDescription)")
     }
     }
     }
     
     // 6. POST 전송
     
     task.resume()
     
     }
     @IBAction func json(_ sender: UIButton) {
     // 1. 전송할 값 준비
     let userId = (self.userId.text)!
     let name = (self.name.text)!
     let param = ["userId" : userId, "name" : name] // JSON 객체로 변환할 딕셔너리 준비
     let paramData = try! JSONSerialization.data(withJSONObject: param, options: [])
     // 2. URL 객체 정의
     let url = URL(string: "http://swiftapi.rubypaper.co.kr:2029/practice/echoJSON")
     // 3. URLRequest 객체 정의 및 요청 내용 담기
     var request = URLRequest(url: url!)
     request.httpMethod = "POST"
     request.httpBody = paramData
     // 4. HTTP 메세지에 포함될 헤더 설정
     request.addValue("application/json", forHTTPHeaderField: "Content-Type")
     request.setValue(String(paramData.count), forHTTPHeaderField: "Content-Length")
     // 5. URLSession 객체를 통해 전송 및 응답값 처리 로직 작성
     let task = URLSession.shared.dataTask(with: request) { (data, response, error ) in
     // 5-1. 서버가 응답이 없거나 통신이 실패했을 때
     if let e = error {
     NSLog("An error has occurred : \(e.localizedDescription)")
     return
     
     }
     print("Response Data=\(String(data: data!, encoding: .utf8)!)")
     
     // 5-2. 응답 처리 로직이 여기에 들어갑니다.
     // 1) 메인 스레드에서 비동기로 처리되도록 한다.
     DispatchQueue.main.async(){
     do {
     let object = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
     guard let jsonObject = object else { return }
     // 2) JSON 결과값을 추출한다.
     let result = jsonObject["result"] as? String
     let timestamp = jsonObject["timestamp"] as? String
     let userId = jsonObject["userId"] as? String
     let name = jsonObject["name"] as? String
     // 3) 결과가 성공일 때에만 텍스트 뷰에 출력한다.
     if result == "SUCCESS" {
     self.responseView.text = "아이디 : \(userId!)" + "\n"
     + "이름 : \(name!)" + "\n"
     + "응답결과 : \(result!)" + "\n"
     + "응답방식 : \(timestamp!)" + "\n"
     + "요청방식 : application/json"
     
     }
     } catch let e as NSError {
     print ("An error has occurred while parsing JSONObject : \(e.localizedDescription)")
     }
     }
     }
     // 6. POST 전송
     task.resume()
     
     }
     
     }
     */
}
extension LoginViewController: UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 100{
           
        }
        else if textField.tag == 101{
            
        }
        self.activeTextField = textField
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
          self.activeTextField = nil
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag == 100{
        }
        else if textField.tag == 101{
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 100{
            print(range.length - range.location)
            if (range.length - range.location) <= 0{

                loginButton.isHidden = false
                signup.isHidden = true
            }else{
                
                loginButton.isHidden = true
                signup.isHidden = false
            }
            
        }
        else if textField.tag == 101{
            
        }
        return true
    }
}
extension UITextField {
    func addBottomBorder(){
        self.translatesAutoresizingMaskIntoConstraints = false
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 2, width: self.frame.size.width, height: 2)
        bottomLine.backgroundColor = UIColor.yellow.cgColor
        borderStyle = .none
        layer.addSublayer(bottomLine)
        
    }
}
