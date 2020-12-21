//
//  Constant.swift
//  daview
//  Created by ksb on 06/08/2019.
//  Copyright © 2019 ksb. All rights reserved.

import UIKit
import CoreBluetooth



/*
 (boxing_360 변경 api)
 api_Version_Check_360
 exercise_Monthly_Record_360
 exercise_save_360
 today_Exercise_Record_360
 member_Login_360
 
 timezone 추가
 exercise_Save_360
 today_Exercise_Record_360
 member_Login_360

 timezone , language 추가
 member_Join

 이외의 api는 boxing과 동일하게 사용 파라미터 동일

 추가된 파라미터 형식
 language(ko,en)
 timezone(숫자)
 
 */

class Constant{
    static let PORT =             ":3000/"
    static let VRFIT_BOXING_MUSIC_URL = "https://www.m2me.co.kr:4000/"
    
    static let VRFIT_BOXING_HTTP_DOMAIN = "https://www.m2me.co.kr:4443/vr_cycle/" //싸이클 공통 도메인
    
    //static let DEFAULT_URL    =   "http://192.168.1.121" + PORT
    static let URL_HTTP_VRFIT_VRCONTENT = "http://www.mtome.co.kr:8989/vrfit2/"
    static let VRFIT_CYCLE_HTTP_DOMAIN_SETTING = "https://www.m2me.co.kr:6443/setting/"
    static let VRFIT_MEMBER_SIGNUP_ADDRESS = VRFIT_BOXING_HTTP_DOMAIN + "member_Join"
    static let VRFIT_MEMBER_LOGIN_ADDRESS = VRFIT_BOXING_HTTP_DOMAIN + "member_Login_360"
    static let VRFIT_MEMBER_INPUT_WEIGHT = VRFIT_BOXING_HTTP_DOMAIN + "add_Weight"
    static let VRFIT_MEMBER_FACEBOOK_LOGIN_ADDRESS = VRFIT_BOXING_HTTP_DOMAIN + "facebook_Login"
    static let VRFIT_MEMBER_FIND_ID_ADDRESS = VRFIT_BOXING_HTTP_DOMAIN + "find_ID_Password"
    static let VRFIT_MEMBER_DATA_ACHIVE = VRFIT_BOXING_HTTP_DOMAIN + "exercise_Achivement"
    static let VRFIT_MEMBER_TODAY_RECORD = VRFIT_BOXING_HTTP_DOMAIN + "today_Exercise_Record_360"
    static let VRFIT_MEMBER_MONTH_RECORD = VRFIT_BOXING_HTTP_DOMAIN + "exercise_Monthly_Record_360"

    static let VRFIT_RECORD = VRFIT_CYCLE_HTTP_DOMAIN_SETTING + "MainContent/webView.jsp?id=" //멤버 앱 통합기록 WEB VIEW URL; //게임 랭크 정보 가져오기
    static let VRFIT_RANKING = VRFIT_BOXING_HTTP_DOMAIN + "MainContent/rankingList.jsp?id"
    
    static let VRCYCLE_MEMBER_EXER_SAVE = VRFIT_BOXING_HTTP_DOMAIN + "exercise_Save_360" //멤버 운동정보 저장 URL
    static let VRFIT_VERSION_CHECK = VRFIT_BOXING_HTTP_DOMAIN + "api_Version_Check_i_360"
    /////////////////////////String VRFIT_MUSIC_LIST = VRFIT_CYCLE_HTTP_DOMAIN_SETTING + "music_Information";
    static let VRFIT_MUSIC_LIST = VRFIT_BOXING_HTTP_DOMAIN + "music_Information"
    static let URL_GET_MAGNET = "https://www.m2me.co.kr:9443/setting/get_Calibration?uu_id=%s&id=%s" // Magnet X Y Z 찾아오는 URL
    static let SERVER_SUCCESS = "SUCCESS"
    static let SERVER_FAIL = "FAIL"
    static let WIFI_FAIL = "WIFI_FAIL"
    
