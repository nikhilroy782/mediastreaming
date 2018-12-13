//
//  RadioVC.swift
//  My Music
//
//  Created by ICON on 11/12/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit
import AVFoundation

class RadioVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tbl_radio: UITableView!
    
    var stationArr = [["name":"Absolute Country Hits","desc":"The Music Starts Here","url":"http://strm112.1.fm/acountry_mobile_mp3"],["name":"Newport Folk Radio","desc":"Are you ready to Folk?","url":"http://rfcmedia.streamguys1.com/Newport.mp3"],["name":"The Alt Vault","desc":"Your Lifestyle... Your Music!","url":"http://jupiter.prostreaming.net/altmixxlow"],["name":"Classic Rock","desc":"Classic Rock Hits","url":"http://rfcmedia.streamguys1.com/classicrock.mp3"],["name":"Radio 1190","desc":"KVCU - Boulder, CO","url":"http://radio1190.colorado.edu:8000/high.mp3"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stationArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tbl_radio.dequeueReusableCell(withIdentifier: "RadioTableCell") as! RadioTableCell
        cell.img_radio.image = #imageLiteral(resourceName: "logo")
        cell.lbl_name.text = self.stationArr[indexPath.row]["name"]
        cell.lbl_desc.text = self.stationArr[indexPath.row]["desc"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = URL.init(string: self.stationArr[indexPath.row]["url"])
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .defaultToSpeaker)
            GlobalClass.player = AVPlayer.init(url: url)
            GlobalClass.player.play()
        } catch {
            print(error)
        }
    }
}
