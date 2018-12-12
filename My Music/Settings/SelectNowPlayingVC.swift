//
//  SelectNowPlayingVC.swift
//  My Music
//
//  Created by ICON on 12/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit

class SelectNowPlayingVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collection_palyTheme: UICollectionView!
    @IBOutlet weak var view_navigationBar: UIView!
    var themeArr : [UIImage] = [#imageLiteral(resourceName: "timber_3_nowplaying_x"),#imageLiteral(resourceName: "timber_1_nowplaying_x")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) == nil {
            self.view_navigationBar.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 1/255, alpha: 255/255)
        }
        else {
            let colorHex = UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) as! String
            self.view_navigationBar.backgroundColor = UIColor(hexString: colorHex)
        }
    }
    
    @IBAction func btnBack_Clicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.themeArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collection_palyTheme.frame.size.width, height: self.collection_palyTheme.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collection_palyTheme.dequeueReusableCell(withReuseIdentifier: "NowPlayingCell", for: indexPath) as! NowPlayingCell
        cell.img_playTheme.image = self.themeArr[indexPath.row]
        
        if indexPath.row == UserDefaults.standard.value(forKey: GlobalClass.UD_isNowPlayingTheme) as! Int {
            cell.imgSelected.isHidden = false
        }
        else {
            cell.imgSelected.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            UserDefaults.standard.set(0, forKey: GlobalClass.UD_isNowPlayingTheme)
        }
        else if indexPath.row == 1 {
            UserDefaults.standard.set(1, forKey: GlobalClass.UD_isNowPlayingTheme)
        }
        self.collection_palyTheme.reloadData()
    }
    
}
