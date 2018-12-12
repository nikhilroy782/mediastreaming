//
//  SettingsVC.swift
//  My Music
//
//  Created by ICON on 09/09/18.
//  Copyright © 2018 Checkmate Softsense. All rights reserved.
//

import UIKit
import GoogleMobileAds

class SettingsVC: UIViewController,SelectColorVCDelegate,GADBannerViewDelegate {
    
    @IBOutlet weak var view_primaryColor: UIView!
    @IBOutlet weak var view_accentColor: UIView!
    @IBOutlet weak var view_navigationBar: UIView!
    @IBOutlet weak var lblNowPlaying_title: UILabel!
    @IBOutlet weak var lblPersonalisation_title: UILabel!
    @IBOutlet weak var btnChk_List: UIButton!
    @IBOutlet weak var btnChk_Grid: UIButton!
    @IBOutlet weak var bannerContainer: UIView!
    @IBOutlet weak var bannerContainer_height: NSLayoutConstraint!
    
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view_primaryColor.layer.borderColor = UIColor.black.cgColor
        self.view_primaryColor.layer.borderWidth = 1.0
        self.view_primaryColor.layer.cornerRadius = 15.0
        
        self.view_accentColor.layer.borderColor = UIColor.black.cgColor
        self.view_accentColor.layer.borderWidth = 1.0
        self.view_accentColor.layer.cornerRadius = 15.0
        
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
            self.view_navigationBar.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 1/255, alpha: 1.0)
            self.view_primaryColor.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 1/255, alpha: 1.0)
        }
        else {
            let colorHex = UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) as! String
            self.view_navigationBar.backgroundColor = UIColor(hexString: colorHex)
            self.view_primaryColor.backgroundColor = UIColor(hexString: colorHex)
        }
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_AccentColor) == nil {
            self.lblNowPlaying_title.textColor = UIColor.black
            self.lblPersonalisation_title.textColor = UIColor.black
            self.view_accentColor.backgroundColor = UIColor.black
        }
        else {
            let colorHex = UserDefaults.standard.value(forKey: GlobalClass.UD_AccentColor) as! String
            self.lblNowPlaying_title.textColor = UIColor(hexString: colorHex)
            self.lblPersonalisation_title.textColor = UIColor(hexString: colorHex)
            self.view_accentColor.backgroundColor = UIColor(hexString: colorHex)
        }
        
        if UserDefaults.standard.value(forKey: GlobalClass.UD_DisplayType) == nil {
            self.btnChk_List.setImage(#imageLiteral(resourceName: "checkboxFill"), for: .normal)
            self.btnChk_Grid.setImage(#imageLiteral(resourceName: "checkbox"), for: .normal)
        }
        else {
            let displayType = UserDefaults.standard.value(forKey: GlobalClass.UD_DisplayType) as! String
            if displayType == "List" {
                self.btnChk_List.setImage(#imageLiteral(resourceName: "checkboxFill"), for: .normal)
                self.btnChk_Grid.setImage(#imageLiteral(resourceName: "checkbox"), for: .normal)
            }
            else if displayType == "Grid" {
                self.btnChk_List.setImage(#imageLiteral(resourceName: "checkbox"), for: .normal)
                self.btnChk_Grid.setImage(#imageLiteral(resourceName: "checkboxFill"), for: .normal)
            }
        }
    }
    
    @IBAction func btnMenu_Clicked(_ sender: UIButton) {
        self.slideMenuController()?.openLeft()
    }
    
    @IBAction func btnSearch_Clicked(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    @IBAction func btnPrimary_Clicked(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectColorVC") as! SelectColorVC
        objVC.isComeFrom = "Primary"
        objVC.delegate = self
        objVC.modalPresentationStyle = .overFullScreen
        objVC.modalTransitionStyle = .crossDissolve
        self.present(objVC,animated: true,completion: nil)
    }
    
    @IBAction func btnAccent_Clicked(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectColorVC") as! SelectColorVC
        objVC.isComeFrom = "Accent"
        objVC.delegate = self
        objVC.modalPresentationStyle = .overFullScreen
        objVC.modalTransitionStyle = .crossDissolve
        self.present(objVC,animated: true,completion: nil)
    }
    
    @IBAction func btnNowplayingTheme_Clicked(_ sender: UIButton) {
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectNowPlayingVC") as! SelectNowPlayingVC
        self.navigationController?.pushViewController(objVC, animated: true)
    }
    
    func setSelectedColor(isComeFrom: String) {
        if isComeFrom == "Primary" {
            let colorHex = UserDefaults.standard.value(forKey: GlobalClass.UD_PrimaryColor) as! String
            self.view_navigationBar.backgroundColor = UIColor(hexString: colorHex)
            self.view_primaryColor.backgroundColor = UIColor(hexString: colorHex)
        }
        else if isComeFrom == "Accent" {
            let colorHex = UserDefaults.standard.value(forKey: GlobalClass.UD_AccentColor) as! String
            self.lblNowPlaying_title.textColor = UIColor(hexString: colorHex)
            self.lblPersonalisation_title.textColor = UIColor(hexString: colorHex)
            self.view_accentColor.backgroundColor = UIColor(hexString: colorHex)
        }
    }
    
    @IBAction func btnChkList_Clicked(_ sender: UIButton) {
        UserDefaults.standard.setValue("List", forKey: GlobalClass.UD_DisplayType)
        self.btnChk_List.setImage(#imageLiteral(resourceName: "checkboxFill"), for: .normal)
        self.btnChk_Grid.setImage(#imageLiteral(resourceName: "checkbox"), for: .normal)
    }
    
    @IBAction func btnChkGrid_Clicked(_ sender: UIButton) {
        UserDefaults.standard.setValue("Grid", forKey: GlobalClass.UD_DisplayType)
        self.btnChk_List.setImage(#imageLiteral(resourceName: "checkbox"), for: .normal)
        self.btnChk_Grid.setImage(#imageLiteral(resourceName: "checkboxFill"), for: .normal)
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
