//
//  MusicInfo.swift
//  Boxing
//
//  Created by altedge on 2020/04/26.
//  Copyright © 2020 mtome. All rights reserved.
//

import Foundation
//뮤직데이터
class MusicInfo{

   var index:Int32?
   var title:String?
   var composer:String?
   var singer:String?
   var music_bit:String?
   var music_note:Int32?
   var music_bpm:Int32?
   var playtime:String?
   var h_playtime:Int32?
   var length:Int32?
   var difficulty:String?
   var isPlaying:Bool
   var isDownload:Bool
   var playSec:Int32?
   required init?(){
        isPlaying = false
        isDownload = false
        index = 0
    }
}
//영상테이터
class VoidInfo{
    
    var image : String?
    var title : String?
    var aviname : String?
    var description : String?
    var type : String?
    var cn : String?
    var pay : String?
    var isDownLoad:Bool
    var isCheck:Bool
    required init?(){
        isDownLoad = false
        isCheck = false
     }
}
