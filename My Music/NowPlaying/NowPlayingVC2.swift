//
//  NowPlayingVC2.swift
//  My Music
//
//  Created by ICON on 26/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit
import MediaPlayer
import DropDown
import GoogleMobileAds

class NowPlayingVC2: UIViewController,UITableViewDelegate,UITableViewDataSource,AddPlaylistVCDelegate,SelectPlaylistVCDelegate,GADBannerViewDelegate {
    
    @IBOutlet weak var view_shuffle: UIView!
    @IBOutlet weak var img_nowPlaying: UIImageView!
    @IBOutlet weak var lblSongTitle: UILabel!
    @IBOutlet weak var lblSongArtist: UILabel!
    @IBOutlet weak var lblCurrentTime: UILabel!
    @IBOutlet weak var lblRemainingTime: UILabel!
    @IBOutlet weak var sliderIndicator: UISlider!
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var btnShuffle: UIButton!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var tblNowPlaying: UITableView!
    @IBOutlet weak var bannerContainer: UIView!
    @IBOutlet weak var bannerContainer_height: NSLayoutConstraint!
    
    var bannerView: GADBannerView!
    
    var isComeFrom = 0
    var arrSongs = [[String:Any]]()
    var mediaItems = [MPMediaItem]()
    var customMediaItems = [MPMediaItem]()
    var globalMediaItems = [MPMediaItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bannerContainer_height.constant = 0.0
        self.bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        self.bannerView.adUnitID = GlobalClass.UD_Bannerid
        self.bannerView.rootViewController = self
        self.bannerView.delegate = self
        bannerView.load(GADRequest())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        GlobalClass.songTimer.invalidate()
        GlobalClass.homeTimer.invalidate()
        
        self.view_shuffle.layer.cornerRadius = self.view_shuffle.frame.size.height/2
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) == nil {
            self.view_shuffle.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 1/255, alpha: 255/255)
            self.sliderIndicator.minimumTrackTintColor = UIColor(red: 255/255, green: 0/255, blue: 1/255, alpha: 255/255)
            self.sliderIndicator.thumbTintColor = UIColor(red: 255/255, green: 0/255, blue: 1/255, alpha: 255/255)
        }
        else {
            let colorHex = UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) as! String
            self.view_shuffle.backgroundColor = UIColor(hexString: colorHex)
            self.sliderIndicator.minimumTrackTintColor = UIColor(hexString: colorHex)
            self.sliderIndicator.thumbTintColor = UIColor(hexString: colorHex)
        }
        
        if self.isComeFrom == 1 {
            self.btnMenu.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        }
        self.img_nowPlaying.image = #imageLiteral(resourceName: "logo")
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_isPermissionGiven) as! Int == 0 {
            GlobalClass.showPermissionAlertMessage()
        }
        else if UserDefaults.standard.value(forKey: GlobalClass.UD_isPermissionGiven) as! Int == 1 {
            if GlobalClass.globalPlayer.nowPlayingItem != nil {
                let currentSong = GlobalClass.globalPlayer.nowPlayingItem
                if currentSong?.title == nil {
                    self.lblSongTitle.text = "unknown"
                }
                else {
                    self.lblSongTitle.text = currentSong?.title
                }
                
                if currentSong?.artist == nil {
                    self.lblSongArtist.text = "unknown"
                }
                else {
                    self.lblSongArtist.text = currentSong?.artist
                }
                
                if currentSong?.artwork?.image(at: CGSize(width: 50.0, height: 50.0)) == nil {
                    self.img_nowPlaying.image = #imageLiteral(resourceName: "logo")
                }
                else {
                    self.img_nowPlaying.image = currentSong?.artwork?.image(at: CGSize(width: 50.0, height: 50.0))
                }
                
                if self.img_nowPlaying.image == #imageLiteral(resourceName: "logo") {
                    self.img_nowPlaying.contentMode = .scaleAspectFit
                }
                else {
                    self.img_nowPlaying.contentMode = .scaleAspectFill
                    self.img_nowPlaying.clipsToBounds = true
                }
                self.sliderIndicator.maximumValue = Float((GlobalClass.globalPlayer.nowPlayingItem?.playbackDuration)!)
                self.sliderIndicator.minimumValue = 0.0
                
                self.sliderIndicator.value = Float(GlobalClass.globalPlayer.currentPlaybackTime)
                
                self.convertTimeIntervalToString()
                
                switch GlobalClass.globalPlayer.playbackState {
                case .playing:
                    self.btnPlayPause.setImage(#imageLiteral(resourceName: "ic_pause_white_36dp"), for: .normal)
                case .paused:
                    self.btnPlayPause.setImage(#imageLiteral(resourceName: "ic_play_white_36dp"), for: .normal)
                case .stopped:
                    self.btnPlayPause.setImage(#imageLiteral(resourceName: "ic_play_white_36dp"), for: .normal)
                default:
                    self.btnPlayPause.setImage(#imageLiteral(resourceName: "ic_play_white_36dp"), for: .normal)
                }
                
                switch GlobalClass.globalPlayer.shuffleMode {
                case .songs:
                    self.btnShuffle.setImage(#imageLiteral(resourceName: "shuffle-white"), for: .normal)
                case .off:
                    self.btnShuffle.setImage(#imageLiteral(resourceName: "shuffle"), for: .normal)
                default:
                    self.btnShuffle.setImage(#imageLiteral(resourceName: "shuffle"), for: .normal)
                }
            }
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
                    image =  #imageLiteral(resourceName: "logo.png")
                }
                else {
                    image = (item.artwork?.image(at: CGSize(width: 50.0, height: 50.0))!)!
                }
                
                let obj = ["name":name,"artist":artist,"image":image] as [String : Any]
                
                self.arrSongs.append(obj)
            }
            
            self.tblNowPlaying.reloadData()
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
        
        GlobalClass.songTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.convertTimeIntervalToString), userInfo: nil, repeats: true)
        GlobalClass.globalPlayer.beginGeneratingPlaybackNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerSongChanged), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerSongChanged), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
        
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
                        self.tblNowPlaying.reloadData()
                    }
                }
            })
        }
    }
    
    @IBAction func btnMenu_Clicked(_ sender: UIButton) {
        if self.isComeFrom == 1 {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            self.slideMenuController()?.openLeft()
        }
    }
    
    @IBAction func btnSearch_Clicked(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    @IBAction func playSlider_change(_ sender: UISlider) {
        if GlobalClass.globalPlayer.nowPlayingItem != nil {
            GlobalClass.globalPlayer.currentPlaybackTime = TimeInterval(self.sliderIndicator.value)
        }
    }
    
    @objc func convertTimeIntervalToString() {
        DispatchQueue.global().async {
            DispatchQueue.main.async(execute: {
                if GlobalClass.globalPlayer.nowPlayingItem != nil {
                    let totalTime : TimeInterval = (GlobalClass.globalPlayer.nowPlayingItem?.playbackDuration)!
                    var remainingTime : TimeInterval = totalTime - GlobalClass.globalPlayer.currentPlaybackTime
                    var elapsedTime : TimeInterval = GlobalClass.globalPlayer.currentPlaybackTime
                    
                    let elapsedHours = UInt8(elapsedTime / 3600.0)
                    elapsedTime -= (TimeInterval(elapsedHours) * 3600)
                    
                    let remainingHours = UInt8(remainingTime / 3600.0)
                    remainingTime -= (TimeInterval(remainingHours) * 3600)
                    
                    let elapsedMinutes = UInt8(elapsedTime / 60.0)
                    elapsedTime -= (TimeInterval(elapsedMinutes) * 60)
                    
                    let remainingMinutes = UInt8(remainingTime / 60.0)
                    remainingTime -= (TimeInterval(remainingMinutes) * 60)
                    
                    let elapsedSeconds = UInt8(elapsedTime)
                    elapsedTime -= TimeInterval(elapsedSeconds)
                    
                    let remainingSeconds = UInt8(remainingTime)
                    remainingTime -= TimeInterval(remainingSeconds)
                    
                    //add the leading zero for minutes, seconds and millseconds and store them as string constants
                    let strElapsedHours = String(format: "%02d", elapsedHours)
                    let strElapsedMinutes = String(format: "%02d", elapsedMinutes)
                    let strElapsedSeconds = String(format: "%02d", elapsedSeconds)
                    
                    let strRemainingHours = String(format: "%02d", remainingHours)
                    let strRemainingMinutes = String(format: "%02d", remainingMinutes)
                    let strRemainingSeconds = String(format: "%02d", remainingSeconds)
                    
                    self.lblCurrentTime.text = "\(strElapsedHours):\(strElapsedMinutes):\(strElapsedSeconds)"
                    self.lblRemainingTime.text = "\(strRemainingHours):\(strRemainingMinutes):\(strRemainingSeconds)"
                    //self.sliderIndicator.value = Float(GlobalClass.globalPlayer.currentPlaybackTime)
                    
                    switch GlobalClass.globalPlayer.playbackState {
                    case .playing:
                        self.btnPlayPause.setImage(#imageLiteral(resourceName: "ic_pause_white_36dp"), for: .normal)
                    case .paused:
                        self.btnPlayPause.setImage(#imageLiteral(resourceName: "ic_play_white_36dp"), for: .normal)
                    case .stopped:
                        self.btnPlayPause.setImage(#imageLiteral(resourceName: "ic_play_white_36dp"), for: .normal)
                    default:
                        self.btnPlayPause.setImage(#imageLiteral(resourceName: "ic_play_white_36dp"), for: .normal)
                    }
                    
                    switch GlobalClass.globalPlayer.shuffleMode {
                    case .songs:
                        self.btnShuffle.setImage(#imageLiteral(resourceName: "shuffle-white"), for: .normal)
                    case .off:
                        self.btnShuffle.setImage(#imageLiteral(resourceName: "shuffle"), for: .normal)
                    default:
                        self.btnShuffle.setImage(#imageLiteral(resourceName: "shuffle"), for: .normal)
                    }
                    
                    let currentSong = GlobalClass.globalPlayer.nowPlayingItem
                    if currentSong?.title == nil {
                        self.lblSongTitle.text = "unknown"
                    }
                    else {
                        self.lblSongTitle.text = currentSong?.title
                    }
                    
                    if currentSong?.artist == nil {
                        self.lblSongArtist.text = "unknown"
                    }
                    else {
                        self.lblSongArtist.text = currentSong?.artist
                    }
                    
                    if currentSong?.artwork?.image(at: CGSize(width: 50.0, height: 50.0)) == nil {
                        self.img_nowPlaying.image = #imageLiteral(resourceName: "logo")
                    }
                    else {
                        self.img_nowPlaying.image = currentSong?.artwork?.image(at: CGSize(width: 50.0, height: 50.0))
                    }
                    
                    if self.img_nowPlaying.image == #imageLiteral(resourceName: "logo") {
                        self.img_nowPlaying.contentMode = .scaleAspectFit
                    }
                    else {
                        self.img_nowPlaying.contentMode = .scaleAspectFill
                        self.img_nowPlaying.clipsToBounds = true
                    }
                    self.sliderIndicator.maximumValue = Float((GlobalClass.globalPlayer.nowPlayingItem?.playbackDuration)!)
                    self.sliderIndicator.minimumValue = 0.0
                    
                    self.sliderIndicator.value = Float(GlobalClass.globalPlayer.currentPlaybackTime)
                    
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let noDataLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.tblNowPlaying.bounds.width, height: self.tblNowPlaying.bounds.height))
        noDataLabel.textColor = UIColor.black
        noDataLabel.font = UIFont(name: "Georgia", size: 17.0)
        noDataLabel.textAlignment = .center
        self.tblNowPlaying.backgroundView = noDataLabel
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
        let cell = self.tblNowPlaying.dequeueReusableCell(withIdentifier: "cellNowPlaying") as! PlayingCell
        
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
    
    @IBAction func btnPlayPause_Clicked(_ sender: UIButton) {
        if GlobalClass.globalPlayer.nowPlayingItem == nil {
            GlobalClass.songTimer.invalidate()
            GlobalClass.songTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.convertTimeIntervalToString), userInfo: nil, repeats: true)
        }
        switch GlobalClass.globalPlayer.playbackState {
        case .playing:
            GlobalClass.globalPlayer.pause()
            self.btnPlayPause.setImage(#imageLiteral(resourceName: "ic_play_white_36dp"), for: .normal)
        case .paused:
            GlobalClass.globalPlayer.play()
            self.btnPlayPause.setImage(#imageLiteral(resourceName: "ic_pause_white_36dp"), for: .normal)
        case .stopped:
            GlobalClass.globalPlayer.play()
            self.btnPlayPause.setImage(#imageLiteral(resourceName: "ic_play_white_36dp"), for: .normal)
        default:
            self.btnPlayPause.setImage(#imageLiteral(resourceName: "ic_play_white_36dp"), for: .normal)
        }
    }
    
    @IBAction func btnNext_Clicked(_ sender: UIButton) {
        if GlobalClass.globalPlayer.nowPlayingItem == nil {
            GlobalClass.songTimer.invalidate()
            GlobalClass.songTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.convertTimeIntervalToString), userInfo: nil, repeats: true)
        }
        GlobalClass.globalPlayer.skipToNextItem()
        GlobalClass.globalPlayer.play()
    }
    
    @IBAction func btnPrevious_Clciked(_ sender: UIButton) {
        if GlobalClass.globalPlayer.nowPlayingItem == nil {
            GlobalClass.songTimer.invalidate()
            GlobalClass.songTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.convertTimeIntervalToString), userInfo: nil, repeats: true)
        }
        GlobalClass.globalPlayer.skipToPreviousItem()
        GlobalClass.globalPlayer.play()
    }
    
    @IBAction func btnShuffle_Clicked(_ sender: UIButton) {
        switch GlobalClass.globalPlayer.shuffleMode {
        case .songs:
            GlobalClass.globalPlayer.shuffleMode = .off
            self.btnShuffle.setImage(#imageLiteral(resourceName: "shuffle"), for: .normal)
        case .off:
            GlobalClass.globalPlayer.shuffleMode = .songs
            self.btnShuffle.setImage(#imageLiteral(resourceName: "shuffle-white"), for: .normal)
        default:
            GlobalClass.globalPlayer.shuffleMode = .off
            self.btnShuffle.setImage(#imageLiteral(resourceName: "shuffle"), for: .normal)
        }
    }
    
    //--------------------------------------------------------------------------------------------------------
    
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        self.bannerView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 50.0)
        self.bannerContainer.addSubview(self.bannerView)
        self.bannerContainer_height.constant = 50.0
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        self.bannerContainer_height.constant = 0.0
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
}
