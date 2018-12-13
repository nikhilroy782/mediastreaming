//
//  GlobalPlayer.swift
//  My Music
//
//  Created by ICON on 21/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import Foundation
import MediaPlayer
import UIKit
import NotificationCenter
import AVFoundation

class GlobalClass {
    
    static let UD_PrimaryColor = "PrimaryColor"
    static let UD_isPermissionGiven = "isPermissionGiven"
    static let UD_isNowPlayingTheme = "isNowPlayingTheme"
    static let UD_AccentColor = "AccentColor"
    static let UD_DisplayType = "DisplayType"
    static let UD_GetStart = "GetStart"
    static let UD_isPlayingQueue = "isPlayingQueue"
    static let UD_AdAppid = "ca-app-pub-8404402538495550~5897261226"
    static let UD_Bannerid = "ca-app-pub-8404402538495550/4667654624"
    static let UD_CurrentSong = "CurrentSong"
    static let UD_queueItems = "queueItems"
    
    static let globalPlayer = MPMusicPlayerController.systemMusicPlayer
    static var player: AVPlayer!
    static var songTimer = Timer()
    static var homeTimer = Timer()
    static var equilizerTimer = Timer()
    
    static func showPermissionAlertMessage() -> Void {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Music-Play", message: "Allow Music-Play App to Access Music Library from Settings", preferredStyle: .alert)
            let settingAction = UIAlertAction(title: "Go to settings", style: .default) { (action) in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (action) in
                        print("setting")
                    })
                }
            }
            let noAction = UIAlertAction(title: "Not Now", style: .destructive)
            
            alert.addAction(settingAction)
            alert.addAction(noAction)
            
            UIApplication.shared.delegate?.window!?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    class func setCustomObjToUserDefaults(CustomeObj: AnyObject , key: String) {
        let defaults = UserDefaults.standard
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: CustomeObj)
        defaults.set(encodedData, forKey: key)
        defaults.synchronize()
    }
    
    class func getCustomObjFromUserDefaults(key: String) -> AnyObject {
        let defaults = UserDefaults.standard
        let decoded  = defaults.object(forKey: key) as! NSData
        let decodedTeams = NSKeyedUnarchiver.unarchiveObject(with: decoded as Data)! as AnyObject
        return decodedTeams
    }
    
}
