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
            let success = shareInstance.database?.executeUpdate("INSERT OR REPLACE INTO boxinfo(idx,title,singer,note,playtime,difficulty,bpm,bit,down) VALUES (?,?,?,?,?,?,?,?,(SELECT down FROM boxinfo where title = ?))",
                withArgumentsIn:[count,model.title!,model.singer!,String(model.music_note!),model.playtime!,model.difficulty!,String(model.music_bpm!),String(model.music_bit!),model.title!])
            if success==false{continue}
        }
        shareInstance.database?.close()
        return true
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