    static let SERVICE_ERR_000 = "service_err_000"
    static let SERVICE_ERR_001 = "service_err_001"
    static let SERVICE_ERR_002 = "service_err_002"
    static let SERVICE_ERR_003 = "service_err_003"
    static let SERVICE_ERR_004 = "service_err_004"
    static let SERVICE_ERR_005 = "service_err_005"
    static let SERVICE_ERR_006 = "service_err_006"
    static let SERVICE_ERR_007 = "service_err_007"
    static let SERVICE_ERR_008 = "service_err_008"
    static let SERVICE_ERR_009 = "service_err_009"
    static let SERVICE_ERR_010 = "service_err_010"
    static let SERVICE_ERR_011 = "service_err_011"
    static let SERVICE_ERR_012 = "service_err_012"
    static let SERVICE_ERR_013 = "service_err_013"
    static let SERVICE_ERR_014 = "service_err_014"
    static let SERVICE_ERR_015 = "service_err_015"
    static let SERVICE_ERR_016 = "service_err_016"
    static let SERVICE_ERR_017 = "service_err_017"
    static let SERVICE_ERR_018 = "service_err_018"
    
    static let XCEPTION_01 = "EXCEPTION"
    static let EXCEPTION_02 = "EXCEPTION_SOCKET_TIME_OUT"
    static let DIALOG_ERROR = "DIALOG_ERROR"
    static let DIALOG_POSITIVE = "DIALOG_POSITIVE"
    static let DIALOG_UNKNOWN = "DIALOG_UNKNOWN "
     
    //Blutooth
    
    public static let HEART_RATE_MEASUREMENT = "00002a37-0000-1000-8000-00805f9b34fb";
    public static let CLIENT_CHARACTERISTIC_CONFIG = "00002902-0000-1000-8000-00805f9b34fb";
    public static let CSC_MEASUREMENT = "00002a5b-0000-1000-8000-00805f9b34fb";
    public static let DEVICE_NAME = "00002a00-0000-1000-8000-00805f9b34fb";
    public static let CS_CONTROL_POINT = "00002a55-0000-1000-8000-00805f9b34fb"
    public static let GENERIC_ACCESS_SERVICE = "00001800-0000-1000-8000-00805f9b34fb";
    public static let BATTERY_LEVEL = "00002A19-0000-1000-8000-00805f9b34fb";
    
    public static let SEND_DATA_SERVICE_TEST = "F000AA70-0451-4000-B000-000000000000"
    public static let SEND_DATA_CHARACTERISTIC = "F000AA72-0451-4000-B000-000000000000";
    
    public static let RECIEVE_DATA_SERVICE_TEST = "F000AA80-0451-4000-B000-000000000000";
    public static let RECIEVE_DATA_CHARACTERISTIC = "F000AA81-0451-4000-B000-000000000000";
    
    //Protocall
    
    public static let STX : UInt8 = 0x02
    public static let ETX : UInt8 = 0x03
    public static let NAK : UInt8 = 0x15
    public static let ACK : UInt8 = 0x06
    
    public static let CMD_SENSOR_TYPE : UInt8 = 0x21
    public static let CMD_INIT_MODULE : UInt8 = 0x22
    public static let CMD_COUNT_START : UInt8 = 0x23
    public static let CMD_COUNT_STOP : UInt8 = 0x24
    
    //모듈 동작 이벤트 (펀치 날리기 이벤트)
    public static let CMD_COUNT_RESULT : UInt8 = 0x26
    public static let CMD_CALIBRATION_GYRO_START : UInt8 = 0x27
    public static let CMD_CALIBRATION_GYRO_RESULT : UInt8 = 0x28
    public static let CMD_CALIBRATION_MAGNET_START : UInt8 = 0x29
    public static let CMD_SEND_CALIBRATION_GYRO : UInt8 = 0x30
    public static let CMD_SEND_CALIBRATION_SUCCESS : UInt8 = 0x32
    public static let CMD_SEND_CALIBRATION_MAGNET : UInt8 = 0x33
    public static let CMD_SEND_MODULE_DIRECTION : UInt8 = 0x36
    public static let CMD_COUNT_CPU_SLEEP : UInt8 = 0x2D
    public static let CMD_MAGNET_NEED_OR_NOT : UInt8 = 0x2E
    public static let CMD_POWER_RESULT : UInt8 = 0x2F
    public static let MUSIC_LEFT : Int = 0
    public static let MUSIC_RIGHT : Int = 1
}
