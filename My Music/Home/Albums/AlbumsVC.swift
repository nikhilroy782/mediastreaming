//
//  AlbumsVC.swift
//  My Music
//
//  Created by ICON on 06/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class AlbumsVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var tbl_albums: UITableView!
    @IBOutlet weak var collectio_albums: UICollectionView!
    
    var arrAlbums = [[String:Any]]()
    var albumCollection = [MPMediaItemCollection]()
    
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
            self.collectio_albums.isHidden = true
            self.tbl_albums.isHidden = false
        }
        else {
            let displayType = UserDefaults.standard.value(forKey: GlobalClass.UD_DisplayType) as! String
            if displayType == "List" {
                self.collectio_albums.isHidden = true
                self.tbl_albums.isHidden = false
            }
            else if displayType == "Grid" {
                self.collectio_albums.isHidden = false
                self.tbl_albums.isHidden = true
            }
        }
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_isPermissionGiven) as! Int == 0 {
            GlobalClass.showPermissionAlertMessage()
        }
        else if UserDefaults.standard.value(forKey: GlobalClass.UD_isPermissionGiven) as! Int == 1 {
            self.albumCollection = MPMediaQuery.albums().collections!
            
            for item in self.albumCollection {
                if item.representativeItem != nil {
                    let mainItem = item.representativeItem!
                    var name = ""
                    var artist = ""
                    var image = UIImage()
                    
                    if mainItem.albumTitle == nil {
                        name = "unknown"
                    }
                    else {
                        name = mainItem.albumTitle!
                    }
                    
                    if mainItem.albumArtist == nil {
                        artist = "unknown"
                    }
                    else {
                        artist = mainItem.albumArtist!
                    }
                    
                    if mainItem.artwork?.image(at: CGSize(width: 50.0, height: 50.0)) == nil {
                        image = #imageLiteral(resourceName: "logo")
                    }
                    else {
                        image = (mainItem.artwork?.image(at: CGSize(width: 50.0, height: 50.0))!)!
                    }
                    
                    let obj = ["name":name,"artist":artist,"image":image,"songs":item.items] as [String : Any]
                    
                    self.arrAlbums.append(obj)
                }
            }
            
            self.tbl_albums.reloadData()
            self.collectio_albums.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let noDataLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.tbl_albums.bounds.width, height: self.tbl_albums.bounds.height))
        noDataLabel.textColor = UIColor.black
        noDataLabel.font = UIFont(name: "Georgia", size: 17.0)
        noDataLabel.textAlignment = .center
        self.tbl_albums.backgroundView = noDataLabel
        if self.arrAlbums.count == 0 {
            noDataLabel.text = "No Data Found"
        }
        else {
            noDataLabel.text = ""
        }
        return self.arrAlbums.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tbl_albums.dequeueReusableCell(withIdentifier: "cellAlbumTable") as! AlbumTableCell
        
        cell.album_name.text = self.arrAlbums[indexPath.row]["name"] as? String
        cell.album_artist.text = self.arrAlbums[indexPath.row]["artist"] as? String
        cell.album_image.image = self.arrAlbums[indexPath.row]["image"] as? UIImage
        cell.album_image.layer.cornerRadius = 25.0
        cell.album_image.layer.masksToBounds = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "ArtistAlbumSongsVC") as! ArtistAlbumSongsVC
        objVC.mediaItems = self.arrAlbums[indexPath.row]["songs"] as! [MPMediaItem]
        objVC.artistalbumName = self.arrAlbums[indexPath.row]["name"] as! String
        objVC.artistalbumImage = self.arrAlbums[indexPath.row]["image"] as! UIImage
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let noDataLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: self.collectio_albums.bounds.width, height: self.collectio_albums.bounds.height))
        noDataLabel.textColor = UIColor.black
        noDataLabel.font = UIFont(name: "Georgia", size: 17.0)
        noDataLabel.textAlignment = .center
        self.collectio_albums.backgroundView = noDataLabel
        if self.arrAlbums.count == 0 {
            noDataLabel.text = "No Data Found"
        }
        else {
            noDataLabel.text = ""
        }
        return self.arrAlbums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 10)/2
        return CGSize(width: width, height: width + 42)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectio_albums.dequeueReusableCell(withReuseIdentifier: "cellAlbumCollection", for: indexPath) as! AlbumCollectionCell
        
        cell.album_name.text = self.arrAlbums[indexPath.row]["name"] as? String
        cell.album_artist.text = self.arrAlbums[indexPath.row]["artist"] as? String
        cell.album_image.image = self.arrAlbums[indexPath.row]["image"] as? UIImage
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "ArtistAlbumSongsVC") as! ArtistAlbumSongsVC
        objVC.mediaItems = self.arrAlbums[indexPath.row]["songs"] as! [MPMediaItem]
        objVC.artistalbumName = self.arrAlbums[indexPath.row]["name"] as! String
        objVC.artistalbumImage = self.arrAlbums[indexPath.row]["image"] as! UIImage
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
}
