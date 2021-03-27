//
//  ViewController.swift
//  cycle
//
//  Created by SSG on 2020/11/23.
import UIKit
import SideMenu
import Alamofire
import SwiftyJSON
import Charts
import UnityFramework
import CoreBluetooth

enum GameMode{
    case gameLobby
    case countdown
    case gameStart
    case gameEnd
}
enum AltMode{
    case BATTERY
    case NONMUSIC
}
class ViewController: UIViewController, UINavigationControllerDelegate,ChartViewDelegate,CBCentralManagerDelegate,CBPeripheralDelegate{
    var logo : UIView!
    var menu:SideMenuNavigationController?
    var loginViewConroller : LoginViewController!
    var alertVodDownvc : AlertVodDownVC!
    @IBOutlet weak var progressBar: UIProgressView!
    //뒤집어
    @IBOutlet weak var complateVal: UILabel!
    @IBOutlet weak var countLabelVal: UILabel!
    @IBOutlet weak var pointVal: UILabel!
    @IBOutlet weak var useridVal: UILabel!
    
    @IBOutlet weak var complate: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var point: UILabel!
    @IBOutlet weak var userid: UILabel!
    @IBOutlet weak var goLeftMenu: UIButton!
    
    @IBOutlet weak var addSensor: UIButton!
    @IBOutlet weak var startGame: UIButton!
    @IBOutlet weak var todayPerCent: UILabel!
    
    //하단정보
    @IBOutlet weak var todayHealthTime: UILabel!
    @IBOutlet weak var todayHealthTimeVal: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var distanceVal: UILabel!
    @IBOutlet weak var calories: UILabel!
    @IBOutlet weak var caloriesVal: UILabel!
    
    @IBOutlet weak var star0: UIImageView!
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    
    //차트관련 정보
    @IBOutlet weak var chartView: BarChartView!
    var levelValue = [Int]()
    var currentDate : Date = Date()
    var dayCount : Int = 0
    var currentDay : String!
    var day = [String]()
    var monthRecord : [String:AnyObject] = [:]
    var dayExTime:Int = 0
    
    
    var darkView : UIView?
    var bodyView : UIView?
    
    // MARK: ===============================블루투스 변수======================================
    var manager:CBCentralManager? = nil
    var leftPeripheral:CBPeripheral? = nil
    var rightPeripheral:CBPeripheral? = nil
    var leftPeripheral_Connect:Bool? = false
    var rightPeripheral_Connect:Bool? = false
    var leftSaveTime :Int64 = 0
    var rightSaveTime : Int64 = 0
    var mainCharacteristic:CBCharacteristic? = nil
    var connectBlock: DispatchWorkItem?
    var block: DispatchWorkItem?
    var app : AppDelegate?
    
