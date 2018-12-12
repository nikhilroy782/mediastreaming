//
//  PlaylistVC.swift
//  My Music
//
//  Created by ICON on 09/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit
import Toast_Swift
import GoogleMobileAds

class PlaylistVC: UIViewController,UITableViewDelegate,UITableViewDataSource,AddPlaylistVCDelegate,GADBannerViewDelegate {
    
    @IBOutlet weak var view_navigationBar: UIView!
    @IBOutlet weak var tbl_playlist: UITableView!
    @IBOutlet weak var bannerContainer: UIView!
    @IBOutlet weak var bannerContainer_height: NSLayoutConstraint!
    
    var bannerView: GADBannerView!
    var playlistArr = [[String:String]]()
    
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
            let playlistData = Modeldata.getInstance().getAllPlaylistData()
            
            self.playlistArr.removeAll()
            for item in playlistData {
                let playlistInfo = item as! playlistClass
                let objPlaylist = ["id" : playlistInfo.id, "playlist_name" : playlistInfo.playlist_name, "playlist_song" : playlistInfo.playlist_song]
                self.playlistArr.append(objPlaylist)
            }
            
            self.tbl_playlist.reloadData()
        }
    }
    
    @IBAction func btnMenu_Clicked(_ sender: UIButton) {
        self.slideMenuController()?.openLeft()
    }
    
    @IBAction func btnSearch_Clicked(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    @IBAction func btnAdd_Clicked(_ sender: UIButton) {
        if UserDefaults.standard.value(forKey: GlobalClass.UD_isPermissionGiven) as! Int == 0 {
            GlobalClass.showPermissionAlertMessage()
        }
        else if UserDefaults.standard.value(forKey: GlobalClass.UD_isPermissionGiven) as! Int == 1 {
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "AddPlaylistVC") as! AddPlaylistVC
            objVC.delegate = self
            objVC.isComefrom = 1
            objVC.modalPresentationStyle = .overFullScreen
            objVC.modalTransitionStyle = .crossDissolve
            self.present(objVC,animated: true,completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let noDataLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.tbl_playlist.bounds.width, height: self.tbl_playlist.bounds.height))
        noDataLabel.textColor = UIColor.black
        noDataLabel.font = UIFont(name: "Georgia", size: 17.0)
        noDataLabel.textAlignment = .center
        self.tbl_playlist.backgroundView = noDataLabel
        if self.playlistArr.count == 0 {
            noDataLabel.text = "No Data Found"
        }
        else {
            noDataLabel.text = ""
        }
        return self.playlistArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tbl_playlist.dequeueReusableCell(withIdentifier: "PlaylistCell") as! PlaylistCell
        cell.playlist_name.text = self.playlistArr[indexPath.row]["playlist_name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "PlaylistSongVC") as! PlaylistSongVC
        objVC.playlistSongs = self.playlistArr[indexPath.row]["playlist_song"]!
        objVC.playlistId = self.playlistArr[indexPath.row]["id"]!
        objVC.playlistName = self.playlistArr[indexPath.row]["playlist_name"]!
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let isDeleted = Modeldata.getInstance().deletePlaylist(id: self.playlistArr[indexPath.row]["id"]!)
            print(isDeleted)
            self.playlistArr.remove(at: indexPath.row)
            self.tbl_playlist.reloadData()
        }
    }
    
    func playlistAdded(isComefrom: Int) {
        let playlistData = Modeldata.getInstance().getAllPlaylistData()
        
        if playlistData.count != 0 {
            self.playlistArr.removeAll()
            for item in playlistData {
                let playlistInfo = item as! playlistClass
                let objPlaylist = ["id" : playlistInfo.id, "playlist_name" : playlistInfo.playlist_name, "playlist_song" : playlistInfo.playlist_song]
                self.playlistArr.append(objPlaylist)
            }
            self.tbl_playlist.reloadData()
            self.view.makeToast("Playlist Added Successfully")
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
