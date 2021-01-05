//
//  SignUpViewController.swift
//  daview
//
//  Created by ksb on 31/07/2019.
//  Copyright © 2019 ksb. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
class SignUpViewController: UIViewController {
    
    var activityindi : ActivityIndicator!
     var activeTextField : UITextField? = nil
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var userId: UITextField!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var asignTitle: UILabel!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordComplate: UITextField!
    @IBOutlet weak var signe: UIButton!
    override func viewDidLoad(){
        
        super.viewDidLoad()
        self.asignTitle.text = Util.localString(st: "ph_join_now")
        self.userId.placeholder = Util.localString(st: "ph_user_id")
        self.emailAddress.placeholder = Util.localString(st:"ph_user_pwd_email")
        self.password.placeholder = Util.localString(st:"ph_user_pwd")
        self.passwordComplate.placeholder = Util.localString(st: "ph_user_pwd_comp")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        // Do any additional setup after loading the view.
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
           let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY
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
    @IBAction func closeLoginView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func tabAction(_ sender: Any) {
        view.endEditing(true)
    }
    @IBAction func backButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion:nil)
    }
    @IBAction func signAction(_ sender: Any) {
        if checkEmailid() == false{
           let alert = UIAlertController(title: Util.localString(st: "alert"), message:Util.localString(st: "signup_email_input"), preferredStyle: .alert)
           let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
           }
           alert.addAction(OKAction)
           self.present(alert, animated: true, completion: nil)
        }
        else{
            if checkPassword() == -100{
               let alert = UIAlertController(title: Util.localString(st: "alert"), message:Util.localString(st: "signup_pwc_input"), preferredStyle: .alert)
               let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
               }
               alert.addAction(OKAction)
               self.present(alert, animated: true, completion: nil)
            }else if  checkPassword() == -101{
                let alert = UIAlertController(title: Util.localString(st: "alert"), message:Util.localString(st: "signup_pw_input"), preferredStyle: .alert)
                let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
                }
                alert.addAction(OKAction)
                self.present(alert, animated: true, completion: nil)
                
            }else if checkPassword() == 0{
                reqSignup()
            }
        }
    }
}
extension SignUpViewController:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
        if textField == userId{
            
        }
        else if textField == emailAddress{
        }
        else{
            if checkEmailid() == false{
                let alert = UIAlertController(title: Util.localString(st: "alert"), message:Util.localString(st: "signup_email_input"), preferredStyle: .alert)
                let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
                }
                alert.addAction(OKAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
         self.activeTextField = nil
    }
    private func textFieldShouldReturn(_ textField: UITextField){
        if checkPassword() == -100{
            
            let alert = UIAlertController(title: Util.localString(st: "alert"), message:Util.localString(st: "signup_pwc_input"), preferredStyle: .alert)
            let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
            }
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
            
        }
        else if  checkPassword() == -101{
            let alert = UIAlertController(title: Util.localString(st: "alert"), message: Util.localString(st:"signup_pw_input"), preferredStyle: .alert)
            let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
            }
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
            
        }
        else if checkPassword() == 0{
            reqSignup()
        }
    }
    func reqSignup(){
        if(checkEmailid()){
            activityindi = ActivityIndicator(view: self.view,navigationController: self.navigationController,tabBarController: nil)
            activityindi.showActivityIndicator(text:"")
            var parameters: [String: Any] = [:]
            parameters["id"]    = userId.text
            parameters["email"]    = emailAddress.text
            parameters["pw"] = password.text
            parameters["timezone"] = Util.timeZoneOffsetInHours()
            parameters["language"] = Util.getlan()
            print(parameters)
            Alamofire.request(Constant.VRFIT_MEMBER_SIGNUP_ADDRESS, method: .post, parameters:parameters, encoding:URLEncoding.httpBody)
                .responseJSON { response in
                    self.activityindi.stopActivityIndicator()
                    switch(response.result) {
                    case.success:
                        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8){
                            print("Data: \(utf8Text)") // original server data as UTF8 string
                            do{
                                // Get json data
                                let json = try JSON(data: data)
                                if let reqcode = json["result"].string{
                                    if(reqcode == "SUCCESS"){
                                        let alertVodDownvc =  (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AlertSignUpVC") as! AlertSignUpVC)
                                        //loginViewConroller.delegate = self
                                        self.view.addSubview(alertVodDownvc.view)
                                        self.addChild(alertVodDownvc)
                                        alertVodDownvc.didMove(toParent: self)
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
            let alert = UIAlertController(title: Util.localString(st: "alert"), message:Util.localString(st: "signup_email_input"), preferredStyle: .alert)
            let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
            }
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 100{
        }
        else if textField.tag == 101{
        }
        return true
    }
    func checkEmailid()->Bool{
        let emailReg = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailReg)
        if  emailTest.evaluate(with: self.emailAddress.text) == false {
            return false
        }
        else{
            return true
        }
    }
    func checkPassword()->Int{
        if self.password.text!.count<4||self.passwordComplate.text!.count<4{
            return -101
        }
        if self.password.text != self.passwordComplate.text{
            return -100
        }
        return 0
    }
    
}
