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
class ViewController: UIViewController, UINavigationControllerDelegate,ChartViewDelegate{
    
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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Util.copyDatabase("box.db")
        menu = storyboard?.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? SideMenuNavigationController
        menu?.leftSide = true
        menu?.setNavigationBarHidden(true, animated: false)
        menu?.settings = makeSettings()
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
        super.viewWillAppear(true)
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
        case levelValue[4]:
            levelString = "5"
            break
        default: break
            
        }
        return levelString
    }
    private func makeSettings() -> SideMenuSettings{
        var presentationStyle = SideMenuPresentationStyle()
        presentationStyle = .viewSlideOutMenuIn
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
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = 15
        manager.request(Constant.VRFIT_VERSION_CHECK, method: .post, parameters:parameters, encoding:URLEncoding.httpBody)
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
    //        let storeViewController = SKStoreProductViewController()
    //        storeViewController.delegate = self
    //            // 앱스토어에 있는 앱 id값으로 연결된 SKStoreProductParameterITunesItemIdentifier 키로 초기화
    //            let parameters = [SKStoreProductParameterITunesItemIdentifier: 1085123968]
    //            // 뷰 컨트롤러에 로드 되고 성공하면 표시된다.
    //                storeViewController.loadProduct(withParameters: parameters, completionBlock: {result, error in
    //                if result {
    //                    self.present(storeViewController, animated: true, completion: nil)
    //                }
    //            })
    //        }
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
                                //                                if let excount = data["ex_count"]?.int{
                                //                                    if excount > 0{
                                //                                        let value = UserDefaults.standard.integer(forKey: "level")
                                //                                        var daypercent : String
                                //                                        if (Float(excount)/Float(value)) > 1.0 {
                                //                                            daypercent = "100.0"
                                //                                        }else{
                                //                                            daypercent = String(format: "%.1f", Float(excount)/Float(value) * 100.0)
                                //                                        }
                                //                                        daypercent += "%"
                                //                                    }
                                //                                }
                                if let extime = data["ex_time"]?.int{
                                    if extime != 0{
                                        self.dayExTime = extime
                                        let savelebel = UserDefaults.standard.integer(forKey:"lebel")
                                        self.updateStar(level: savelebel / self.dayExTime)
                                        self.todayPerCent.text = "\((self.dayExTime/savelebel)*100)"+"%"
                                        self.progressBar.progress = Float(Int(self.dayExTime / savelebel))
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
                                        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
                                        getexerciseAchivement()
                                        self.useridVal.text = UserDefaults.standard.string(forKey: "userid")
                                        getTodayExerciseRecord()
                                        currentDay = self.calMounth(direction: 0)
                                        dayCal(value: currentDay)
                                        getexerciseMonthlyRecord(month: self.calMounth(direction:0))
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
}
extension ViewController : LoginControllerDelegate,SideMenuNavigationControllerDelegate,IAxisValueFormatter{
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
        //        homeController.reflashUserid()
        //        homeController.getData()
        //        if self.loginViewConroller != nil{
        //            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations:{
        //                       self.loginViewConroller.view.alpha = 0.1
        //                   }, completion: { finished in
        //                       self.loginViewConroller.view.removeFromSuperview()
        //                       self.loginViewConroller.removeFromParent()
        //                   })
        //        }
    }
}

