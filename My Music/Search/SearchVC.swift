//
//  SearchVC.swift
//  My Music
//
//  Created by WOS on 27/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit
import MediaPlayer
import DropDown
import Toast_Swift
import GoogleMobileAds

class SearchVC: UIViewController,UITableViewDelegate,UITableViewDataSource,AddPlaylistVCDelegate,SelectPlaylistVCDelegate,GADBannerViewDelegate {
    
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblSearch_result: UITableView!
    @IBOutlet weak var view_navigationBar: UIView!
    @IBOutlet weak var view_search: UIView!
    @IBOutlet weak var bannerContainer: UIView!
    @IBOutlet weak var bannerContainer_height: NSLayoutConstraint!
    
    var bannerView: GADBannerView!
    var mediaItems = [MPMediaItem]()
    var customMediaItems = [MPMediaItem]()
    var globalMediaItems = [MPMediaItem]()
    var arr_songs = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GlobalClass.songTimer.invalidate()
        GlobalClass.homeTimer.invalidate()
        
        self.view_search.layer.borderColor = UIColor.lightGray.cgColor
        self.view_search.layer.borderWidth = 1.0
        self.view_search.layer.cornerRadius = 10.0
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) == nil {
            self.view_navigationBar.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 1/255, alpha: 1.0)
        }
        else {
            let colorHex = UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) as! String
            self.view_navigationBar.backgroundColor = UIColor(hexString: colorHex)
        }
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_isPermissionGiven) as! Int == 0 {
            GlobalClass.showPermissionAlertMessage()
            self.txtSearch.isEnabled = false
        }
        else if UserDefaults.standard.value(forKey: GlobalClass.UD_isPermissionGiven) as! Int == 1 {
            self.txtSearch.isEnabled = true
            self.globalMediaItems = MPMediaQuery.songs().items!
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
    
    @IBAction func btnBack_Clicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func txtSearch_Changed(_ sender: UITextField) {
        let searchText = self.txtSearch.text!
        self.mediaItems.removeAll()
        self.arr_songs.removeAll()
        if searchText != "" {
            for item in self.globalMediaItems {
                if item.title != nil {
                    if item.title!.lowercased().contains(searchText.lowercased()) == true {
                        self.mediaItems.append(item)
                    }
                }
            }
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
                
                self.arr_songs.append(obj)
            }
        }
        self.tblSearch_result.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let noDataLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.tblSearch_result.bounds.width, height: self.tblSearch_result.bounds.height))
        noDataLabel.textColor = UIColor.black
        noDataLabel.font = UIFont(name: "Georgia", size: 17.0)
        noDataLabel.textAlignment = .center
        self.tblSearch_result.backgroundView = noDataLabel
        if self.arr_songs.count == 0 {
            noDataLabel.text = "No Data Found"
        }
        else {
            noDataLabel.text = ""
        }
        return self.arr_songs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tblSearch_result.dequeueReusableCell(withIdentifier: "cellSearch") as! SearchCell
        
        cell.song_name.text = self.arr_songs[indexPath.row]["name"] as? String
        cell.song_artist.text = self.arr_songs[indexPath.row]["artist"] as? String
        cell.song_image.image = self.arr_songs[indexPath.row]["image"] as? UIImage
        cell.song_image.layer.masksToBounds = true
        cell.song_image.layer.cornerRadius = 25.0
        
        //        cell.btnOptions.tag = indexPath.row
        //        cell.btnOptions.addTarget(self, action: #selector(self.btnOption_Clicked(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.customMediaItems.removeAll()
        self.customMediaItems.append(self.mediaItems[indexPath.row])
        
        let mediaCollection = MPMediaItemCollection(items: self.customMediaItems)
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
    
    //    @objc func btnOption_Clicked(sender:UIButton) {
    //        let dropDown = DropDown()
    //        dropDown.anchorView = sender
    //        dropDown.bottomOffset = CGPoint(x: 0, y: sender.bounds.height)
    //        dropDown.width = 150
    //        dropDown.dataSource = [
    //            "Play",
    //            "Play next",
    //            "Add to playlist"
    //        ]
    //        dropDown.selectionAction = { (index, item) in
    //            if item == "Play" {
    //                self.customMediaItems.removeAll()
    //                self.customMediaItems.append(self.mediaItems[sender.tag])
    //
    //                let mediaCollection = MPMediaItemCollection(items: self.mediaItems)
    //                GlobalClass.globalPlayer.setQueue(with: mediaCollection)
    //                switch GlobalClass.globalPlayer.shuffleMode {
    //                case .songs:
    //                    GlobalClass.globalPlayer.shuffleMode = .off
    //                    GlobalClass.globalPlayer.play()
    //                    GlobalClass.globalPlayer.shuffleMode = .songs
    //                case .off:
    //                    GlobalClass.globalPlayer.play()
    //                default:
    //                    GlobalClass.globalPlayer.shuffleMode = .off
    //                    GlobalClass.globalPlayer.play()
    //                }
    //
    //                let isDeleted = Modeldata.getInstance().deleteQueueData()
    //                print(isDeleted)
    //
    //                let objVC = self.storyboard?.instantiateViewController(withIdentifier: "NowPlayingVC") as! NowPlayingVC
    //                objVC.isComeFrom = 1
    //                self.navigationController?.pushViewController(objVC, animated: true)
    //                //self.delegate.sendDefaultSongData(song: self.arrSongs[sender.tag],mediaItems: self.mediaItems, isAppLaunch: false)
    //            }
    //            else if item == "Play next" {
    //                let queueData = playingQueueClass()
    //                queueData.song_name = self.arr_songs[sender.tag]["name"] as! String
    //
    //                let isInserted = Modeldata.getInstance().addQueueData(queueinfo: queueData)
    //                print(isInserted)
    //
    //                self.view.makeToast("1 song added to queue")
    //            }
    //            else if item == "Add to playlist" {
    //
    //                let playlistData = Modeldata.getInstance().getAllPlaylistData()
    //                if playlistData.count == 0 {
    //                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "AddPlaylistVC") as! AddPlaylistVC
    //                    objVC.delegate = self
    //                    objVC.songTitle = self.arr_songs[sender.tag]["name"] as! String
    //                    objVC.isComefrom = 0
    //                    objVC.modalPresentationStyle = .overFullScreen
    //                    objVC.modalTransitionStyle = .crossDissolve
    //                    self.present(objVC, animated: true, completion: nil)
    //                }
    //                else {
    //                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectPlaylistVC") as! SelectPlaylistVC
    //                    objVC.delegate = self
    //                    objVC.songTitle = self.arr_songs[sender.tag]["name"] as! String
    //                    objVC.modalPresentationStyle = .overFullScreen
    //                    objVC.modalTransitionStyle = .crossDissolve
    //                    self.present(objVC, animated: true, completion: nil)
    //                }
    //            }
    //        }
    //
    //        dropDown.show()
    //    }
    
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