    //MARK : ===============================유니티 전달 값======================================
    var sendData : [MusicInfo] = []
    var timeStop : Bool = false
    var mScene : Int = 0
    var mMoviePath : String = ""
    var mKPC : Int!
    var isPlayWithoutMusic : Bool = false
    var circleRighLleft : Bool = false
    var footRighLleft : Bool =  false
    var timer: DispatchSourceTimer!
    var musciInfo : [MusicInfo] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Util.copyDatabase("box.db")
        menu = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
        menu?.leftSide = true
        menu?.setNavigationBarHidden(true, animated: false)
        menu?.settings = makeSettings()
        manager = CBCentralManager(delegate: self, queue: nil)
        SideMenuManager.default.leftMenuNavigationController = menu
        logo = (Bundle.main.loadNibNamed("logoView", owner: self, options: nil)![0] as! UIView)
        logo.frame = self.view.frame
        self.view.addSubview(logo)
        let tapGestureRecognizerLevel = UITapGestureRecognizer(target: self, action: #selector(gotoLevelSetting(_:)))
        let tapGestureRecognizerPoint = UITapGestureRecognizer(target: self, action: #selector(gotoPoint))
        pointVal.addGestureRecognizer(tapGestureRecognizerPoint)
        countLabelVal.addGestureRecognizer(tapGestureRecognizerLevel)
        self.chartInit()
        checkVersion()
    }
    override func viewWillAppear(_ animated: Bool) {
        UserDefaults.standard.string(forKey: "BleUUID")
        super.viewWillAppear(true)
        //bluetoothManager.delegate = self
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    }
    @objc func gotoPoint(){
        
        let board = UIStoryboard(name: "Main", bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: "CycleWebViewController") as! CycleWebViewController
        vc.url = URL(string:"https://www.m2me.co.kr:6443/setting/MainContent/exrecise_get_point.jsp")
        vc.pop = popmode.modal
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    @objc func gotoLevelSetting(_ gesture: UITapGestureRecognizer){
        
        let board = UIStoryboard(name: "Main", bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: "SettingLevelViewController") as! SettingLevelViewController
        vc.modalPresentationStyle = .overFullScreen
        vc.sourceVc = self
        vc.levelValue = self.levelValue
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func addSensorAction(_ sender: Any) {
        let board = UIStoryboard(name: "Main", bundle: nil)
        if self.leftPeripheral != nil{
            
            let vc = board.instantiateViewController(withIdentifier: "AlertCalorieSetVC") as! AlertCalorieSetVC
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
        else{
            let vc = board.instantiateViewController(withIdentifier: "ScanTableViewController") as! ScanTableViewController
            vc.parentView = self
            manager?.delegate = vc
            vc.manager = manager
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    func showDarkView(){
        if (darkView == nil) {
            darkView = UIView()
            let rect = CGRect.init(x: self.view.bounds.origin.x, y: self.view.bounds.origin.y, width: self.view.bounds.size.width, height:UIApplication.shared.statusBarFrame.size.height +
                                    (self.navigationController?.navigationBar.frame.height ?? 0.0))
            if let dv = darkView {
                dv.frame = rect
                dv.backgroundColor = .black
                dv.alpha = 0.7
                self.navigationController?.view.addSubview(darkView!)
            }
            bodyView = UIView()
            bodyView!.frame = self.view.bounds
            bodyView!.backgroundColor = .black
            bodyView!.alpha = 0.7
            self.view.addSubview(bodyView!)
        }
        else{
            darkView!.removeFromSuperview()
            darkView=nil
            bodyView!.removeFromSuperview()
            bodyView=nil
        }
    }
    
    
    func showAlert(style: UIAlertController.Style,text:String,alt_mode:AltMode){
        
        let alert = UIAlertController(title: Util.localString(st: "alert"), message:text, preferredStyle: style)
        let success = UIAlertAction(title: Util.localString(st: "ok"), style: .default){ (action) in
            print(Util.localString(st: "ok"))
            switch(alt_mode){
            case .BATTERY:
                self.showDarkView()
                if UserDefaults.standard.bool(forKey:"checkBox") != true{
                    self.performSegue(withIdentifier: "tutorial_segue", sender: 0)
                }else{
                    
                }
            case .NONMUSIC:
                print("")
            }
        }
        alert.addAction(success)
        self.present(alert, animated:true,completion:nil)
    }
    @IBAction func startGameAction(_ sender: Any) {
        
        if self.leftPeripheral != nil{
            self.connectLeftBle()
        }
        
        // self.showDarkView()
        
        
        //        let vc = storyboard?.instantiateViewController(withIdentifier: "VodListController") as! VodListController
        //        vc.modalPresentationStyle = .overFullScreen
        //        self.present(vc, animated: true, completion: nil)
        
        /*
         if self.leftPeripheral != nil{
         
         self.connectLeftBle()
         
         //            if(self.sendData.count > 0){
         //                self.connectLeftBle()
         //            }else{
         //                showAlert(style: .alert, text:Util.localString(st: "empty_music_warning"),alt_mode: .NONMUSIC)
         //            }
         }
         else {
         Util.Toast.show(message: Util.localString(st: "empty_sensor"), controller: self)}*/
        //UnityEmbeddedSwift.showUnity(self , self)
    }
    func leveTextReflash(){
        self.countLabelVal.text = getLevel()
        //      그래프 리미터 라인 그리기
        //      let savelevel = UserDefaults.standard.integer(forKey: "level")
        //      let ll = ChartLimitLine(limit: Double(savelevel/60), label: "목표운동시간")
        //      ll.labelPosition = .topLeft
        //      chartView.leftAxis.addLimitLine(ll)
    }
    func updateStar(level:Int){
        star0.image = UIImage(named:"target_percent_star_n")
        star1.image = UIImage(named:"target_percent_star_n")
        star2.image = UIImage(named:"target_percent_star_n")
        star3.image = UIImage(named:"target_percent_star_n")
        star4.image = UIImage(named:"target_percent_star_n")
        switch level {
        case 20...39:
            star0.image = UIImage(named:"target_percent_star_p")
            break
        case 40...59:
            star0.image = UIImage(named:"target_percent_star_p")
            star1.image = UIImage(named:"target_percent_star_p")
            break
        case 60...79:
            star0.image = UIImage(named:"target_percent_star_p")
            star1.image = UIImage(named:"target_percent_star_p")
            star2.image = UIImage(named:"target_percent_star_p")
            break
        case 80...99:
            star0.image = UIImage(named:"target_percent_star_p")
            star1.image = UIImage(named:"target_percent_star_p")
            star2.image = UIImage(named:"target_percent_star_p")
            star3.image = UIImage(named:"target_percent_star_p")
            break
        case 100:
            star0.image = UIImage(named:"target_percent_star_p")
            star1.image = UIImage(named:"target_percent_star_p")
            star2.image = UIImage(named:"target_percent_star_p")
            star3.image = UIImage(named:"target_percent_star_p")
            star4.image = UIImage(named:"target_percent_star_p")
            break
        default:
            break
        }
    }
    func getLevel()->String{
        let getlevel = UserDefaults.standard.integer(forKey: "level")
        var levelString : String=""
        switch(getlevel){
        case levelValue[0]:
            levelString = "1"
            break
        case levelValue[1]:
            levelString = "2"
            break
        case levelValue[2]:
            levelString = "3"
            break
        case levelValue[3]:
            levelString = "4"
            break
        case levelValue[4]:
            levelString = "5"
            break
        default: break
            
        }
        return levelString
    }
    private func makeSettings() -> SideMenuSettings{
        var presentationStyle = SideMenuPresentationStyle()
        presentationStyle = .menuSlideIn
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
    @IBAction func goLeftMenu(_ sender: Any) {
        self.navigationController!.present(menu!, animated: true, completion: nil)
    }
    func checkVersion(){
        var parameters: [String: Any] = [:]
        parameters["version"]    =  "0.0.2"//Util.getAppversion()
        print(parameters)
        let afmanager = Alamofire.SessionManager.default
        afmanager.session.configuration.timeoutIntervalForRequest = 15
        afmanager.request(Constant.VRFIT_VERSION_CHECK, method: .post, parameters:parameters, encoding:URLEncoding.httpBody)
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
    //let storeViewController = SKStoreProductViewController()
    //storeViewController.delegate = self
    //    // 앱스토어에 있는 앱 id값으로 연결된 SKStoreProductParameterITunesItemIdentifier 키로 초기화
    //    let parameters = [SKStoreProductParameterITunesItemIdentifier: 1085123968]
    //    // 뷰 컨트롤러에 로드 되고 성공하면 표시된다.
    //        storeViewController.loadProduct(withParameters: parameters, completionBlock: {result, error in
    //        if result {
    //            self.present(storeViewController, animated: true, completion: nil)
    //        }
    //    })
    //}
    //  달성일수 및 현제 포인터
    func getexerciseAchivement(){
        var parameters: [String: Any] = [:]
        parameters["id"] = UserDefaults.standard.string(forKey: "userid")
        Alamofire.request(Constant.VRFIT_MEMBER_DATA_ACHIVE, method: .post, parameters:parameters, encoding:URLEncoding.httpBody)
            .responseJSON { response in
                switch(response.result) {
                case.success:
                    if let data = response.data, let _ = String(data: data, encoding: .utf8){
                        //print("Data: \(utf8Text)") // original server data as UTF8 string
                        do{
                            // Get json data
                            let json = try JSON(data: data)
                            print("getexerciseAchivement"+"\(json)")
                            if let reqcode = json["result"].string{
                                if(reqcode == "SUCCESS"){
                                    if let data = json["data"].dictionary{
                                        if let achivement = data["achivement"]?.int{
                                            self.complateVal.text = String(achivement)
                                        }
                                        if let point = data["point"]?.int{
                                            self.pointVal.text = String(point)
                                        }
                                    }
                                }
                                else{
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
                    } else if error is URLError {
                        let alert = UIAlertController(title: Util.localString(st: "alert"), message: Util.localString(st:"wifi_fail"), preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
                        }
                        alert.addAction(OKAction)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        print("Unknown error: \(error)")
                    }
                }
            }
    }
    /**
     *@brief 오늘운동 기록 요청
     *
     *
     */
    func getTodayExerciseRecord(){
        var parameters: [String: Any] = [:]
        parameters["id"] = UserDefaults.standard.string(forKey: "userid")
        parameters["timezone"] = Util.timeZoneOffsetInHours()
        Alamofire.request(Constant.VRFIT_MEMBER_TODAY_RECORD, method: .post, parameters:parameters, encoding:URLEncoding.httpBody)
            .responseJSON { [self] response in
                
                switch(response.result) {
                case.success(let value):
                    let json = JSON(value)
                    if let record = json["result"].string{
                        if(record=="SUCCESS"){
                            print("getTodayExerciseRecord"+"\(json)")
                            if let data = json["data"].dictionary{
                                if let excal = data["ex_kcal"]?.int{
                                    self.caloriesVal.text = String(format: "%@kcal",String(excal))
                                    let attributedString = NSMutableAttributedString(string: self.caloriesVal.text!)
                                    let fontSize = UIFont.boldSystemFont(ofSize:20)
                                    attributedString.addAttribute(NSAttributedString.Key.font, value: fontSize, range:  ( self.caloriesVal.text! as NSString).range(of:"kcal"))
                                    self.caloriesVal.attributedText = attributedString
                                }
                                if let extime = data["ex_time"]?.int{
                                    if extime != 0{
                                        self.dayExTime = extime
                                        let savelebel = UserDefaults.standard.integer(forKey:"lebel")
                                        if savelebel != 0{
                                            self.updateStar(level: savelebel / self.dayExTime)
                                            self.todayPerCent.text = "\((self.dayExTime/savelebel)*100)"+"%"
                                            self.progressBar.progress = Float(Int(self.dayExTime / savelebel))
                                        }
                                        let time = extime/60
                                        self.todayHealthTimeVal.text = "\(time)"+"Min"
                                        let attributedString = NSMutableAttributedString(string: self.todayHealthTimeVal.text!)
                                        let color = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
                                        let fontSize = UIFont.boldSystemFont(ofSize: 25)
                                        attributedString.addAttribute(NSAttributedString.Key.font, value: fontSize, range:  ( self.todayHealthTimeVal.text! as NSString).range(of:"Min"))
                                        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value:color, range: (self.todayHealthTimeVal.text! as NSString).range(of:"Min"))
                                        self.todayHealthTimeVal.adjustsFontSizeToFitWidth = true
                                        self.todayHealthTimeVal.minimumScaleFactor = 0.5
                                        self.todayHealthTimeVal.attributedText = attributedString
                                    }
                                }
                                if let distance = data["ex_distance"]?.float{
                                    let hit = String(format: "%.2f", distance)
                                    self.distanceVal.text = "\(hit)" + "km"
                                    let attributedString = NSMutableAttributedString(string: self.distanceVal.text!)
                                    let fontSize = UIFont.boldSystemFont(ofSize:20)
                                    attributedString.addAttribute(NSAttributedString.Key.font, value: fontSize, range:  ( self.distanceVal.text! as NSString).range(of:"km"))
                                    self.distanceVal.adjustsFontSizeToFitWidth = true
                                    self.distanceVal.minimumScaleFactor = 0.5
                                    self.distanceVal.attributedText = attributedString
                                }
                            }
                            if let level = json["goal_data"].dictionary{
                                for (_,value) in level{
                                    let data = value["ex_count"].int
                                    self.levelValue.append(data!)
                                }
                                self.levelValue.sort()
                            }
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
                    } else if error is URLError {
                        let alert = UIAlertController(title: Util.localString(st: "alert"), message: Util.localString(st:"wifi_fail"), preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
                        }
                        alert.addAction(OKAction)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        print("Unknown error: \(error)")
                    }
                }
            }
    }
    func mainScreenSet(){
        
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
        getexerciseAchivement()
        self.useridVal.text = UserDefaults.standard.string(forKey: "userid")
        getTodayExerciseRecord()
        currentDay = self.calMounth(direction: 0)
        dayCal(value: currentDay)
        getexerciseMonthlyRecord(month: self.calMounth(direction:0))

        musciInfo = DatabaseManager.getInstance().selectMusic()
        
    }
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
                                        self.mainScreenSet()
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
    //MARK - 차트관련 함수
    func calMounth(direction : Int)->String{
        currentDate = Calendar.current.date(byAdding: .month, value: direction, to: self.currentDate)!
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM"
        let formattedDate = format.string(from: currentDate)
        return formattedDate
    }
    @IBAction func arrowLeftAction(_ sender: Any) {
        DispatchQueue.main.async{
            let val = self.calMounth(direction: -1)
            self.monthRecord.removeAll()
            self.dayCal(value : val)
            self.monthRecord.removeAll()
            self.getexerciseMonthlyRecord(month: val)
        }
    }
    @IBAction func arrowRightAction(_ sender: Any) {
        let nextMonth = self.calMounth(direction: 1)
        if currentDay <  nextMonth {
            _ = self.calMounth(direction: -1)
            Util.Toast.show(message: Util.localString(st:"graph_recent_warning"), controller:self)
            return
        }
        DispatchQueue.main.async{
            self.monthRecord.removeAll()
            self.dayCal(value : nextMonth)
            self.monthRecord.removeAll()
            self.getexerciseMonthlyRecord(month:nextMonth)
        }
    }
    // MARK: Chart
    func dayCal(value : String){
        let param = value.components(separatedBy: "-")
        dayCount = Util.getTotalDate(year: Int(param[0])!, month: Int(param[1])!)
        day.removeAll()
        for x in 0..<dayCount{
            day.append(String(x))
        }
    }
    func chartInit(){
        chartView.animate(yAxisDuration: 1.0)
        chartView.pinchZoomEnabled = false
        chartView.drawBarShadowEnabled = false
        chartView.drawBordersEnabled = false
        chartView.doubleTapToZoomEnabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        self.chartView.legend.enabled = false
    }
    //MARk:Chart
    func updateChartData() {
        self.setChartData()
    }
    func setChartData() {
        self.chartInit()
        let data = generateBarData()
        //data.lineData = generateLineData()
        chartView.data = data
    }
    func generateLineData() -> LineChartData {
        let entries = (0..<dayCount).map { (i) -> ChartDataEntry in
            let key = String(i)
            if  self.monthRecord[key] != nil{
                let value:MonthRecord = self.monthRecord[key] as! MonthRecord
                return ChartDataEntry(x: Double(i) + 0.5, y: Double(value.ex_kcal))
            }
            else {return ChartDataEntry(x: Double(i) + 0.5, y: 0.0)}
        }
        let set = LineChartDataSet(entries: entries, label: "Kal")
        set.setColor(UIColor(red: 241/255, green: 141/255, blue: 16/255, alpha: 1))
        set.lineWidth = 2.5
        set.setCircleColor(UIColor(red: 241/255, green: 141/255, blue: 16/255, alpha: 1))
        set.circleRadius = 5
        set.circleHoleRadius = 2.5
        set.fillColor = UIColor(red: 241/255, green: 141/255, blue: 16/255, alpha: 1)
        set.mode = .cubicBezier
        set.drawValuesEnabled = true
        set.valueFont = .systemFont(ofSize: 10)
        set.valueTextColor = UIColor(red: 241/255, green: 141/255, blue: 16/255, alpha: 1)
        set.axisDependency = .right
        return LineChartData(dataSet: set)
    }
    func generateBarData() -> BarChartData {
        var barColor : [UIColor] = []
        let entries1 = (1..<dayCount+1).map { (i) -> BarChartDataEntry in
            let key = String(i)
            if  self.monthRecord[key] != nil{
                let value:MonthRecord = self.monthRecord[key] as! MonthRecord
                
                return BarChartDataEntry(x: Double(i), y: Double(value.ex_time))
            }
            else {return BarChartDataEntry(x: Double(i), y:0.0)}
        }
        let set1 = BarChartDataSet(entries: entries1,label:"운동시간")
        //TODO: 그래프 운동시간 달성 변수 채워 줘야함
        let saveData = UserDefaults.standard.integer(forKey: "level")/60
        for val in set1{
            if Int(val.y) < saveData  {
                barColor.append(#colorLiteral(red: 0.4862297177, green: 0.4863032103, blue: 0.4862136245, alpha: 1))
            }else {
                barColor.append(#colorLiteral(red: 0.4542920589, green: 0.8233559728, blue: 0.8838157654, alpha: 1))
            }
        }
        set1.colors = barColor
        set1.drawValuesEnabled = false
        // (0.45 + 0.02) * 2 + 0.06 = 1.00 -> interval per "group"
        let data = BarChartData(dataSets: [set1])
        // data.barWidth = barWidth
        // make this BarData object grouped
        //data.groupBars(fromX: 0, groupSpace: groupSpace, barSpace: barSpace)
        return data
    }
    func generateScatterData() -> ScatterChartData {
        let entries = stride(from: 0.0, to: Double(dayCount), by: 0.5).map { (i) -> ChartDataEntry in
            return ChartDataEntry(x: i+0.25, y: Double(arc4random_uniform(10) + 55))
        }
        let set = ScatterChartDataSet(entries: entries, label: "Scatter DataSet")
        set.colors = ChartColorTemplates.material()
        set.scatterShapeSize = 4.5
        set.drawValuesEnabled = false
        set.valueFont = .systemFont(ofSize: 10)
        return ScatterChartData(dataSet: set)
    }
    func generateCandleData() -> CandleChartData {
        let entries = stride(from: 0, to: dayCount, by: 2).map { (i) -> CandleChartDataEntry in
            return CandleChartDataEntry(x: Double(i+1), shadowH: 90, shadowL: 70, open: 85, close: 75)
        }
        let set = CandleChartDataSet(entries: entries, label: "Candle DataSet")
        set.setColor(UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1))
        set.decreasingColor = UIColor(red: 142/255, green: 150/255, blue: 175/255, alpha: 1)
        set.shadowColor = .darkGray
        set.valueFont = .systemFont(ofSize: 10)
        set.drawValuesEnabled = false
        return CandleChartData(dataSet: set)
    }
    func generateBubbleData() -> BubbleChartData {
        let entries = (0..<dayCount).map { (i) -> BubbleChartDataEntry in
            return BubbleChartDataEntry(x: Double(i) + 0.5,
                                        y: Double(arc4random_uniform(10) + 105),
                                        size: CGFloat(arc4random_uniform(50) + 105))
        }
        let set = BubbleChartDataSet(entries: entries, label: "Bubble DataSet")
        set.setColors(ChartColorTemplates.vordiplom(), alpha: 1)
        set.valueTextColor = .white
        set.valueFont = .systemFont(ofSize: 10)
        set.drawValuesEnabled = true
        return BubbleChartData(dataSet: set)
    }
    func getexerciseMonthlyRecord(month:String){
        var parameters: [String: Any] = [:]
        parameters["id"] = UserDefaults.standard.string(forKey: "userid")
        parameters["month"]  = month
        Alamofire.request(Constant.VRFIT_MEMBER_MONTH_RECORD, method: .post, parameters:parameters, encoding:URLEncoding.httpBody)
            .responseJSON { [self] response in
                switch(response.result) {
                case.success:
                    if let data = response.data, let _ = String(data: data, encoding: .utf8){
                        //print("Data: \(utf8Text)") // original server data as UTF8 string
                        do{
                            let json = try JSON(data: data)
                            print("getexerciseMonthlyRecord"+"\(json)")
                            if let reqcode = json["result"].string{
                                if(reqcode == "SUCCESS"){
                                    if let data = json["data"].dictionary{
                                        for element in data {
                                            let valueList : MonthRecord = MonthRecord()
                                            let value = element.value
                                            if let ex_count = value["ex_count"].int{
                                                valueList.ex_count = ex_count
                                            }
                                            if let ex_kcal = value["ex_kcal"].int{
                                                valueList.ex_kcal = ex_kcal
                                            }
                                            if let ex_time = value["ex_time"].int{
                                                
                                                valueList.ex_time = ex_time/60
                                            }
                                            self.monthRecord[element.key] = valueList
                                        }
                                        self.updateChartData()
                                    }
                                }
                                else{
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
                    } else if error is URLError {
                        let alert = UIAlertController(title: Util.localString(st: "alert"), message: Util.localString(st:"wifi_fail"), preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
                        }
                        alert.addAction(OKAction)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        print("Unknown error: \(error)")
                    }
                }
            }
    }
    func connectLeftBle(){
        if self.leftPeripheral?.state == .connected{
            return
        }
        
        Util.Toast.show(message: "Starting...", controller: self)
        self.leftPeripheral?.delegate = self
        self.manager?.connect(self.leftPeripheral!,options: [:])
        if self.connectBlock != nil{
            self.connectBlock!.cancel()
        }
        self.connectBlock = DispatchWorkItem {
            self.timeOutbleResponse()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(15), execute: self.connectBlock!)
        
    }
    //MARK - 블루투스 관련 함수 모음
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("didFailToConnect")
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //pass reference to connected peripheral to parent view
        self.connectBlock?.cancel()
        print(peripheral)
        if leftPeripheral == peripheral{
            leftPeripheral!.discoverServices(nil)
            // peripheral.delegate = parentView
            // peripheral.discoverServices(nil)
            // set the manager's delegate view to parent so it can call relevant disconnect methods
            // manager?.delegate = parentView
        }
        else if rightPeripheral == peripheral{
            rightPeripheral!.discoverServices(nil)
            //  peripheral.delegate = parentView
            //  peripheral.discoverServices(nil)
            //  set the manager's delegate view to parent so it can call relevant disconnect methods
            //  manager?.delegate = parentView
        }
    }
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        if central.state == .poweredOn {
            if let peripheralIdStr = UserDefaults.standard.object(forKey: "BleUUID") as? String,let peripheralId = UUID(uuidString: peripheralIdStr),
               let previouslyConnected = manager!.retrievePeripherals(withIdentifiers: [peripheralId])
                .first {
                self.leftPeripheral = previouslyConnected
                // Next, try for ones that are connected to the system:
            }
            
        }
        else if central.state == .poweredOff {
            
            let alert = UIAlertController(title:Util.localString(st: "alert"), message: Util.localString(st: "ble_turn_off"), preferredStyle: .alert)
            let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
            }
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            print("Service found with UUID: " + service.uuid.uuidString)
            if (service.uuid.uuidString == Constant.RECIEVE_DATA_SERVICE_TEST) {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            //Bluno Service
            else if (service.uuid.uuidString == Constant.SEND_DATA_SERVICE_TEST) {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("didDiscoverCharacteristicsFor")
        if (service.uuid.uuidString ==   Constant.RECIEVE_DATA_SERVICE_TEST) {
            for characteristic in service.characteristics! {
                if characteristic.uuid.uuidString == Constant.RECIEVE_DATA_CHARACTERISTIC {
                    peripheral.setNotifyValue(true, for: characteristic)
                    break
                }
            }
        }
        else if (service.uuid.uuidString == Constant.SEND_DATA_SERVICE_TEST) {
            for characteristic in service.characteristics! {
                if characteristic.uuid.uuidString == Constant.SEND_DATA_CHARACTERISTIC {
                    peripheral.setNotifyValue(true, for: characteristic)
                    mainCharacteristic = characteristic
                    break
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print("Constant.CMD_INIT_MODULE")
                self.sendProtocol(peripheral: peripheral ,type: 0,cmd: Constant.CMD_INIT_MODULE, what: 0)
            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if(error != nil){
            let alert = UIAlertController(title:Util.localString(st: "alert"), message: Util.localString(st: "connect_with_sensor_failed"), preferredStyle: .alert)
            let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
            }
            alert.addAction(OKAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        //TODO: 유니티 프로그램이 실행중일때 앱 종료
        //exit(0)
        
    }
    func timeOutbleResponse(){
        
        let alert = UIAlertController(title:Util.localString(st: "alert"), message: Util.localString(st: "connect_with_sensor_failed"), preferredStyle: .alert)
        let OKAction = UIAlertAction(title: Util.localString(st: "ok"), style: .default) {(action:UIAlertAction!) in
            if self.leftPeripheral != nil{
                self.manager?.cancelPeripheralConnection(self.leftPeripheral!)
            }
            if self.rightPeripheral != nil{
                self.manager?.cancelPeripheralConnection(self.rightPeripheral!)
            }
        }
        alert.addAction(OKAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    func sendProtocol(peripheral:CBPeripheral,type:UInt8,cmd : UInt8,what :UInt8) -> Void{
        
        /*
         @IBAction func go(_ sender: Any) {
         let vc2 = VC2()
         self.navigationController?.pushViewController(vc2, animated: true)
         }
         override func viewDidLoad() {
         super.viewDidLoad()
         self.view.backgroundColor = .white
         }
         override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
         }
         // execute task in 2 seconds
         DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: self.block!)
         }
         */
        var data:[UInt8]=[]
        switch (cmd){
        case Constant.CMD_INIT_MODULE:
            if self.block != nil{
                self.block!.cancel()
            }
            self.block = DispatchWorkItem {
                self.timeOutbleResponse()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(15), execute: self.block!)
            data.append(Constant.STX)
            data.append(0)
            data.append(0)
            data.append(cmd)
            data.append(Constant.ETX)
            let writeData =  Data(data)
            peripheral.writeValue(writeData, for:mainCharacteristic!, type: .withResponse)
            break
        case Constant.CMD_SENSOR_TYPE:
            if self.block != nil{
                self.block!.cancel()
            }
            self.block = DispatchWorkItem {
                self.timeOutbleResponse()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(15), execute: self.block!)
            data = [Constant.STX,0,type,cmd,Constant.ETX]
            let writeData =  Data(data)
            peripheral.writeValue(writeData, for:mainCharacteristic!, type: .withResponse)
            //mMainActivity.setModuleState(MainActivity.CONNECT_STATE_TYPE);
            //mMainActivity.startWaitingForState();
            break
        case Constant.CMD_SEND_MODULE_DIRECTION:
            data.append(Constant.STX)
            data.append((what == 1 ? 1: 0))
            data.append(type)
            data.append(cmd)
            data.append(Constant.ETX)
            let writeData =  Data(data)
            peripheral.writeValue(writeData, for:mainCharacteristic!, type: .withResponse)
            break
        case Constant.CMD_COUNT_START:
            data = [Constant.STX, 0,0,cmd,Constant.ETX]
            let writeData =  Data(data)
            peripheral.writeValue(writeData, for:mainCharacteristic!, type: .withResponse)
            break
        case Constant.CMD_COUNT_STOP:
            data = [Constant.STX, 0,0,cmd,Constant.ETX]
            let writeData =  Data(data)
            peripheral.writeValue(writeData, for:mainCharacteristic!, type: .withResponse)
            break
        case Constant.CMD_CALIBRATION_GYRO_START:
            data = [Constant.STX, 0,0,cmd,Constant.ETX]
            break
        case Constant.CMD_CALIBRATION_MAGNET_START:
            data = [Constant.STX, 0,0,cmd,Constant.ETX]
        case Constant.CMD_MAGNET_NEED_OR_NOT:
            data = [Constant.STX, 0,0,cmd,Constant.ETX]
            break
        case Constant.CMD_SEND_CALIBRATION_GYRO:
            break
        case Constant.CMD_SEND_CALIBRATION_MAGNET:
            break
        default:
            break
        }
    }
    func recvDataSplit(values : [UInt8]) -> [UInt8]{
        var splitValue:[UInt8]=[]
        for i in (0 ... values.count-1).reversed(){
            if values[i] == Constant.ETX{
                splitValue = Array(values[0...i])
                break
            }
        }
        return splitValue
    }
    func getCurrentMillis()->Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    func sendPunch(pr :CBPeripheral){
        
        //        if pr == self.leftPeripheral {
        //            let calTime = leftPunchsaveTime - Int64(getCurrentMillis())
        //            if leftPunchsaveTime == 0 || abs(calTime) > 300{
        //            self.app!.unityFramework?.sendMessageToGO(withName: "VIASS_Glovers_Blue", functionName:"rcvLeftSensorMove", message:"")
        //            mPunchCount+=1
        //                leftPunchsaveTime = Int64(getCurrentMillis())
        //            }
        //        }
        //        else if pr == self.rightPeripheral {
        //            let calTime = rightPunchsaveTime - Int64(getCurrentMillis())
        //            if rightPunchsaveTime == 0 || abs(calTime) > 300{
        //            self.app!.unityFramework?.sendMessageToGO(withName: "VIASS_Glovers_Red", functionName:"rcvRightSensorMove", message:"")
        //                mPunchCount+=1
        //                rightPunchsaveTime = Int64(getCurrentMillis())
        //            }
        //        }
    }
    func musicControl(pr :CBPeripheral){
        //        if pr == self.leftPeripheral {
        //            leftSaveTime = Int64(getCurrentMillis())
        //        }
        //        else if pr == self.rightPeripheral {
        //            rightSaveTime = Int64(getCurrentMillis())
        //        }
        //        let min = leftSaveTime - rightSaveTime
        //
        //        print("time:"+"\(min.magnitude)")
        //        if  min.magnitude < 300{
        //            gameStart=true
        //          self.app!.unityFramework?.sendMessageToGO(withName: "EffectSound", functionName:"playChoiceSound", message:"")
        //          self.app!.unityFramework?.sendMessageToGO(withName: "SceneManager", functionName:"changeScene", message:"GameStart")
        //            gameMode = GameMode.countdown
        //            print("gameStart")
        //        }
        //        else {
        //            let delay : Double = 0.3 //delay time in seconds
        //            let time = DispatchTime.now() + delay
        //            DispatchQueue.main.asyncAfter(deadline:time){
        //                if self.gameStart == false {
        //                    if pr == self.leftPeripheral{
        //                        self.sendMusicCal(mode:Constant.MUSIC_LEFT)
        //                    }else{
        //                        self.sendMusicCal(mode:Constant.MUSIC_RIGHT)
        //                    }
        //                }
        //            }
        //        }
    }
    //    func unityFrameworkLoad() -> UnityFramework? {
    //              let bundlePath = Bundle.main.bundlePath.appending("/Frameworks/UnityFramework.framework")
    //              if let unityBundle = Bundle.init(path: bundlePath){
    //                  if let frameworkInstance = unityBundle.principalClass?.getInstance(){
    //                      return frameworkInstance
    //                  }
    //              }
    //              return nil
    //    }
    //
    //    func initAndShowUnity() -> Void {
    //              if let framework = self.unityFrameworkLoad(){
    //                  self.unityFramework = framework
    //                  self.unityFramework?.setDataBundleId("com.unity3d.framework")
    //                self.unityFramework?.runEmbedded(withArgc: CommandLine.argc, argv: CommandLine.unsafeArgv, appLaunchOpts:)
    //                  self.unityViewController = (self.unityFramework.appController()?.rootViewController)!
    //                  self.view.addSubview(self.unityViewController!.view)
    //        }
    //     }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let originalValues = Array<UInt8>(characteristic.value!)
        print(originalValues)
        let value = recvDataSplit(values: originalValues)
        if value.count == 0 { return}
        if error != nil {return}
        switch (value[value.count-2]) {
        case Constant.CMD_INIT_MODULE:
            self.block?.cancel()
            //유저에게 케리브레이션 할지 안할지 묻는 모듈
            self.sendProtocol(peripheral:peripheral,type:1,cmd:Constant.CMD_SENSOR_TYPE,what: 0)
            print("aaaaaa")
            // try {
            //                    if(isRightSensor){
            //                        if (rcvData[rcvData.length - 2 - 1] == ACK) { //Module Init
            //                            hasInfo1 = false;
            //                        } else {
            //                            hasInfo1 = true;
            //                        }
            //                    }else{
            //                        if (rcvData[rcvData.length - 2 - 1] == ACK) { //Module Init
            //                            hasInfo2 = false;
            //                        } else {
            //                            hasInfo2 = true;
            //                        }
            //                    }
            //                    mMainActivity.showDialogMsg("Sending type data...");
            //                    Thread.sleep(1000);
            //                    sendProtocol(CMD_SENSOR_TYPE, mAppData.getPairedSensor1Data().getType(), mScanDeviceNum);
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            //                self.sendProtocol(peripheral:peripheral,type:5,cmd:Constant.CMD_SENSOR_TYPE,what: 0)
            //            }
            //                } catch (Exception e) {
            //                    Log.e("mtome2", "Thread Error!");
            //                }
            break
        case Constant.CMD_SENSOR_TYPE:
            self.block?.cancel()
            if value[value.count-2-1] == Constant.ACK {
                Util.Toast.show(message: "Sending Module Direction...", controller: self)
                sendProtocol(peripheral:peripheral ,type:0,cmd: Constant.CMD_SEND_MODULE_DIRECTION,what: 0)
            }
            //Type 전송 성공!!
            //                    if(isRightSensor){
            //                        Log.e("mtome", "hasInfo1 : "+hasInfo1);
            //                        if (hasInfo1) {
            //                            if (mConnectedModule1.getGyorX() != null) {
            //                                mMainActivity.showDialogMsg("Sending gyro data...");
            //                                mMainActivity.rcvSuccessTypeSend();
            //                            } else {
            //                                try {
            //                                    Thread.sleep(1000);
            //                                } catch (InterruptedException e) {
            //                                    e.printStackTrace();
            //                                }
            //                                mMainActivity.showDialogMsg("Request magnet data...");
            //                                mMainActivity.rcvSuccessGyroCalibration();
            //                            }
            //                        } else {  //Type Save Success!!
            //                            mMainActivity.showDialogMsg("Start gyro calibration...");
            //                            mMainActivity.showDialogGyroCalibrationQ();
            //                        }
            //                    }else{  // Left Sensor
            //                        Log.e("mtome", "hasInfo2 : "+hasInfo2);
            //                        if (hasInfo2) {
            //                            if (mConnectedModule2.getGyorX() != null) {
            //                                mMainActivity.showDialogMsg("Sending gyro data...");
            //                                mMainActivity.rcvSuccessTypeSend();
            //                            } else {
            //                                try {
            //                                    Thread.sleep(1000);
            //                                } catch (InterruptedException e) {
            //                                    e.printStackTrace();
            //                                }
            //                                mMainActivity.showDialogMsg("Request magnet data...");
            //                                mMainActivity.rcvSuccessGyroCalibration();
            //                            }
            //                        } else {  //Type Save Success!!
            //                            mMainActivity.showDialogMsg("Start gyro calibration...");
            //                            mMainActivity.showDialogGyroCalibrationQ();
            //                        }
            //                    }
            //                }
            break
        case Constant.CMD_COUNT_START:
            if value[value.count-2-1] == Constant.ACK  {
                if self.leftPeripheral == peripheral {
                    leftPeripheral_Connect = true
                    print("Seq 1 : UnityEmbeddedSwift.showUnity(self , self")
                }
            }
            break
        case Constant.CMD_COUNT_STOP:
            //                    Log.e("mtome3", "측정 종료 ack!!");
            //                    //측정 종료!
            //                } else {
            //                    Log.e("mtome3", "Error : " + String.valueOf(rcvData[1]));
            //                    //측정 종료 Error!
            //                }
            break
        case Constant.CMD_COUNT_RESULT:
        
            let x = ((value[1] & 0xff) << 8) | (value[2] & 0xff)
            let y = ((value[3] & 0xff) << 8) | (value[4] & 0xff)
            let z = ((value[5] & 0xff) << 8) | (value[6] & 0xff)
        
            recvCount(x: Int(x), y:  Int(y), z: Int(z))
            print("x=\(x) y=\(y) z=\(z) max=\(value.max() ?? 0)")
            
            
            //            if self.gameMode == GameMode.gameLobby{
            //                musicControl(pr:peripheral)
            //            }
            //            else if self.gameMode == GameMode.gameStart{
            //                sendPunch(pr: peripheral)
            //            }
            break
        case Constant.CMD_POWER_RESULT:
            
            
            //            switch(((value[1] & 0xff) << 8) | (value[2] & 0xff)){
            //            case 1:
            //                mKcal += mWeight * mKcalSoftFactor
            //                sendPower(pr: peripheral, power: "soft")
            //                break
            //            case 2:
            //                mKcal += mWeight * mKcalNormalFactor
            //                sendPower(pr: peripheral, power: "normal")
            //                break
            //            case 3:
            //                mKcal += mWeight * mKcalPowerFactor;
            //                sendPower(pr: peripheral, power: "power")
            //                break
            //            default:
            //                break
            //            }
            //          Intent intentPower = new Intent();
            //          intentPower.setAction(isRightSensor ? BluetoothLeService.RECIEVE_POWER_1 : BluetoothLeService.RECIEVE_POWER_2);
            //          intentPower.putExtra("POWER", power);
            //          broadcastUpdate(intentPower);
            //            break;
            break
        case Constant.CMD_CALIBRATION_GYRO_START:
            //                if (rcvData[rcvData.length - 2 - 1] == ACK) {
            //                    mMainActivity.showDialogMsg("Start gyro calibration...");
            //                }
            break
        case Constant.CMD_CALIBRATION_GYRO_RESULT:
            //
            //                mMainActivity.cancelWaitingTimer();
            //
            //                int xGyro, yGyro, zGyro;
            //                xGyro = ((rcvBytes[1] & 0xff) << 8) | (rcvBytes[2] & 0xff);
            //                yGyro = ((rcvBytes[3] & 0xff) << 8) | (rcvBytes[4] & 0xff);
            //                zGyro = ((rcvBytes[5] & 0xff) << 8) | (rcvBytes[6] & 0xff);
            //
            //                if(isRightSensor){
            //                    mConnectedModule1.setGyroX(Integer.toString(xGyro));
            //                    mConnectedModule1.setGyroY(Integer.toString(yGyro));
            //                    mConnectedModule1.setGyroZ(Integer.toString(zGyro));
            //
            //                    //Log.e("mtome3", "CMD_CALIBRATION_GYRO_RESULT > X(" + xGyro + "), Y(" + yGyro + "), Z(" + zGyro + ")");
            //
            //                    mMainActivity.showDialogMsg("Saving gyro data...");
            //                    int result = mMainActivity.updateGyroData(mConnectedModule1.getUUID(), Integer.toString(xGyro), Integer.toString(yGyro), Integer.toString(zGyro));
            //
            //                    if (!hasInfo1) {
            //                        //mMainFragment.showDialogProgressDialog("sending magnet data...");
            //                        mMainActivity.showDialogMsg("Request magnet data...");
            //                        mMainActivity.rcvSuccessGyroCalibration();
            //                    } else {
            //                        //mMainFragment.showDialogProgressDialog(null);
            //                        mMainActivity.showDialogMsg(null);
            //                    }
            //                }else{
            //                    mConnectedModule2.setGyroX(Integer.toString(xGyro));
            //                    mConnectedModule2.setGyroY(Integer.toString(yGyro));
            //                    mConnectedModule2.setGyroZ(Integer.toString(zGyro));
            //
            //                    //Log.e("mtome3", "CMD_CALIBRATION_GYRO_RESULT > X(" + xGyro + "), Y(" + yGyro + "), Z(" + zGyro + ")");
            //
            //                    mMainActivity.showDialogMsg("Saving gyro data...");
            //                    int result = mMainActivity.updateGyroData(mConnectedModule2.getUUID(), Integer.toString(xGyro), Integer.toString(yGyro), Integer.toString(zGyro));
            //
            //                    if (!hasInfo2) {
            //                        //mMainFragment.showDialogProgressDialog("sending magnet data...");
            //                        mMainActivity.showDialogMsg("Request magnet data...");
            //                        mMainActivity.rcvSuccessGyroCalibration();
            //                    } else {
            //                        //mMainFragment.showDialogProgressDialog(null);
            //                        mMainActivity.showDialogMsg(null);
            //                    }
            //                }
            break
        //case CMD_SEND_CALIBRATION_GYRO:
        case Constant.CMD_SEND_CALIBRATION_SUCCESS:
            //                if (rcvData[rcvData.length - 2 - 1] == ACK) {
            //                    //mMainFragment.showDialogProgressDialog("send magnet data...");
            //                    mMainActivity.showDialogMsg("Request magnet data...");
            //                    mMainActivity.rcvSuccessGyroSend();
            //                } else {
            //                    //전송 실패 > 이유 rcvData[1]
            //                }
            break
        case Constant.CMD_SEND_MODULE_DIRECTION:
            sendProtocol(peripheral:peripheral ,type:0,cmd: Constant.CMD_COUNT_START,what: 0)
            break
        case 0x37:
            sendProtocol(peripheral:peripheral ,type:0,cmd: Constant.CMD_COUNT_START,what: 0)
            print("CMD_SEND_MODULE_DIRECTION")
            //                       case 0x37:
            //                            try {
            //                                mMainActivity.showDialogMsg(null);
            //                                Thread.sleep(1000);
            //                                sendProtocol(CMD_COUNT_START, 0, mScanDeviceNum);
            //                            } catch (InterruptedException e) {
            //                                e.printStackTrace();
            //                            }
            break
        case Constant.CMD_SEND_CALIBRATION_MAGNET:
            //                mMainActivity.cancelWaitingTimer();
            //                try {
            //                    if (rcvData[rcvData.length - 2 - 1] == ACK) {
            //                        mMainActivity.showDialogMsg("Sending Module Direction...");
            //                        Thread.sleep(1000);
            //                        //sendProtocol(CMD_COUNT_START, 0, mScanDeviceNum);
            //                        sendProtocol(CMD_SEND_MODULE_DIRECTION, 0, mScanDeviceNum);
            //                    } else {
            //                        Log.e("mtome", "Magnet data Sending Failed...");
            //                        //Magnet data Sending Failed...
            //                    }
            //                } catch (InterruptedException e) {
            //                    e.printStackTrace();
            //                }
            break
        case Constant.CMD_MAGNET_NEED_OR_NOT:
            //                try {
            //                    if (rcvData[rcvData.length - 2 - 1] == ACK) { //Need Magnet Data
            //                        mMainActivity.showDialogMsg("Sending magnet data...");
            //                        Thread.sleep(1000);
            //                        sendProtocol(CMD_SEND_CALIBRATION_MAGNET, 0, mScanDeviceNum);
            //                    } else {
            //                        mMainActivity.showDialogMsg("Sending Module Direction...");
            //                        Thread.sleep(1000);
            //                        //sendProtocol(CMD_COUNT_START, 0, mScanDeviceNum);
            //                        sendProtocol(CMD_SEND_MODULE_DIRECTION, 0, mScanDeviceNum);
            //                    }
            //                } catch (Exception e) {
            //                    Log.e("mtome2", "Send CMD_MAGNET_NEED_OR_NOT e : " + e);
            //                }
            break
        case Constant.CMD_COUNT_CPU_SLEEP:
            //                int intV = rcvData[rcvData.length - 2 - 1];
            //                Log.e("mtome2", "슬립 받을때 배터리 : " + intV);
            //                Intent intent2 = new Intent();
            //                intent2.putExtra("BATTERY", intV);
            //                intent2.setAction(isRightSensor ? BluetoothLeService.RECIEVE_SLEEP_1 : BluetoothLeService.RECIEVE_SLEEP_2);
            //                broadcastUpdate(intent2);
            break
        default:
            break
        }
    }
    var mSpeedKMH : Float = 0
    let mReference : Float = 18000
    var mCount :Int = 0
    var mPreCount :Int = 0
    var mKcal :Int = 0
    var mPreTime : CLong = 0
    var mShowingCount :Int = 0
    var mCurTime: CLong = 0
    var isSensorMove :Bool = false
    var isFirstMusic :Bool = true
    func recvCount(x:Int ,y:Int ,z:Int){
        var va = [Int](repeating: 0, count: 3)
        va[0] = Int(x)
        va[1] = Int(y)
        va[2] = Int(z)
        let total = x + y + z
        if total == 0{
            firstStartSpeed()
        }
        else if(total > 190000){
            stopSpeed()
        }else{
            if(timeStop){
                firstStartSpeed()
                timeStop = false;
            }else{
                mCount = va.max()!
                mKcal = mShowingCount / mKPC;
                if(mPreCount != mCount){
                if(mScene == 1){
                    UnityEmbeddedSwift.sendUnityMessage("AndroidManagerMovie", methodName: "setSleepIcon", message: "false")
                }else{
                    UnityEmbeddedSwift.sendUnityMessage("AndroidManagerMovie2D", methodName: "setSleepIcon", message: "false")
                }
                isSensorMove = true
                if isFirstMusic {
                  isFirstMusic = false
                  musicFinish()
                }
                speedControll(mode:0)
                mCurTime = CLong(Util.getCurrentMillis())
                let term : Int = mCurTime - mPreTime;

                setTime()

                if((mCount % 2) == 1){
                    mShowingCount += 1
                }
                calDistance();
                setSpeed(spd: calSpeed(alpha: 0.65, spd:(mReference / Float(term))) / 2)
                if(!isPlayWithoutMusic) {
                    footConfirm2()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.speedControll(mode: 1)
                }
                broadCastExData(isCounting: true)
                mPreCount = mCount;
                mPreTime = mCurTime;
                }
            }
        }
    }
    var mMusicRPM : Int = 0
    var mFootSwitch : Bool = false
    var mLeftPreTime : Int = 0
    var mRightPreTime : Int = 0
    var PLUS_TERM : Int = 50
    var mTermInt: Int = 0
    
    func calcurateSuccessTerm(){
        let valuef = String(format:"%.3f", Float(60 / mMusicRPM))
        let first = String(valuef[valuef.startIndex])
        let strRange = valuef.index(valuef.startIndex, offsetBy: 2) ... valuef.index(valuef.startIndex, offsetBy: 4)
        let second = first + valuef[strRange]
        mTermInt = Int(second)!
    }
    var isLeftFootSuccess : Bool!
    var isRightFootSuccess : Bool!
    var mShowWarningCnt : Int = 0
    var passRPMDis : Int = 8
    
    func footConfirm2(){
        let rpm = Int(calRPM(spd: mSpeedKMH))
        let v = mMusicRPM - rpm!    /// 90 - 100

            if(abs(v) < passRPMDis){    //Success
                mShowWarningCnt = 0;

                if(circleRighLleft){
                    isRightFootSuccess = true;
                    UnityEmbeddedSwift.sendUnityMessage("RightFoot", methodName: "RightFootPrint", message: isRightFootSuccess ? "SUCCESS" : "FAIL")
                }else{
                    isLeftFootSuccess = true;
                    UnityEmbeddedSwift.sendUnityMessage("LeftFoot", methodName: "LeftFootPrint", message: isLeftFootSuccess ? "SUCCESS" : "FAIL")
                }
            }else if(v > passRPMDis){                  //Failed(Slow)
                if(mShowWarningCnt >= 8){
                    UnityEmbeddedSwift.sendUnityMessage("Warning_Slow", methodName: "tooSlow", message: "");
                    mShowWarningCnt = 0
                }
                mShowWarningCnt += 1
            }else if(v < -passRPMDis){                  //Failed(fast)
                if(mShowWarningCnt >= 13){
                    UnityEmbeddedSwift.sendUnityMessage("Warning_Fast", methodName: "tooFast", message: "");
                    mShowWarningCnt = 0;
                }
                mShowWarningCnt += 1

            }
            isRightFootSuccess = false;
            isLeftFootSuccess = false;
    }
    var mDistance : Float = 0.0
    var mWheelDistance : Float = 4.2
    func calDistance(){
        mDistance = (Float(mShowingCount) * mWheelDistance) / 1000
    }
    var totalTime : Int  = 0
    var mBeforeTime : Int = 0
    var hasStopSig : Bool = true
    func broadCastExData(isCounting:Bool){
        let currentTime = Int(Util.getCurrentMillis())
        if(isCounting){
            if(!hasStopSig){
                   totalTime += currentTime - mBeforeTime;
               }
               hasStopSig = false
               mBeforeTime = currentTime;
           }else{
               if(!hasStopSig){
                   hasStopSig = true
                   totalTime += currentTime - mBeforeTime;
                   mBeforeTime = 0
               }
           }

//           Intent intent = new Intent();
//           intent.setAction("vrcycle.mtome.com.vr_cycle_movie_360.receiver.count");
//           intent.putExtra("KM", Integer.toString((int) (mDistance * 1000)));
//           intent.putExtra("KCAL", Integer.toString(mKcal));
//           intent.putExtra("COUNT", Integer.toString(mShowingCount));
//           intent.putExtra("TIME", Long.toString(totalTime/1000));
//           sendBroadcast(intent);
       }
    func setTime(){
          let s = (Int)(totalTime/1000)
          let sec = (Int)(s % 60)
          let min = (Int)((s / 60) % 60)
          let hour = (s / 3600) % 24
          let value = String(format:"%02d:%02d:%02d", hour, min, sec);
          UnityEmbeddedSwift.sendUnityMessage("InfoTimeTXT", methodName: "setTime", message: value);
       }
    
    func firstStartSpeed(){
        mPreTime = CLong(Util.getCurrentMillis())
        setSpeed(spd: calSpeed(alpha: 0.65, spd: 25.0))
        timeStop = true
        stopSpeed()
        
    }
    private let maxSpeed : Float = 30.0
    private let maxXSpeed : Float = 2.0
    func setSpeed(spd :Float){
        mSpeedKMH = spd / 2
        UnityEmbeddedSwift.sendUnityMessage("ToggleCycleImage", methodName: "changeToggle", message: "")
        var setSpeedValue:Float = 0.0
        if(mSpeedKMH < (maxSpeed/1.65)){
            setSpeedValue = mSpeedKMH * (maxXSpeed / (maxSpeed/1.65))
            
        }else{
            setSpeedValue = maxXSpeed
        }
        let kmh = calRPM(spd: mSpeedKMH)
        UnityEmbeddedSwift.sendUnityMessage("VideoPlayer", methodName: "setSpeed", message: String(setSpeedValue))
        UnityEmbeddedSwift.sendUnityMessage("Cycle1SetSpeed", methodName: "setSpeed", message: String(format:"%.0f", mSpeedKMH * 1.65))
        UnityEmbeddedSwift.sendUnityMessage("Cycle1SetRPM", methodName: "setRPM", message: spd == 0 ? "0" : String(kmh))
        UnityEmbeddedSwift.sendUnityMessage("DistanceTXT", methodName: "setDistance", message: String(format:"%.2f", mDistance))
         
    }
    
    //스피드 계산
    private var mean: Float = 0.0
    private var pre_spd : Float = 0.0
    private let A : Float = 70 * 2 / 1.65 * 2
    func calSpeed(alpha:Float,spd:Float)->Float{
        mean = alpha * mean + (1 - alpha) * spd
        
        if(mean > pre_spd){
            if(mean-pre_spd > 30){
                mean = pre_spd + 30
            }
        }else{
            if(pre_spd-mean > 30){
                mean = pre_spd - 30
            }
        }
        if(mean > A){
            mean = A;
        }
        pre_spd = mean;
        return mean;
    }
    var rpms = [Double](repeating:0, count: 5)
    var isFullTemp :Bool = false
    var rpmCnt : Int = 0
    func calRPM(spd:Float)->String{
        var rpm : String = "0"
        if(rpmCnt < 5){
            rpms[rpmCnt] = Double(1.65 * (spd/(50/25*2096*60))*1000000)
            rpmCnt += 1
        }
        if(rpmCnt >= 5){
            isFullTemp = true
            rpmCnt = 0;
        }
        if(isFullTemp){
            rpm = String.init(format:"%.0f", (rpms[0] + rpms[1] + rpms[2] + rpms[3] + rpms[4]) / 5)
        }
        return rpm
    }
    func stopSpeed(){
        mean = 0;
        pre_spd = 0
        setSpeed(spd:0)
        rpms[0] = 0
        rpms[1] = 0
        rpms[2] = 0
        rpms[3] = 0
        rpms[4] = 0
        isFullTemp = false
        rpmCnt = 0
    }
    var mBPMTerm : Double = 0
    func musicStart(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.speedControll(mode: 1)
        }
    }
    var musicCnt : Int = 1
    func musicFinish(){
         if(!isPlayWithoutMusic){
            if(musicCnt > musciInfo.count){
                   musicCnt = 1
          }
            if musciInfo.count > 0{
                self.timer?.cancel()
                self.timer = nil
          }
          mBPMTerm = floor((60.0 / Double(musciInfo[musicCnt].music_bpm!) / 2) * 1000)
          mMusicRPM =  Int(musciInfo[musicCnt].music_bpm!)
          calcurateSuccessTerm()
          let patch = Util.getPath(musciInfo[musicCnt].title! + ".mp3")
          UnityEmbeddedSwift.sendUnityMessage("BPM_bgm", methodName: "test", message: patch)
               musicCnt += 1
           }
       }
    func BPMCircleStart(){
        NSLog("startTimer")
        let queue = DispatchQueue(label: "com.domain.app.timer", qos: .userInteractive)
        timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        timer.schedule(deadline: .now(), repeating:mBPMTerm, leeway: .nanoseconds(0))
        timer.setEventHandler {
            if(self.isSensorMove){
                UnityEmbeddedSwift.sendUnityMessage("BPM_bgm", methodName: "resumeMusic", message: "")
                UnityEmbeddedSwift.sendUnityMessage("BPM_bgm", methodName: "startSensor", message: "")
                self.showBPMCircle()
             }else{
                UnityEmbeddedSwift.sendUnityMessage("BPM_bgm", methodName: "pauseMusic", message: "")
            }
        }
        timer.resume()
    }
    func showBPMCircle(){
           if(circleRighLleft){
            UnityEmbeddedSwift.sendUnityMessage("LeftCircle", methodName: "LeftCircleShow", message: "")
           }else{
            UnityEmbeddedSwift.sendUnityMessage("RightCircle", methodName: "RightCircleShow", message: "")
           }
           circleRighLleft = !circleRighLleft
       }
    func speedControll(mode : Int)
    {
        switch mode {
        case 0:
            timeStop = true
            stopSpeed()
            break
        case 1:
            //BPMCircleStart()
            break
        default:
            break
        }
        
    }
    
    //MARK: 유니티 에서 네이티브 콜 함수
    
    func unityStartScene(){
        UnityEmbeddedSwift.sendUnityMessage("ReadySceneManager", methodName: "TestLoadLevel", message:mScene == 1 ? "1" : "2" )
    }
    func unityInit(){
        UnityEmbeddedSwift.sendUnityMessage("ReadySceneManager", methodName: "TestLoadLevel", message:mScene == 1 ? "1" : "2" )
        if  mScene == 1{
            UnityEmbeddedSwift.sendUnityMessage("VideoPlayer", methodName: "setMovieURLList", message: mMoviePath)
        }else{
            UnityEmbeddedSwift.sendUnityMessage("VideoPlayer", methodName: "setMovieURLList2D", message: mMoviePath)
        }
    }
}
extension ViewController : LoginControllerDelegate,SideMenuNavigationControllerDelegate,IAxisValueFormatter,UnityInit,NativeCallsProtocol{
    func unityLodingCall(){
        
    }
    func sendUnity(toIOS msg: String!) {
        if msg.contains("unityStartScene"){
            unityStartScene()
        }
        else if msg.contains("unityInit"){
            
            
        }
    }
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return value <= 0.0 ? "" : String(describing: value)
    }
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
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
        loginViewConroller.view .removeFromSuperview()
        loginViewConroller .removeFromParent()
        //homeController.reflashUserid()
        //homeController.getData()
        //if self.loginViewConroller != nil{
        //    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations:{
        //               self.loginViewConroller.view.alpha = 0.1
        //           }, completion: { finished in
        //               self.loginViewConroller.view.removeFromSuperview()
        //               self.loginViewConroller.removeFromParent()
        //           })
        //}
    }
    // MARK: BluetoothDelegate
    func didDiscoverPeripheral(_ peripheral: CBPeripheral, advertisementData: [String : Any], RSSI: NSNumber) {
        
    }
    
}

