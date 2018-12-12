//
//  SongsVC.swift
//  My Music
//
//  Created by ICON on 06/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit
import MediaPlayer
import DropDown
import Toast_Swift
import NotificationCenter

protocol SongsVCDelegate {
    func sendDefaultSongData(song : [String:Any], mediaItems : [MPMediaItem])
    func setHomeTimer()
}

class SongsVC: UIViewController,UITableViewDelegate,UITableViewDataSource,AddPlaylistVCDelegate,SelectPlaylistVCDelegate {
    
    @IBOutlet weak var tbl_songs: UITableView!
    
    var delegate : SongsVCDelegate!
    var arrSongs = [[String:Any]]()
    var mediaItems = [MPMediaItem]()
    var customMediaItems = [MPMediaItem]()
    var globalMediaItems = [MPMediaItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        GlobalClass.songTimer.invalidate()
        GlobalClass.homeTimer.invalidate()
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_isPermissionGiven) as! Int == 0 {
            GlobalClass.showPermissionAlertMessage()
        }
        else if UserDefaults.standard.value(forKey: GlobalClass.UD_isPermissionGiven) as! Int == 1 {
            self.globalMediaItems = MPMediaQuery.songs().items!
            self.mediaItems = MPMediaQuery.songs().items!
            self.customMediaItems = MPMediaQuery.songs().items!
            
            for item in self.mediaItems {
                var name = ""
                var artist = ""
                var image = UIImage()
                
                if item.title == nil {
                    name = "unknown"
                }
                else {
                    name = item.title!
                }
                
                if item.artist == nil {
                    artist = "unknown"
                }
                else {
                    artist = item.artist!
                }
                
                if item.artwork?.image(at: CGSize(width: 50.0, height: 50.0)) == nil {
                    image = #imageLiteral(resourceName: "logo")
                }
                else {
                    image = (item.artwork?.image(at: CGSize(width: 50.0, height: 50.0))!)!
                }
                
                let obj = ["name":name,"artist":artist,"image":image] as [String : Any]
                
                self.arrSongs.append(obj)
            }
            
            DispatchQueue.global().async {
                DispatchQueue.main.async(execute: {
                    if GlobalClass.globalPlayer.nowPlayingItem != nil {
                        let currentSong = GlobalClass.globalPlayer.nowPlayingItem!
                        if currentSong.title != nil {
                            UserDefaults.standard.set(currentSong.title!, forKey: GlobalClass.UD_CurrentSong)
                        }
                    }
                    else {
                        if self.arrSongs.count != 0 {
                            UserDefaults.standard.set(self.arrSongs[0]["name"], forKey: GlobalClass.UD_CurrentSong)
                        }
                    }
                })
            }
            
            self.tbl_songs.reloadData()
            
            if self.arrSongs.count != 0 {
                self.delegate.sendDefaultSongData(song: self.arrSongs[0], mediaItems: self.mediaItems)
            }
            GlobalClass.homeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.startHomeTimer), userInfo: nil, repeats: true)
            GlobalClass.globalPlayer.beginGeneratingPlaybackNotifications()
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerSongChanged), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerSongChanged), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
        }
    }
    
    @objc func startHomeTimer() {
        self.delegate.setHomeTimer()
    }
    
    @objc func playerSongChanged() {
        if UserDefaults.standard.value(forKey: GlobalClass.UD_isPlayingQueue) as! Int == 1 {
            UserDefaults.standard.set(0, forKey: GlobalClass.UD_isPlayingQueue)
            let mediaQueue = GlobalClass.getCustomObjFromUserDefaults(key: GlobalClass.UD_queueItems) as! [MPMediaItem]
            let mediaCollection = MPMediaItemCollection(items: mediaQueue)
            GlobalClass.globalPlayer.setQueue(with: mediaCollection)
            switch GlobalClass.globalPlayer.shuffleMode {
            case .songs:
                GlobalClass.globalPlayer.shuffleMode = .off
                GlobalClass.globalPlayer.play()
                GlobalClass.globalPlayer.shuffleMode = .songs
            case .off:
                GlobalClass.globalPlayer.play()
            default:
                GlobalClass.globalPlayer.shuffleMode = .off
                GlobalClass.globalPlayer.play()
            }
            GlobalClass.setCustomObjToUserDefaults(CustomeObj: [MPMediaItem]() as AnyObject, key: GlobalClass.UD_queueItems)
        }
        DispatchQueue.global().async {
            DispatchQueue.main.async(execute: {
                if GlobalClass.globalPlayer.nowPlayingItem != nil {
                    let currentSong = GlobalClass.globalPlayer.nowPlayingItem!
                    if currentSong.title != nil {
                        UserDefaults.standard.set(currentSong.title!, forKey: GlobalClass.UD_CurrentSong)
                        self.tbl_songs.reloadData()
                    }
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let noDataLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.tbl_songs.bounds.width, height: self.tbl_songs.bounds.height))
        noDataLabel.textColor = UIColor.black
        noDataLabel.font = UIFont(name: "Georgia", size: 17.0)
        noDataLabel.textAlignment = .center
        self.tbl_songs.backgroundView = noDataLabel
        if self.arrSongs.count == 0 {
            noDataLabel.text = "No Data Found"
        }
        else {
            noDataLabel.text = ""
        }
        return self.arrSongs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tbl_songs.dequeueReusableCell(withIdentifier: "cellSong") as! SongCell
        
        cell.song_name.text = self.arrSongs[indexPath.row]["name"] as? String
        cell.song_artist.text = self.arrSongs[indexPath.row]["artist"] as? String
        cell.song_image.image = self.arrSongs[indexPath.row]["image"] as? UIImage
        cell.song_image.layer.masksToBounds = true
        cell.song_image.layer.cornerRadius = 25.0
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_CurrentSong) as! String == self.arrSongs[indexPath.row]["name"] as! String {
            cell.img_equilizer.image = UIImage.gif(name: "equilizer")
            cell.img_equilizer.layer.masksToBounds = true
            cell.img_equilizer.layer.cornerRadius = 25.0
            
            if UserDefaults.standard.value(forKey: GlobalClass.UD_AccentColor) == nil {
                cell.song_name.textColor = UIColor.black
            }
            else {
                let colorHex = UserDefaults.standard.value(forKey: GlobalClass.UD_AccentColor) as! String
                cell.song_name.textColor = UIColor(hexString: colorHex)
            }
            switch GlobalClass.globalPlayer.playbackState {
            case .playing:
                cell.img_equilizer.isHidden = false
            case .paused:
                cell.img_equilizer.isHidden = true
            case .stopped:
                cell.img_equilizer.isHidden = true
            default:
                cell.img_equilizer.isHidden = true
            }
        }
        else {
            cell.img_equilizer.isHidden = true
            cell.song_name.textColor = UIColor.black
        }
        cell.btnOptions.tag = indexPath.row
        cell.btnOptions.addTarget(self, action: #selector(self.btnOption_Clicked(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.customMediaItems.removeAll()
        for i in indexPath.row ..< self.globalMediaItems.count {
            self.customMediaItems.append(self.globalMediaItems[i])
        }
        for i in 0 ..< indexPath.row {
            self.customMediaItems.append(self.globalMediaItems[i])
        }
        
        self.mediaItems.removeAll()
        
        for item in self.customMediaItems {
            self.mediaItems.append(item)
        }
        let mediaCollection = MPMediaItemCollection(items: mediaItems)
        GlobalClass.globalPlayer.setQueue(with: mediaCollection)
        switch GlobalClass.globalPlayer.shuffleMode {
        case .songs:
            GlobalClass.globalPlayer.shuffleMode = .off
            GlobalClass.globalPlayer.play()
            GlobalClass.globalPlayer.shuffleMode = .songs
        case .off:
            GlobalClass.globalPlayer.play()
        default:
            GlobalClass.globalPlayer.shuffleMode = .off
            GlobalClass.globalPlayer.play()
        }
        
        let isDeleted = Modeldata.getInstance().deleteQueueData()
        print(isDeleted)
        
        UserDefaults.standard.set(0, forKey: GlobalClass.UD_isPlayingQueue)
        GlobalClass.setCustomObjToUserDefaults(CustomeObj: [MPMediaItem]() as AnyObject, key: GlobalClass.UD_queueItems)
    }
    
    @objc func btnOption_Clicked(sender:UIButton) {
        let dropDown = DropDown()
        dropDown.anchorView = sender
        dropDown.bottomOffset = CGPoint(x: 0, y: sender.bounds.height)
        dropDown.width = 150
        dropDown.dataSource = [
            "Play",
            "Play next",
            "Add to playlist"
        ]
        dropDown.selectionAction = { (index, item) in
            if item == "Play" {
                self.customMediaItems.removeAll()
                for i in sender.tag ..< self.globalMediaItems.count {
                    self.customMediaItems.append(self.globalMediaItems[i])
                }
                for i in 0 ..< sender.tag {
                    self.customMediaItems.append(self.globalMediaItems[i])
                }
                
                self.mediaItems.removeAll()
                
                for item in self.customMediaItems {
                    self.mediaItems.append(item)
                }
                
                let mediaCollection = MPMediaItemCollection(items: self.mediaItems)
                GlobalClass.globalPlayer.setQueue(with: mediaCollection)
                switch GlobalClass.globalPlayer.shuffleMode {
                case .songs:
                    GlobalClass.globalPlayer.shuffleMode = .off
                    GlobalClass.globalPlayer.play()
                    GlobalClass.globalPlayer.shuffleMode = .songs
                case .off:
                    GlobalClass.globalPlayer.play()
                default:
                    GlobalClass.globalPlayer.shuffleMode = .off
                    GlobalClass.globalPlayer.play()
                }
                
                let isDeleted = Modeldata.getInstance().deleteQueueData()
                print(isDeleted)
                
                UserDefaults.standard.set(0, forKey: GlobalClass.UD_isPlayingQueue)
                GlobalClass.setCustomObjToUserDefaults(CustomeObj: [MPMediaItem]() as AnyObject, key: GlobalClass.UD_queueItems)
            }
            else if item == "Play next" {
                if GlobalClass.globalPlayer.nowPlayingItem != nil {
                    let queueData = Modeldata.getInstance().getAllQueueData()
                    if queueData.count == 0 {
                        let currentSong = GlobalClass.globalPlayer.nowPlayingItem!
                        var currentSongName = ""
                        if currentSong.title == nil {
                            currentSongName = "unknown"
                        }
                        else {
                            currentSongName = currentSong.title!
                        }
                        
                        let queue = playingQueueClass()
                        queue.song_name = currentSongName + "," + (self.arrSongs[sender.tag]["name"] as! String)
                        let isInserted = Modeldata.getInstance().addQueueData(queueinfo: queue)
                        print(isInserted)
                        
                        self.view.makeToast("1 song added to queue")
                        
                        let queueArr = Modeldata.getInstance().getAllQueueData()
                        if queueArr.count != 0 {
                            let queueElement = queueArr[0] as! playingQueueClass
                            let strSongsName = queueElement.song_name
                            let arrSongsName = strSongsName.components(separatedBy: ",")
                            self.mediaItems.removeAll()
                            self.customMediaItems.removeAll()
                            for song in arrSongsName {
                                for item in self.globalMediaItems {
                                    if item.title != nil {
                                        if song == item.title! {
                                            self.mediaItems.append(item)
                                            self.customMediaItems.append(item)
                                        }
                                    }
                                }
                            }
                            self.mediaItems.remove(at: 0)
                            self.customMediaItems.remove(at: 0)
                            UserDefaults.standard.set(1, forKey: GlobalClass.UD_isPlayingQueue)
                            GlobalClass.setCustomObjToUserDefaults(CustomeObj: self.mediaItems as AnyObject, key: GlobalClass.UD_queueItems)
                        }
                    }
                    else {
                        let queueValue = queueData[0] as! playingQueueClass
                        let id = queueValue.id
                        let songValue = queueValue.song_name
                        var songValueArr = songValue.components(separatedBy: ",")
                        if GlobalClass.globalPlayer.nowPlayingItem != nil {
                            let currentSong = GlobalClass.globalPlayer.nowPlayingItem!
                            var currentSongName = ""
                            if currentSong.title == nil {
                                currentSongName = "unknown"
                            }
                            else {
                                currentSongName = currentSong.title!
                            }
                            
                            if songValueArr.contains(currentSongName) == true {
                                let indexOfSong = songValueArr.index(of: currentSongName)
                                if indexOfSong == songValueArr.count - 1 {
                                    songValueArr.append(self.arrSongs[sender.tag]["name"] as! String)
                                }
                                else {
                                    songValueArr.insert(self.arrSongs[sender.tag]["name"] as! String, at: indexOfSong! + 1)
                                }
                            }
                            let queue = playingQueueClass()
                            queue.id = id
                            queue.song_name = songValueArr.joined(separator: ",")
                            
                            let isUpdated = Modeldata.getInstance().updateQueueData(queueData: queue)
                            print(isUpdated)
                            
                            self.view.makeToast("1 song added to queue")
                            
                            let indexValue = songValueArr.index(of: currentSongName)
                            self.mediaItems.removeAll()
                            self.customMediaItems.removeAll()
                            for i in indexValue! ..< songValueArr.count {
                                for item in self.globalMediaItems {
                                    if item.title != nil {
                                        if songValueArr[i] == item.title! {
                                            self.mediaItems.append(item)
                                            self.customMediaItems.append(item)
                                        }
                                    }
                                }
                            }
                            self.mediaItems.remove(at: 0)
                            self.customMediaItems.remove(at: 0)
                            UserDefaults.standard.set(1, forKey: GlobalClass.UD_isPlayingQueue)
                            GlobalClass.setCustomObjToUserDefaults(CustomeObj: self.mediaItems as AnyObject, key: GlobalClass.UD_queueItems)
                        }
                    }
                }
            }
            else if item == "Add to playlist" {
                
                let playlistData = Modeldata.getInstance().getAllPlaylistData()
                if playlistData.count == 0 {
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "AddPlaylistVC") as! AddPlaylistVC
                    objVC.delegate = self
                    objVC.songTitle = self.arrSongs[sender.tag]["name"] as! String
                    objVC.isComefrom = 0
                    objVC.modalPresentationStyle = .overFullScreen
                    objVC.modalTransitionStyle = .crossDissolve
                    self.present(objVC, animated: true, completion: nil)
                }
                else {
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectPlaylistVC") as! SelectPlaylistVC
                    objVC.delegate = self
                    objVC.songTitle = self.arrSongs[sender.tag]["name"] as! String
                    objVC.modalPresentationStyle = .overFullScreen
                    objVC.modalTransitionStyle = .crossDissolve
                    self.present(objVC, animated: true, completion: nil)
                }
            }
        }
        
        dropDown.show()
    }
    
    func songAdded(isAddClicked: Bool, message: String, songTitle: String) {
        if isAddClicked == false {
            self.view.makeToast(message)
        }
        else if isAddClicked == true {
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "AddPlaylistVC") as! AddPlaylistVC
            objVC.delegate = self
            objVC.songTitle = songTitle
            objVC.isComefrom = 0
            objVC.modalPresentationStyle = .overFullScreen
            objVC.modalTransitionStyle = .crossDissolve
            self.present(objVC, animated: true, completion: nil)
        }
    }
    
    func playlistAdded(isComefrom: Int) {
        self.view.makeToast("Song Added Successfully")
    }
    
}
