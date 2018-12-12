//
//  ArtistsVC.swift
//  My Music
//
//  Created by ICON on 06/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class ArtistsVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var tbl_artists: UITableView!
    @IBOutlet weak var collection_artists: UICollectionView!
    
    var arrArtists = [[String:Any]]()
    var artistCollection = [MPMediaItemCollection]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_DisplayType) == nil {
            self.collection_artists.isHidden = true
            self.tbl_artists.isHidden = false
        }
        else {
            let displayType = UserDefaults.standard.value(forKey: GlobalClass.UD_DisplayType) as! String
            if displayType == "List" {
                self.collection_artists.isHidden = true
                self.tbl_artists.isHidden = false
            }
            else if displayType == "Grid" {
                self.collection_artists.isHidden = false
                self.tbl_artists.isHidden = true
            }
        }
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_isPermissionGiven) as! Int == 0 {
            GlobalClass.showPermissionAlertMessage()
        }
        else if UserDefaults.standard.value(forKey: GlobalClass.UD_isPermissionGiven) as! Int == 1 {
            self.artistCollection = MPMediaQuery.artists().collections!
            
            for item in self.artistCollection {
                if item.representativeItem != nil {
                    let mainItem = item.representativeItem!
                    var name = ""
                    var image = UIImage()
                    //var songs = [MPMediaItem]()
                    
                    if mainItem.artist == nil {
                        name = "unknown"
                    }
                    else {
                        name = mainItem.artist!
                    }
                    
                    if mainItem.artwork?.image(at: CGSize(width: 50.0, height: 50.0)) == nil {
                        image = #imageLiteral(resourceName: "logo")
                    }
                    else {
                        image = (mainItem.artwork?.image(at: CGSize(width: 50.0, height: 50.0))!)!
                    }
                    
                    let obj = ["name":name,"image":image,"songs":item.items] as [String : Any]
                    
                    self.arrArtists.append(obj)
                }
            }
            self.tbl_artists.reloadData()
            self.collection_artists.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let noDataLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.tbl_artists.bounds.width, height: self.tbl_artists.bounds.height))
        noDataLabel.textColor = UIColor.black
        noDataLabel.font = UIFont(name: "Georgia", size: 17.0)
        noDataLabel.textAlignment = .center
        self.tbl_artists.backgroundView = noDataLabel
        if self.arrArtists.count == 0 {
            noDataLabel.text = "No Data Found"
        }
        else {
            noDataLabel.text = ""
        }
        return self.arrArtists.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tbl_artists.dequeueReusableCell(withIdentifier: "cellArtistTable") as! ArtistTableCell
        
        cell.artist_name.text = self.arrArtists[indexPath.row]["name"] as? String
        cell.artist_image.image = self.arrArtists[indexPath.row]["image"] as? UIImage
        cell.artist_image.layer.cornerRadius = 25.0
        cell.artist_image.layer.masksToBounds = true
        
        let items = self.arrArtists[indexPath.row]["songs"] as! [MPMediaItem]
        if items.count == 1 {
            cell.artist_count.text = "\(items.count)" + " song"
        }
        else {
            cell.artist_count.text = "\(items.count)" + " songs"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "ArtistAlbumSongsVC") as! ArtistAlbumSongsVC
        objVC.mediaItems = self.arrArtists[indexPath.row]["songs"] as! [MPMediaItem]
        objVC.artistalbumName = self.arrArtists[indexPath.row]["name"] as! String
        objVC.artistalbumImage = self.arrArtists[indexPath.row]["image"] as! UIImage
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let noDataLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.collection_artists.bounds.width, height: self.collection_artists.bounds.height))
        noDataLabel.textColor = UIColor.black
        noDataLabel.font = UIFont(name: "Georgia", size: 17.0)
        noDataLabel.textAlignment = .center
        self.collection_artists.backgroundView = noDataLabel
        if self.arrArtists.count == 0 {
            noDataLabel.text = "No Data Found"
        }
        else {
            noDataLabel.text = ""
        }
        return self.arrArtists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 10)/2
        return CGSize(width: width, height: width + 42)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collection_artists.dequeueReusableCell(withReuseIdentifier: "cellArtistCollection", for: indexPath) as! ArtistCollectionCell
        
        cell.artist_name.text = self.arrArtists[indexPath.row]["name"] as? String
        cell.artist_image.image = self.arrArtists[indexPath.row]["image"] as? UIImage
        
        let items = self.arrArtists[indexPath.row]["songs"] as! [MPMediaItem]
        if items.count == 1 {
            cell.artist_count.text = "\(items.count)" + " song"
        }
        else {
            cell.artist_count.text = "\(items.count)" + " songs"
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "ArtistAlbumSongsVC") as! ArtistAlbumSongsVC
        objVC.mediaItems = self.arrArtists[indexPath.row]["songs"] as! [MPMediaItem]
        objVC.artistalbumName = self.arrArtists[indexPath.row]["name"] as! String
        objVC.artistalbumImage = self.arrArtists[indexPath.row]["image"] as! UIImage
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
}
