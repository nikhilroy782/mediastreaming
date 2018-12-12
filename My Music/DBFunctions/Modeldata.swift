//
//  Modeldata.swift
//  swift_database
//
//  Created by Mitesh Ramani on 5/15/18.
//  Copyright © 2018 Mitesh Ramani. All rights reserved.
//

import UIKit
let sharedInstance = Modeldata()
class Modeldata: NSObject {

    var database: FMDatabase? = nil
    
    class func getInstance() -> Modeldata
    {
        if(sharedInstance.database == nil)
        {
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("MyMusic.db").path
            sharedInstance.database = FMDatabase(path: path)
            print(path)
            
        }
        return sharedInstance
    }
    //Insert data
    func addPlaylistData(playlistinfo: playlistClass) -> Bool {
        sharedInstance.database!.open()
        
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO playlist (playlist_name,playlist_song) VALUES (?,?);", withArgumentsIn: [playlistinfo.playlist_name,playlistinfo.playlist_song])
        sharedInstance.database!.close()
        return isInserted
    }
    
    func addQueueData(queueinfo: playingQueueClass) -> Bool {
        sharedInstance.database!.open()
        
        let isInserted = sharedInstance.database!.executeUpdate("INSERT INTO playingQueue (song_name) VALUES (?);", withArgumentsIn: [queueinfo.song_name])
        sharedInstance.database!.close()
        return isInserted
    }
    
    //Get Data
    func getAllPlaylistData() -> NSMutableArray {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM playlist", withArgumentsIn: [])
        let resultPlaylistInfo : NSMutableArray = NSMutableArray()
        if (resultSet != nil) {
            while resultSet.next() {
                let playlistinfo : playlistClass = playlistClass()
                playlistinfo.id = resultSet.string(forColumn: "id")!
                playlistinfo.playlist_name = resultSet.string(forColumn: "playlist_name")!
                playlistinfo.playlist_song = resultSet.string(forColumn: "playlist_song")!
                resultPlaylistInfo.add(playlistinfo)
            }
        }
        sharedInstance.database!.close()
        return resultPlaylistInfo
    }
    
    func getAllQueueData() -> NSMutableArray {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM playingQueue", withArgumentsIn: [])
        let resultQueueInfo : NSMutableArray = NSMutableArray()
        if (resultSet != nil) {
            while resultSet.next() {
                let queueinfo : playingQueueClass = playingQueueClass()
                queueinfo.id = resultSet.string(forColumn: "id")!
                queueinfo.song_name = resultSet.string(forColumn: "song_name")!
                resultQueueInfo.add(queueinfo)
            }
        }
        sharedInstance.database!.close()
        return resultQueueInfo
    }
    
    // Update Data
    func updatePlaylistData(playlistData: playlistClass) -> Bool {
        sharedInstance.database!.open()
        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE playlist SET playlist_song=? WHERE id=?", withArgumentsIn: [playlistData.playlist_song,playlistData.id])
        sharedInstance.database!.close()
        return isUpdated
    }
    
    func updateQueueData(queueData: playingQueueClass) -> Bool {
        sharedInstance.database!.open()
        let isUpdated = sharedInstance.database!.executeUpdate("UPDATE playingQueue SET song_name=? WHERE id=?", withArgumentsIn: [queueData.song_name,queueData.id])
        sharedInstance.database!.close()
        return isUpdated
    }
    
    //Delete Data
    func deleteQueueData() -> Bool {
        sharedInstance.database!.open()
        let isDeleted = sharedInstance.database!.executeUpdate("DELETE FROM playingQueue", withArgumentsIn: [])
        sharedInstance.database!.close()
        return isDeleted
    }
    
    func deletePlaylist(id : String) -> Bool {
        sharedInstance.database!.open()
        let isDeleted = sharedInstance.database!.executeUpdate("DELETE FROM playlist WHERE id=?", withArgumentsIn: [id])
        sharedInstance.database!.close()
        return isDeleted
    }
    
   
}
