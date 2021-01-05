//
//  DatabaseManager.swift
//  Boxing
//
//  Created by altedge on 2020/05/26.
//  Copyright © 2020 mtome. All rights reserved.
//

import Foundation
import FMDB
var shareInstance = DatabaseManager()
class DatabaseManager : NSObject{
    var database : FMDatabase? = nil
    class func getInstance() -> DatabaseManager{
        if shareInstance.database == nil{
            shareInstance.database = FMDatabase(path: Util.getPath("box.db"))
        }
        return shareInstance
    }
    func saveAllData(modelInfo:[MusicInfo] )-> Bool{
        shareInstance.database?.open()
        var count : Int = 0
        for model in modelInfo{
            count+=1;
            let success = shareInstance.database?.executeUpdate("INSERT OR REPLACE INTO boxinfo(idx,title,singer,playtime,bpm,down) VALUES (?,?,?,?,?,(SELECT down FROM boxinfo where title = ?))",
                withArgumentsIn:[count,model.title!,model.singer!,model.playtime!,String(model.music_bpm!),model.title!])
            if success==false{continue}
        }
        shareInstance.database?.close()
        return true
    }
    func saveVodInfo(modelInfo:[InfoData])-> Bool{
        shareInstance.database?.open()
        var count : Int = 0
        for model in modelInfo{
            count+=1;
            let success = shareInstance.database?.executeUpdate("INSERT OR REPLACE INTO vodinfo(image,title,aviname,description,cn,pay,vodcheck,down) VALUES (?,?,?,?,?,?,?,(SELECT IFNULL(down,0) FROM vodinfo where title = ?))",
                                                                withArgumentsIn:[model.image!,model.title!,model.aviname!,model.description!,model.cn!,model.pay!,0,model.title!])
        
            print(shareInstance.database?.lastErrorMessage() as Any)
            if success == false{
                print("insertFalse")
                continue
            }
        }
        shareInstance.database?.close()
        return true
    }
    func selectDownLoaded()->[InfoData]{
        var model : [InfoData] = []
        let queryString = "SELECT *from vodinfo where down = 1 order by title asc"
         shareInstance.database?.open()
        let result = shareInstance.database?.executeQuery(queryString, withArgumentsIn: [])
        if  (result != nil) {
            while(result!.next()){
            let data : InfoData = InfoData(image: result!.string(forColumn: "image"), title: result!.string(forColumn: "title"),aviname:result!.string(forColumn: "aviname"),
                                           description: result!.string(forColumn: "description")
                                          ,length_4k: 0, length_2k: 0, length: 0, type: "", cn: result!.string(forColumn: "cn")
                                          ,pay:result!.string(forColumn: "pay"), vodcheck: result!.bool(forColumn: "vodcheck"),download: result!.bool(forColumn: "down"))
          model.append(data)
         }
        }
        shareInstance.database?.close()
        return model
    }
    func selectVodData(query : String)->[InfoData]{
        var model : [InfoData] = []
        let queryString = "SELECT *from vodinfo order by title asc"
         shareInstance.database?.open()
        let result = shareInstance.database?.executeQuery(queryString, withArgumentsIn: [])
        if  (result != nil) {
            while(result!.next()){
            let data : InfoData = InfoData(image: result!.string(forColumn: "image"), title: result!.string(forColumn: "title"),aviname:result!.string(forColumn: "aviname"),
                                           description: result!.string(forColumn: "description")
                                          ,length_4k: 0, length_2k: 0, length: 0, type: "", cn: result!.string(forColumn: "cn")
                                          ,pay:result!.string(forColumn: "pay"), vodcheck: result!.bool(forColumn: "vodcheck"),download: result!.bool(forColumn: "down"))
          model.append(data)
         }
        }
        shareInstance.database?.close()
        return model
        
    }
    func saveVodPlayCheck(fileName:String,check:Bool){
        shareInstance.database?.open()
         //데이터 수정
        let sqlUpdate : String = "UPDATE vodinfo SET vodcheck = ? WHERE title = ?"
        var value = check ? 1 : 0
        shareInstance.database?.executeUpdate(sqlUpdate,withArgumentsIn:[value,fileName])
        print(shareInstance.database?.lastErrorMessage() as Any)
        shareInstance.database?.close()
    }
    func saveDownLoadComplate(fileName : String) -> Bool{
        shareInstance.database?.open()
         //데이터 수정
        let sqlUpdate : String = "UPDATE vodinfo SET down = ? WHERE title = ?"
        let success = shareInstance.database?.executeUpdate(sqlUpdate,withArgumentsIn:[1,fileName])
        print(shareInstance.database?.lastErrorMessage() as Any)
        shareInstance.database?.close()
        return success!
    }
    func saveData(model:MusicInfo) -> Bool{
         shareInstance.database?.open() 
         //데이터 수정
        let sqlUpdate : String = "UPDATE boxinfo SET down =? WHERE title =?"
        let success = shareInstance.database?.executeUpdate(sqlUpdate,withArgumentsIn: [(model.isDownload ? 1 : 0),model.title!])
       shareInstance.database?.close()
        return success!
    }
    func selectQuery(query : String)->[MusicInfo]{
        var model : [MusicInfo] = []
        let queryString = "SELECT *from boxinfo where down = 1 order by title asc"
         shareInstance.database?.open()
        let result = shareInstance.database?.executeQuery(queryString, withArgumentsIn: [])
        while(result!.next()){
                let data : MusicInfo = MusicInfo()!
                data.index = result!.int(forColumn: "idx")
                data.title = result!.string(forColumn: "title")
                data.singer = result!.string(forColumn: "singer")
                data.music_note = result!.int(forColumn: "note")
                data.playtime = result!.string(forColumn: "playtime")
                data.difficulty = result!.string(forColumn: "difficulty")
                data.music_bpm = result!.int(forColumn: "bpm")
                data.music_bit = result!.string(forColumn: "bit")
                data.isDownload = result!.bool(forColumn: "down")
                model.append(data)
        }
        shareInstance.database?.close()
        return model
        
    }
    
}

