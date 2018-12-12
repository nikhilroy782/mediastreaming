//
//  SidemenuVC.swift
//  My Music
//
//  Created by ICON on 06/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit

class SidemenuVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var img_currentSong: UIImageView!
    @IBOutlet weak var lbl_currentSongName: UILabel!
    @IBOutlet weak var lbl_artist: UILabel!
    @IBOutlet weak var tbl_menu: UITableView!
    var menuArr = ["Now Playing","Library","Playlists","Playing Queue","Settings"]
    var menuIconArr = [#imageLiteral(resourceName: "bookmark_music"),#imageLiteral(resourceName: "library_music"),#imageLiteral(resourceName: "music_note"),#imageLiteral(resourceName: "playlist_play"),#imageLiteral(resourceName: "settings")]
    var nowplayingViewController: UINavigationController!
    var homeViewController: UINavigationController!
    var playlistViewController: UINavigationController!
    var queueViewController: UINavigationController!
    var settingsViewController: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_isNowPlayingTheme) as! Int == 0 {
            let nowplayingVC = storyboard.instantiateViewController(withIdentifier: "NowPlayingVC") as! NowPlayingVC
            self.nowplayingViewController = UINavigationController(rootViewController: nowplayingVC)
            nowplayingViewController.setNavigationBarHidden(true, animated: true)
        }
        else if UserDefaults.standard.value(forKey: GlobalClass.UD_isNowPlayingTheme) as! Int == 1 {
            let nowplayingVC = storyboard.instantiateViewController(withIdentifier: "NowPlayingVC2") as! NowPlayingVC2
            self.nowplayingViewController = UINavigationController(rootViewController: nowplayingVC)
            nowplayingViewController.setNavigationBarHidden(true, animated: true)
        }
        
        let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        self.homeViewController = UINavigationController(rootViewController: homeVC)
        homeViewController.setNavigationBarHidden(true, animated: true)
        
        let playlistVC = storyboard.instantiateViewController(withIdentifier: "PlaylistVC") as! PlaylistVC
        self.playlistViewController = UINavigationController(rootViewController: playlistVC)
        playlistViewController.setNavigationBarHidden(true, animated: true)
        
        let queueVC = storyboard.instantiateViewController(withIdentifier: "PlayingQueueVC") as! PlayingQueueVC
        self.queueViewController = UINavigationController(rootViewController: queueVC)
        queueViewController.setNavigationBarHidden(true, animated: true)
        
        let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        self.settingsViewController = UINavigationController(rootViewController: settingsVC)
        settingsViewController.setNavigationBarHidden(true, animated: true)
        
        if GlobalClass.globalPlayer.nowPlayingItem != nil {
            let currentSong = GlobalClass.globalPlayer.nowPlayingItem
            if currentSong?.title == nil {
                self.lbl_currentSongName.text = "unknown"
            }
            else {
                self.lbl_currentSongName.text = currentSong?.title
            }
            
            if currentSong?.artist == nil {
                self.lbl_artist.text = "unknown"
            }
            else {
                self.lbl_artist.text = currentSong?.artist
            }
            
            if currentSong?.artwork?.image(at: CGSize(width: 50.0, height: 50.0)) == nil {
                self.img_currentSong.image = #imageLiteral(resourceName: "logo")
            }
            else {
                self.img_currentSong.image = currentSong?.artwork?.image(at: CGSize(width: 50.0, height: 50.0))
            }
            
            if self.img_currentSong.image == #imageLiteral(resourceName: "logo") {
                self.img_currentSong.contentMode = .scaleAspectFit
            }
            else {
                self.img_currentSong.contentMode = .scaleAspectFill
                self.img_currentSong.clipsToBounds = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tbl_menu.dequeueReusableCell(withIdentifier: "menuCell") as! menuCell
        
        cell.lbl_name.text = self.menuArr[indexPath.row]
        cell.img_menu.image = self.menuIconArr[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.slideMenuController()?.changeMainViewController(self.nowplayingViewController, close: true)
        }
        else if indexPath.row == 1 {
            self.slideMenuController()?.changeMainViewController(self.homeViewController, close: true)
        }
        else if indexPath.row == 2 {
            self.slideMenuController()?.changeMainViewController(self.playlistViewController, close: true)
        }
        else if indexPath.row == 3 {
            self.slideMenuController()?.changeMainViewController(self.queueViewController, close: true)
        }
        else if indexPath.row == 4 {
            self.slideMenuController()?.changeMainViewController(self.settingsViewController, close: true)
        }
    }
    
}
