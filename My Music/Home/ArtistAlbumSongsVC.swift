//
//  ArtistAlbumSongsVC.swift
//  My Music
//
//  Created by WOS on 19/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit
import MediaPlayer
import DropDown
import GoogleMobileAds

class ArtistAlbumSongsVC: UIViewController,UITableViewDelegate,UITableViewDataSource,AddPlaylistVCDelegate,SelectPlaylistVCDelegate,GADBannerViewDelegate {
    
    @IBOutlet weak var btnOption: UIButton!
    @IBOutlet weak var img_artistAlbum: UIImageView!
    @IBOutlet weak var lblArtistAlbumName: UILabel!
    @IBOutlet weak var tbl_songs: UITableView!
    @IBOutlet weak var bannerContainer: UIView!
    @IBOutlet weak var bannerContainer_height: NSLayoutConstraint!
    
    var bannerView: GADBannerView!
    var artistalbumName = ""
    var artistalbumImage = UIImage()
    var mediaItems = [MPMediaItem]()
    var customMediaItems = [MPMediaItem]()
    var globalMediaItems = [MPMediaItem]()
    var arrSongs = [[String:Any]]()
    
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
        
        self.lblArtistAlbumName.text = self.artistalbumName
        self.img_artistAlbum.image = self.artistalbumImage
        self.customMediaItems = self.mediaItems
        self.globalMediaItems = self.mediaItems
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
        
        if self.img_artistAlbum.image == #imageLiteral(resourceName: "logo") {
            self.img_artistAlbum.contentMode = .scaleAspectFit
        }
        else {
            self.img_artistAlbum.contentMode = .scaleAspectFill
            self.img_artistAlbum.clipsToBounds = true
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
                        self.tbl_songs.reloadData()
                    }
                }
            })
        }
    }
    
    @IBAction func btnBack_Clicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSearch_Clicked(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    @IBAction func btnOption_Clicked(_ sender: UIButton) {
        let dropDown = DropDown()
        dropDown.anchorView = self.btnOption
        dropDown.bottomOffset = CGPoint(x: 0, y: self.btnOption.bounds.height)
        dropDown.width = 150
        dropDown.dataSource = [
            "Shuffle All"
        ]
        
        dropDown.selectionAction = { (index, item) in
            if item == "Shuffle All" {
                GlobalClass.globalPlayer.shuffleMode = .songs
            }
        }
        dropDown.show()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrSongs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tbl_songs.dequeueReusableCell(withIdentifier: "ArtistAlbumSongCell") as! SongCell
        
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
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_isNowPlayingTheme) as! Int == 0 {
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "NowPlayingVC") as! NowPlayingVC
            objVC.isComeFrom = 1
            self.navigationController?.pushViewController(objVC, animated: true)
        }
        else if UserDefaults.standard.value(forKey: GlobalClass.UD_isNowPlayingTheme) as! Int == 1 {
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "NowPlayingVC2") as! NowPlayingVC2
            objVC.isComeFrom = 1
            self.navigationController?.pushViewController(objVC, animated: true)
        }
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
                for i in sender.tag ..< self.mediaItems.count {
                    self.customMediaItems.append(self.mediaItems[i])
                }
                for i in 0 ..< sender.tag {
                    self.customMediaItems.append(self.mediaItems[i])
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
                
                if UserDefaults.standard.value(forKey: GlobalClass.UD_isNowPlayingTheme) as! Int == 0 {
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "NowPlayingVC") as! NowPlayingVC
                    objVC.isComeFrom = 1
                    self.navigationController?.pushViewController(objVC, animated: true)
                }
                else if UserDefaults.standard.value(forKey: GlobalClass.UD_isNowPlayingTheme) as! Int == 1 {
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "NowPlayingVC2") as! NowPlayingVC2
                    objVC.isComeFrom = 1
                    self.navigationController?.pushViewController(objVC, animated: true)
                }
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
