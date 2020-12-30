//
//  VideoInfo.swift
//  cycle
//
//  Created by SSG on 2020/12/24.
//

import Foundation

struct VideoInfo:Codable{
    
    var result : String?
    var version : String?
    var reason : String?
    var data: [String:InfoData]?
}
struct InfoData:Codable{
    var image : String?
    var title : String?
    var aviname : String?
    var description : String?
    var length_4k : Int
    var length_2k :Int
    var length:Int
    var type : String?
    var cn : String?
    var pay : String?
    var check :  Bool?
    var download: Bool?
    
}

