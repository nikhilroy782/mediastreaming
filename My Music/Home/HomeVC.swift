//
//  HomeVC.swift
//  My Music
//
//  Created by ICON on 06/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit
import ViewPager_Swift
import MediaPlayer
import GoogleMobileAds

class HomeVC: UIViewController,ViewPagerControllerDelegate,ViewPagerControllerDataSource,SongsVCDelegate,GADBannerViewDelegate {
    
    @IBOutlet weak var view_navigationBar: UIView!
    @IBOutlet weak var btnOptions: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var img_CurrentSong: UIImageView!
    @IBOutlet weak var lbl_CurrentSongTitle: UILabel!
    @IBOutlet weak var lbl_CurrentSongArtist: UILabel!
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var view_miniPlayer: GradientView!
    @IBOutlet weak var song_progress: UIProgressView!
    @IBOutlet weak var viewContainer_height: NSLayoutConstraint!
    @IBOutlet weak var bannerContainer: UIView!
    @IBOutlet weak var bannerContainer_height: NSLayoutConstraint!
    
    var bannerView: GADBannerView!
    
    var viewPager : ViewPagerController!
    var options:ViewPagerOptions!
    let tabs = [
        ViewPagerTab(title: "SONGS", image: UIImage(named: "a")),
        ViewPagerTab(title: "ARTISTS", image: UIImage(named: "b")),
        ViewPagerTab(title: "ALBUMS", image: UIImage(named: "c")),
        ViewPagerTab(title: "RADIO", image: UIImage(named: "d"))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        GlobalClass.songTimer.invalidate()
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_isPermissionGiven) as! Int == 0 {
            self.view_miniPlayer.isHidden = true
        }
        else if UserDefaults.standard.value(forKey: GlobalClass.UD_isPermissionGiven) as! Int == 1 {
            self.view_miniPlayer.isHidden = false
        }
        
