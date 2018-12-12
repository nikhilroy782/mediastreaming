//
//  SelectPlaylistVC.swift
//  My Music
//
//  Created by ICON on 18/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit

protocol SelectPlaylistVCDelegate {
    func songAdded(isAddClicked : Bool, message : String, songTitle : String)
}

class SelectPlaylistVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var popupView_height: NSLayoutConstraint!
    @IBOutlet weak var lbl_ChoosePlaylist: UILabel!
    @IBOutlet weak var tbl_playlist: UITableView!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var popupView: UIView!
    var delegate : SelectPlaylistVCDelegate!
    var playlistArr = [[String:String]]()
    var songTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) == nil {
            self.lbl_ChoosePlaylist.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 1/255, alpha: 255/255)
        }
        else {
            let colorHex = UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) as! String
            self.lbl_ChoosePlaylist.backgroundColor = UIColor(hexString: colorHex)
        }
        
        let playlistData = Modeldata.getInstance().getAllPlaylistData()
        
        for item in playlistData {
            let playlistInfo = item as! playlistClass
            let objPlaylist = ["id" : playlistInfo.id, "playlist_name" : playlistInfo.playlist_name, "playlist_song" : playlistInfo.playlist_song]
            self.playlistArr.append(objPlaylist)
        }
        
        if 40 + (self.playlistArr.count * 60) > 500 {
            self.popupView_height.constant = 500.0
        }
        else {
            self.popupView_height.constant = 40.0 + CGFloat(self.playlistArr.count * 60)
        }
        
        self.tapGesture.delegate = self
        
        self.tbl_playlist.reloadData()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if !((touch.view?.isDescendant(of: self.popupView))!)
        {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
            return true
        }
        return false
    }
    
    @IBAction func btnAdd_Clicked(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate.songAdded(isAddClicked: true, message: "", songTitle: self.songTitle)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlistArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tbl_playlist.dequeueReusableCell(withIdentifier: "SelectPlaylistCell") as! PlaylistCell
        cell.playlist_name.text = self.playlistArr[indexPath.row]["playlist_name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let playlistSong = self.playlistArr[indexPath.row]["playlist_song"]
        let playlistData = playlistClass()
        playlistData.id = self.playlistArr[indexPath.row]["id"]!
        if playlistSong == "" {
            playlistData.playlist_song = songTitle
            let isUpdated = Modeldata.getInstance().updatePlaylistData(playlistData: playlistData)
            print(isUpdated)
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    self.delegate.songAdded(isAddClicked: false, message: "Song Added Successfully", songTitle: self.songTitle)
                }
            }
        }
        else {
            let songsArr = playlistSong?.components(separatedBy: ",")
            
            if songsArr?.contains(songTitle) == true {
                print("Already Exists")
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.delegate.songAdded(isAddClicked: false, message: "Song Already Exists", songTitle: self.songTitle)
                    }
                }
            }
            else {
                playlistData.playlist_song = playlistSong! + "," + songTitle
                let isUpdated = Modeldata.getInstance().updatePlaylistData(playlistData: playlistData)
                print(isUpdated)
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.delegate.songAdded(isAddClicked: false, message: "Song Added Successfully", songTitle: self.songTitle)
                    }
                }
            }
        }
    }
    
}
