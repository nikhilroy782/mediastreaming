//
//  AddPlaylistVC.swift
//  My Music
//
//  Created by WOS on 14/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit

protocol AddPlaylistVCDelegate {
    func playlistAdded(isComefrom : Int)
}

class AddPlaylistVC: UIViewController,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var lbl_CreatePlaylist: UILabel!
    @IBOutlet weak var view_playlistName: UIView!
    @IBOutlet weak var txt_playlistName: UITextField!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var popupView: UIView!
    var delegate : AddPlaylistVCDelegate!
    var songTitle = ""
    var isComefrom = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view_playlistName.layer.borderColor = UIColor.lightGray.cgColor
        self.view_playlistName.layer.borderWidth = 1.0
        self.view_playlistName.layer.cornerRadius = 5.0
        
        self.tapGesture.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) == nil {
            self.lbl_CreatePlaylist.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 1/255, alpha: 255/255)
        }
        else {
            let colorHex = UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) as! String
            self.lbl_CreatePlaylist.backgroundColor = UIColor(hexString: colorHex)
        }
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
    
    @IBAction func btnCancel_Clicked(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func btnAdd_Clicked(_ sender: UIButton) {
        let playlistData = playlistClass()
        playlistData.playlist_name = self.txt_playlistName.text!
        if self.isComefrom == 0 {
            playlistData.playlist_song = self.songTitle
        }
        else if self.isComefrom == 1 {
            playlistData.playlist_song = ""
        }
        let isInserted = Modeldata.getInstance().addPlaylistData(playlistinfo: playlistData)
        print(isInserted)
        DispatchQueue.main.async {
            self.dismiss(animated: true) {
                self.delegate.playlistAdded(isComefrom: self.isComefrom)
            }
        }
    }
    
}