        self.viewContainer_height.constant = 72.0
        
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        let frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height - 134)
        options = ViewPagerOptions(viewPagerWithFrame: frame)
        options.tabType = ViewPagerTabType.basic
        options.tabViewTextFont = UIFont(name: "Georgia-Bold", size: 15.0)!
        options.fitAllTabsInView = true
        options.tabViewTextDefaultColor = .white
        options.isTabHighlightAvailable = true
        options.tabViewBackgroundHighlightColor = .clear
        options.tabViewTextDefaultColor = .white
        options.tabViewTextDefaultColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6)
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) == nil {
            self.view_navigationBar.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 1/255, alpha: 1.0)
            options.tabViewBackgroundDefaultColor = UIColor(red: 255/255, green: 0/255, blue: 1/255, alpha: 1.0)
        }
        else {
            let colorHex = UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) as! String
            self.view_navigationBar.backgroundColor = UIColor(hexString: colorHex)
            options.tabViewBackgroundDefaultColor = UIColor(hexString: colorHex)!
        }
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_AccentColor) == nil {
            options.tabIndicatorViewBackgroundColor = UIColor.black
            self.song_progress.progressTintColor = UIColor.black
        }
        else {
            let colorHex = UserDefaults.standard.value(forKey: GlobalClass.UD_AccentColor) as! String
            options.tabIndicatorViewBackgroundColor = UIColor(hexString: colorHex)!
            self.song_progress.progressTintColor = UIColor(hexString: colorHex)!
        }
        
        viewPager = ViewPagerController()
        viewPager.options = options
        viewPager.dataSource = self
        viewPager.delegate = self
        
        self.addChildViewController(viewPager)
        self.viewContainer.addSubview(viewPager.view)
        viewPager.didMove(toParentViewController: self)
        
        if GlobalClass.globalPlayer.nowPlayingItem != nil {
            let currentSong = GlobalClass.globalPlayer.nowPlayingItem
            if currentSong?.title == nil {
                self.lbl_CurrentSongTitle.text = "unknown"
            }
            else {
                self.lbl_CurrentSongTitle.text = currentSong?.title
            }
            
            if currentSong?.artist == nil {
                self.lbl_CurrentSongArtist.text = "unknown"
            }
            else {
                self.lbl_CurrentSongArtist.text = currentSong?.artist
            }
            
            if currentSong?.artwork?.image(at: CGSize(width: 50.0, height: 50.0)) == nil {
                self.img_CurrentSong.image = #imageLiteral(resourceName: "logo")
            }
            else {
                self.img_CurrentSong.image = currentSong?.artwork?.image(at: CGSize(width: 50.0, height: 50.0))
            }
            
            switch GlobalClass.globalPlayer.playbackState {
            case .playing:
                self.btnPlayPause.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            case .paused:
                self.btnPlayPause.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            case .stopped:
                self.btnPlayPause.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            default:
                self.btnPlayPause.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            }
            
            let currentTime = Float(GlobalClass.globalPlayer.currentPlaybackTime)
            let totalTime = Float((GlobalClass.globalPlayer.nowPlayingItem?.playbackDuration)!)
            
            self.song_progress.progress = currentTime/totalTime
        }
        
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
    
    @IBAction func btnPlayer_Clicked(_ sender: UIButton) {
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
    
    @IBAction func btnSearch_Clicked(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    @objc func checkCurrentSong() {
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                if GlobalClass.globalPlayer.nowPlayingItem != nil {
                    let currentSong = GlobalClass.globalPlayer.nowPlayingItem
                    if currentSong?.title == nil {
                        self.lbl_CurrentSongTitle.text = "unknown"
                    }
                    else {
                        self.lbl_CurrentSongTitle.text = currentSong?.title
                    }
                    
                    if currentSong?.artist == nil {
                        self.lbl_CurrentSongArtist.text = "unknown"
                    }
                    else {
                        self.lbl_CurrentSongArtist.text = currentSong?.artist
                    }
                    
                    if currentSong?.artwork?.image(at: CGSize(width: 50.0, height: 50.0)) == nil {
                        self.img_CurrentSong.image = #imageLiteral(resourceName: "logo")
                    }
                    else {
                        self.img_CurrentSong.image = currentSong?.artwork?.image(at: CGSize(width: 50.0, height: 50.0))
                    }
                    
                    switch GlobalClass.globalPlayer.playbackState {
                    case .playing:
                        self.btnPlayPause.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
                    case .paused:
                        self.btnPlayPause.setImage(#imageLiteral(resourceName: "play"), for: .normal)
                    case .stopped:
                        self.btnPlayPause.setImage(#imageLiteral(resourceName: "play"), for: .normal)
                    default:
                        self.btnPlayPause.setImage(#imageLiteral(resourceName: "play"), for: .normal)
                    }
                    
                    let currentTime = Float(GlobalClass.globalPlayer.currentPlaybackTime)
                    let totalTime = Float((GlobalClass.globalPlayer.nowPlayingItem?.playbackDuration)!)
                    
                    self.song_progress.progress = currentTime/totalTime
                }
            }
        }
    }
    
    @IBAction func btnMenu_Clicked(_ sender: UIButton) {
        self.slideMenuController()?.openLeft()
    }
    
    func numberOfPages() -> Int {
        return tabs.count
    }
    
    func viewControllerAtPosition(position: Int) -> UIViewController {
        if position == 0 {
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SongsVC") as! SongsVC
            objVC.delegate = self
            return objVC
        }
        else if position == 1 {
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "ArtistsVC") as! ArtistsVC
            return objVC
        }
        else if position == 2 {
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "AlbumsVC") as! AlbumsVC
            return objVC
        }
        else if position == 3 {
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "RadioVC") as! RadioVC
            return objVC
        }
        return UIViewController()
    }
    
    func tabsForPages() -> [ViewPagerTab] {
        return tabs
    }
    
    func sendDefaultSongData(song: [String : Any], mediaItems: [MPMediaItem]) {
        if GlobalClass.globalPlayer.nowPlayingItem == nil {
            self.lbl_CurrentSongTitle.text = song["name"] as? String
            self.lbl_CurrentSongArtist.text = song["artist"] as? String
            self.img_CurrentSong.image = song["image"] as? UIImage
            self.song_progress.progress = 0.0
            
            let mediaCollection = MPMediaItemCollection(items: mediaItems)
            GlobalClass.globalPlayer.setQueue(with: mediaCollection)
        }
        
        
    }
    
    func setHomeTimer() {
        self.checkCurrentSong()
    }
    
    @IBAction func btnPlayPause_Clicked(_ sender: UIButton) {
        switch GlobalClass.globalPlayer.playbackState {
        case .playing:
            GlobalClass.globalPlayer.pause()
        case .paused:
            GlobalClass.globalPlayer.play()
        case .stopped:
            GlobalClass.globalPlayer.play()
        default:
            GlobalClass.globalPlayer.play()
        }
    }
    
    //--------------------------------------------------------------------------------------------------------
    
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        self.bannerView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 50.0)
        self.bannerContainer.addSubview(self.bannerView)
        self.bannerContainer_height.constant = 50.0
        self.viewContainer_height.constant = 122.0
        
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        let frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height - 184)
        options = ViewPagerOptions(viewPagerWithFrame: frame)
        options.tabType = ViewPagerTabType.basic
        options.tabViewTextFont = UIFont(name: "Georgia-Bold", size: 15.0)!
        options.fitAllTabsInView = true
        options.tabViewTextDefaultColor = .white
        options.isTabHighlightAvailable = true
        options.tabViewBackgroundHighlightColor = .clear
        options.tabViewTextDefaultColor = .white
        options.tabViewTextDefaultColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6)
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) == nil {
            self.view_navigationBar.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 1/255, alpha: 1.0)
            options.tabViewBackgroundDefaultColor = UIColor(red: 255/255, green: 0/255, blue: 1/255, alpha: 1.0)
        }
        else {
            let colorHex = UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) as! String
            self.view_navigationBar.backgroundColor = UIColor(hexString: colorHex)
            options.tabViewBackgroundDefaultColor = UIColor(hexString: colorHex)!
        }
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_AccentColor) == nil {
            options.tabIndicatorViewBackgroundColor = UIColor.black
            self.song_progress.progressTintColor = UIColor.black
        }
        else {
            let colorHex = UserDefaults.standard.value(forKey: GlobalClass.UD_AccentColor) as! String
            options.tabIndicatorViewBackgroundColor = UIColor(hexString: colorHex)!
            self.song_progress.progressTintColor = UIColor(hexString: colorHex)!
        }
        
        viewPager = ViewPagerController()
        viewPager.options = options
        viewPager.dataSource = self
        viewPager.delegate = self
        
        self.addChildViewController(viewPager)
        self.viewContainer.addSubview(viewPager.view)
        viewPager.didMove(toParentViewController: self)
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        self.bannerContainer_height.constant = 0.0
        self.viewContainer_height.constant = 72.0
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
