//
//  PlayingQueueVC.swift
//  My Music
//
//  Created by ICON on 07/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import DropDown
import GoogleMobileAds

class PlayingQueueVC: UIViewController,UITableViewDelegate,UITableViewDataSource,AddPlaylistVCDelegate,SelectPlaylistVCDelegate,GADBannerViewDelegate {
    
    @IBOutlet weak var tbl_playingQueue: UITableView!
    @IBOutlet weak var view_navigationBar: UIView!
    @IBOutlet weak var btnOption: UIButton!
    @IBOutlet weak var bannerContainer: UIView!
    @IBOutlet weak var bannerContainer_height: NSLayoutConstraint!
    
    var bannerView: GADBannerView!
    
    var arrQueueSongs = [[String:Any]]()
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
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) == nil {
            self.view_navigationBar.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 1/255, alpha: 255/255)
        }
        else {
            let colorHex = UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) as! String
            self.view_navigationBar.backgroundColor = UIColor(hexString: colorHex)
        }
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_isPermissionGiven) as! Int == 0 {
            GlobalClass.showPermissionAlertMessage()
        }
        else if UserDefaults.standard.value(forKey: GlobalClass.UD_isPermissionGiven) as! Int == 1 {
            self.arrQueueSongs.removeAll()
            
            self.mediaItems = MPMediaQuery.songs().items!
            let queueData = Modeldata.getInstance().getAllQueueData()
            
            if queueData.count != 0 {
                let queueValue = queueData[0] as! playingQueueClass
                let songStr = queueValue.song_name
                let songArr = songStr.components(separatedBy: ",")
                
                for song in songArr {
                    //let queueSong = queue as! playingQueueClass
                    
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
                        
                        if song == name {
                            self.globalMediaItems.append(item)
                            
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
                            
                            self.arrQueueSongs.append(obj)
                        }
                    }
                }
            }
        }
        
        self.mediaItems.removeAll()
        
        for item in self.globalMediaItems {
            self.mediaItems.append(item)
        }
        
        for item in self.globalMediaItems {
            self.customMediaItems.append(item)
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
                    if self.arrQueueSongs.count != 0 {
                        UserDefaults.standard.set(self.arrQueueSongs[0]["name"], forKey: GlobalClass.UD_CurrentSong)
                    }
                }
            })
        }
        self.tbl_playingQueue.reloadData()
        
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
                        self.tbl_playingQueue.reloadData()
                    }
                }
            })
        }
    }
    
    @IBAction func btnMenu_Clicked(_ sender: UIButton) {
        self.slideMenuController()?.openLeft()
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
        let noDataLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.tbl_playingQueue.bounds.width, height: self.tbl_playingQueue.bounds.height))
        noDataLabel.textColor = UIColor.black
        noDataLabel.font = UIFont(name: "Georgia", size: 17.0)
        noDataLabel.textAlignment = .center
        self.tbl_playingQueue.backgroundView = noDataLabel
        if self.arrQueueSongs.count == 0 {
            noDataLabel.text = "No Data Found"
        }
        else {
            noDataLabel.text = ""
        }
        return self.arrQueueSongs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tbl_playingQueue.dequeueReusableCell(withIdentifier: "cellQueue") as! PlayingQueueCell
        
        cell.queue_name.text = self.arrQueueSongs[indexPath.row]["name"] as? String
        cell.queue_artist.text = self.arrQueueSongs[indexPath.row]["artist"] as? String
        cell.queue_image.image = self.arrQueueSongs[indexPath.row]["image"] as? UIImage
        cell.queue_image.layer.masksToBounds = true
        cell.queue_image.layer.cornerRadius = 25.0
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_CurrentSong) as! String == self.arrQueueSongs[indexPath.row]["name"] as! String {
            cell.img_equilizer.image = UIImage.gif(name: "equilizer")
            cell.img_equilizer.layer.masksToBounds = true
            cell.img_equilizer.layer.cornerRadius = 25.0
            
            if UserDefaults.standard.value(forKey: GlobalClass.UD_AccentColor) == nil {
                cell.queue_name.textColor = UIColor.black
            }
            else {
                let colorHex = UserDefaults.standard.value(forKey: GlobalClass.UD_AccentColor) as! String
                cell.queue_name.textColor = UIColor(hexString: colorHex)
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
            cell.queue_name.textColor = UIColor.black
        }
        
        cell.btnOption.tag = indexPath.row
        cell.btnOption.addTarget(self, action: #selector(self.btnOption_Clicked(sender:)), for: .touchUpInside)
        
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
                
                UserDefaults.standard.set(0, forKey: GlobalClass.UD_isPlayingQueue)
                GlobalClass.setCustomObjToUserDefaults(CustomeObj: [MPMediaItem]() as AnyObject, key: GlobalClass.UD_queueItems)
            }
            else if item == "Add to playlist" {
                
                let playlistData = Modeldata.getInstance().getAllPlaylistData()
                if playlistData.count == 0 {
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "AddPlaylistVC") as! AddPlaylistVC
                    objVC.delegate = self
                    objVC.songTitle = self.arrQueueSongs[sender.tag]["name"] as! String
                    objVC.isComefrom = 0
                    objVC.modalPresentationStyle = .overFullScreen
                    objVC.modalTransitionStyle = .crossDissolve
                    self.present(objVC, animated: true, completion: nil)
                }
                else {
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectPlaylistVC") as! SelectPlaylistVC
                    objVC.delegate = self
                    objVC.songTitle = self.arrQueueSongs[sender.tag]["name"] as! String
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
