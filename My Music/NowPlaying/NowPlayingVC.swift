//
//  NowPlayingVC.swift
//  My Music
//
//  Created by ICON on 11/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit
import MediaPlayer
import NotificationCenter
import GoogleMobileAds

class NowPlayingVC: UIViewController,GADBannerViewDelegate {
    
    @IBOutlet weak var view_playpause: UIView!
    @IBOutlet weak var img_nowPlaying: UIImageView!
    @IBOutlet weak var lblSongTitle: UILabel!
    @IBOutlet weak var lblSongArtist: UILabel!
    @IBOutlet weak var lblCurrentTime: UILabel!
    @IBOutlet weak var lblRemainingTime: UILabel!
    @IBOutlet weak var sliderIndicator: UISlider!
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var btnShuffle: UIButton!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var btnRepeat: UIButton!
    @IBOutlet weak var bannerContainer: UIView!
    @IBOutlet weak var bannerContainer_height: NSLayoutConstraint!
    
    var bannerView: GADBannerView!
    
    var isComeFrom = 0
    
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
        
        self.view_playpause.layer.cornerRadius = self.view_playpause.frame.size.height/2
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) == nil {
            self.view_playpause.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 1/255, alpha: 255/255)
            self.sliderIndicator.minimumTrackTintColor = UIColor(red: 255/255, green: 0/255, blue: 1/255, alpha: 255/255)
            self.sliderIndicator.thumbTintColor = UIColor(red: 255/255, green: 0/255, blue: 1/255, alpha: 255/255)
        }
        else {
            let colorHex = UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) as! String
            self.view_playpause.backgroundColor = UIColor(hexString: colorHex)
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
                    self.btnShuffle.setImage(#imageLiteral(resourceName: "shuffle-red"), for: .normal)
                case .off:
                    self.btnShuffle.setImage(#imageLiteral(resourceName: "shuffle"), for: .normal)
                default:
                    self.btnShuffle.setImage(#imageLiteral(resourceName: "shuffle"), for: .normal)
                }
                
                switch GlobalClass.globalPlayer.repeatMode {
                case .default:
                    self.btnRepeat.setImage(#imageLiteral(resourceName: "repeat"), for: .normal)
                case .all:
                    self.btnRepeat.setImage(#imageLiteral(resourceName: "repeat-red"), for: .normal)
                case .one:
                    self.btnRepeat.setImage(#imageLiteral(resourceName: "repeat-1"), for: .normal)
                default:
                    self.btnRepeat.setImage(#imageLiteral(resourceName: "repeat"), for: .normal)
                }
            }
        }
        
        GlobalClass.songTimer.invalidate()
        GlobalClass.songTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.convertTimeIntervalToString), userInfo: nil, repeats: true)
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
    
    @IBAction func playSlider_Change(_ sender: UISlider) {
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
                        self.btnShuffle.setImage(#imageLiteral(resourceName: "shuffle-red"), for: .normal)
                    case .off:
                        self.btnShuffle.setImage(#imageLiteral(resourceName: "shuffle"), for: .normal)
                    default:
                        self.btnShuffle.setImage(#imageLiteral(resourceName: "shuffle"), for: .normal)
                    }
                    
                    switch GlobalClass.globalPlayer.repeatMode {
                    case .default:
                        self.btnRepeat.setImage(#imageLiteral(resourceName: "repeat"), for: .normal)
                    case .all:
                        self.btnRepeat.setImage(#imageLiteral(resourceName: "repeat-red"), for: .normal)
                    case .one:
                        self.btnRepeat.setImage(#imageLiteral(resourceName: "repeat-1"), for: .normal)
                    default:
                        self.btnRepeat.setImage(#imageLiteral(resourceName: "repeat"), for: .normal)
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
            self.btnPlayPause.setImage(#imageLiteral(resourceName: "ic_pause_white_36dp"), for: .normal)
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
            self.btnShuffle.setImage(#imageLiteral(resourceName: "shuffle-red"), for: .normal)
        default:
            GlobalClass.globalPlayer.shuffleMode = .off
            self.btnShuffle.setImage(#imageLiteral(resourceName: "shuffle"), for: .normal)
        }
    }
    
    @IBAction func btnRepeat_Clicked(_ sender: UIButton) {
        switch GlobalClass.globalPlayer.repeatMode {
        case .default:
            GlobalClass.globalPlayer.repeatMode = .all
            self.btnRepeat.setImage(#imageLiteral(resourceName: "repeat-red"), for: .normal)
        case .all:
            GlobalClass.globalPlayer.repeatMode = .one
            self.btnRepeat.setImage(#imageLiteral(resourceName: "repeat-1"), for: .normal)
        case .one:
            GlobalClass.globalPlayer.repeatMode = .default
            self.btnRepeat.setImage(#imageLiteral(resourceName: "repeat"), for: .normal)
        default:
            GlobalClass.globalPlayer.repeatMode = .all
            self.btnRepeat.setImage(#imageLiteral(resourceName: "repeat-red"), for: .normal)
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
